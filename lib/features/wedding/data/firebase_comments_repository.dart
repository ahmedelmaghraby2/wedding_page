import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wedding/features/wedding/data/wedding_comment_mapper.dart';
import 'package:wedding/features/wedding/domain/comment_access_code.dart';
import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/comments_repository.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

// The public constructor takes `weddingId`/`firestore` but stores them in
// private fields (intentional encapsulation), so the initializing-formal
// suggestion cannot apply here.
// ignore_for_file: prefer_initializing_formals

/// Maps Firestore exceptions to the storage-agnostic [CommentFailure] domain.
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

/// Firestore-backed [CommentsRepository]. Scopes every read/write to the active
/// `weddingId` so a single database can serve many couples' sites.
class FirebaseCommentsRepository implements CommentsRepository {
  FirebaseCommentsRepository({String? weddingId, FirebaseFirestore? firestore})
    : _weddingId = weddingId,
      _firestore = firestore;

  static const String commentsCollectionName = 'wedding_comments';
  static const String ownersCollectionName = 'comment_owners';

  final String? _weddingId;
  FirebaseFirestore? _firestore;

  String? get _scopedWeddingId {
    final id = _weddingId?.trim();
    return (id == null || id.isEmpty) ? null : id;
  }

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
    return db?.collection(commentsCollectionName);
  }

  CollectionReference<Map<String, dynamic>>? get _owners {
    final db = _db;
    return db?.collection(ownersCollectionName);
  }

  @override
  Stream<List<WeddingComment>> watchComments() {
    final comments = _comments;
    if (comments == null) {
      return const Stream<List<WeddingComment>>.empty();
    }
    try {
      Query<Map<String, dynamic>> query = comments;
      final id = _scopedWeddingId;
      if (id != null) {
        query = query.where('weddingId', isEqualTo: id);
      }
      return query.snapshots().map(_parseAndSort);
    } catch (_) {
      return const Stream<List<WeddingComment>>.empty();
    }
  }

  List<WeddingComment> _parseAndSort(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final scoped = _scopedWeddingId;
    final parsed = <WeddingComment>[];
    for (final doc in snapshot.docs) {
      try {
        final comment = WeddingCommentMapper.fromSnapshot(doc);
        if (scoped != null && comment.weddingId != scoped) {
          continue;
        }
        parsed.add(comment);
      } catch (_) {
        // Skip malformed documents gracefully.
      }
    }
    parsed.sort((a, b) {
      final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return parsed;
  }

  @override
  Future<CommentsLoadResult> getCommentsOnce() async {
    final comments = _comments;
    if (comments == null) {
      return const CommentsLoadResult.failure(
        CommentFailure.firebaseUnavailable,
      );
    }
    try {
      Query<Map<String, dynamic>> query = comments;
      final id = _scopedWeddingId;
      if (id != null) {
        query = query.where('weddingId', isEqualTo: id);
      }
      final snapshot = await query.get();
      return CommentsLoadResult.success(_parseAndSort(snapshot));
    } catch (error) {
      return CommentsLoadResult.failure(mapFirestoreError(error));
    }
  }

  @override
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
      batch.set(
        commentRef,
        WeddingCommentMapper.toCreateMap(comment, weddingId: _scopedWeddingId),
      );
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

  @override
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

  @override
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

  @override
  Future<CommentResult> deleteComment(String commentId, String accessCode) {
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
