import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wedding/features/wedding/data/comment_access_code.dart';
import 'package:wedding/features/wedding/data/wedding_comment.dart';

enum CommentFailure {
  invalidCode,
  notFound,
  network,
  permissionDenied,
  invalidData,
  conflict,
  firebaseUnavailable,
  unknown,
}

class CommentResult {
  const CommentResult._(this.failure);

  const CommentResult.success() : this._(null);

  const CommentResult.failure(CommentFailure failure) : this._(failure);

  final CommentFailure? failure;

  bool get isSuccess => failure == null;

  bool get isFailure => failure != null;
}

class CommentsLoadResult {
  const CommentsLoadResult._(this.comments, this.failure);

  const CommentsLoadResult.success(List<WeddingComment> comments)
    : this._(comments, null);

  const CommentsLoadResult.failure(CommentFailure failure)
    : this._(const [], failure);

  final List<WeddingComment> comments;
  final CommentFailure? failure;

  bool get isSuccess => failure == null;
}

CommentFailure mapFirestoreError(Object error, {CommentFailure? onDenied}) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return onDenied ?? CommentFailure.permissionDenied;
      case 'not-found':
        return CommentFailure.notFound;
      case 'unavailable':
      case 'deadline-exceeded':
      case 'cancelled':
      case 'timeout':
        return CommentFailure.network;
      case 'aborted':
      case 'failed-precondition':
      case 'already-exists':
        return CommentFailure.conflict;
      case 'invalid-argument':
      case 'resource-exhausted':
      case 'data-loss':
        return CommentFailure.invalidData;
      default:
        return CommentFailure.unknown;
    }
  }
  return CommentFailure.unknown;
}

class WeddingCommentRepository {
  WeddingCommentRepository([this._firestore]);

  FirebaseFirestore? _firestore;

  static const String commentsCollectionName = 'wedding_comments';
  static const String ownersCollectionName = 'comment_owners';

  FirebaseFirestore? get _db {
    final existing = _firestore;
    if (existing != null) return existing;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
    return _firestore;
  }

  CollectionReference<Map<String, dynamic>>? get _comments {
    final db = _db;
    if (db == null) return null;
    return db.collection(commentsCollectionName);
  }

  CollectionReference<Map<String, dynamic>>? get _owners {
    final db = _db;
    if (db == null) return null;
    return db.collection(ownersCollectionName);
  }

  Stream<List<WeddingComment>> getCommentsStream() {
    final comments = _comments;
    if (comments == null) return const Stream<List<WeddingComment>>.empty();
    try {
      return comments
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final parsed = <WeddingComment>[];
            for (final doc in snapshot.docs) {
              try {
                parsed.add(WeddingComment.fromFirestore(doc));
              } catch (_) {
                // Skip malformed documents gracefully.
              }
            }
            return parsed;
          })
          .handleError((_) {});
    } catch (_) {
      return const Stream<List<WeddingComment>>.empty();
    }
  }

  Future<CommentsLoadResult> getCommentsOnce() async {
    final comments = _comments;
    if (comments == null) {
      return const CommentsLoadResult.failure(
        CommentFailure.firebaseUnavailable,
      );
    }
    try {
      final snapshot = await comments
          .orderBy('createdAt', descending: true)
          .get();
      final parsed = <WeddingComment>[];
      for (final doc in snapshot.docs) {
        try {
          parsed.add(WeddingComment.fromFirestore(doc));
        } catch (_) {
          // Skip malformed documents gracefully.
        }
      }
      return CommentsLoadResult.success(parsed);
    } catch (error) {
      return CommentsLoadResult.failure(mapFirestoreError(error));
    }
  }

  Future<CommentResult> addComment(
    WeddingComment comment,
    String accessCode,
  ) async {
    final code = CommentAccessCode.normalize(accessCode);
    if (CommentAccessCode.validate(code) != null) {
      return const CommentResult.failure(CommentFailure.invalidData);
    }
    final comments = _comments;
    final owners = _owners;
    final db = _db;
    if (comments == null || owners == null || db == null) {
      return const CommentResult.failure(CommentFailure.firebaseUnavailable);
    }
    try {
      final commentRef = comments.doc();
      final ownerRef = owners.doc(commentRef.id);
      final batch = db.batch();
      batch.set(commentRef, comment.toMapForCreate());
      batch.set(ownerRef, {
        'commentId': commentRef.id,
        'codeHash': CommentAccessCode.digest(code),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return const CommentResult.success();
    } catch (error) {
      return CommentResult.failure(
        mapFirestoreError(error, onDenied: CommentFailure.permissionDenied),
      );
    }
  }

  Future<CommentResult> verifyAccessCode(
    String commentId,
    String accessCode,
  ) async {
    final code = CommentAccessCode.normalize(accessCode);
    if (CommentAccessCode.validate(code) != null) {
      return const CommentResult.failure(CommentFailure.invalidCode);
    }
    final owners = _owners;
    if (owners == null) {
      return const CommentResult.failure(CommentFailure.firebaseUnavailable);
    }
    try {
      await owners.doc(commentId).update({
        'proofHash': CommentAccessCode.digest(code),
        'proofNonce': CommentAccessCode.newNonce(),
      });
      return const CommentResult.success();
    } catch (error) {
      return CommentResult.failure(
        mapFirestoreError(error, onDenied: CommentFailure.invalidCode),
      );
    }
  }

  Future<CommentResult> updateComment(
    String commentId,
    String newCommentText,
    String accessCode,
  ) async {
    final text = newCommentText.trim();
    if (text.isEmpty || text.length > 500) {
      return const CommentResult.failure(CommentFailure.invalidData);
    }
    return _runOwnedMutation(
      commentId: commentId,
      accessCode: accessCode,
      apply: (batch, commentRef) => batch.update(commentRef, {'comment': text}),
    );
  }

  Future<CommentResult> deleteComment(
    String commentId,
    String accessCode,
  ) {
    return _runOwnedMutation(
      commentId: commentId,
      accessCode: accessCode,
      requireExisting: true,
      apply: (batch, commentRef) => batch.delete(commentRef),
    );
  }

  Future<CommentResult> _runOwnedMutation({
    required String commentId,
    required String accessCode,
    bool requireExisting = false,
    required void Function(
      WriteBatch batch,
      DocumentReference<Map<String, dynamic>> commentRef,
    )
    apply,
  }) async {
    final code = CommentAccessCode.normalize(accessCode);
    if (CommentAccessCode.validate(code) != null) {
      return const CommentResult.failure(CommentFailure.invalidCode);
    }
    final comments = _comments;
    final owners = _owners;
    final db = _db;
    if (comments == null || owners == null || db == null) {
      return const CommentResult.failure(CommentFailure.firebaseUnavailable);
    }
    try {
      final commentRef = comments.doc(commentId);
      if (requireExisting) {
        final snapshot = await commentRef.get();
        if (!snapshot.exists) {
          return const CommentResult.failure(CommentFailure.notFound);
        }
      }
      final batch = db.batch();
      batch.update(owners.doc(commentId), {
        'proofHash': CommentAccessCode.digest(code),
        'proofNonce': CommentAccessCode.newNonce(),
      });
      apply(batch, commentRef);
      await batch.commit();
      return const CommentResult.success();
    } catch (error) {
      return CommentResult.failure(
        mapFirestoreError(error, onDenied: CommentFailure.permissionDenied),
      );
    }
  }
}
