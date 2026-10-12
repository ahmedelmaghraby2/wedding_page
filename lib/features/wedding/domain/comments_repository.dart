import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

/// Port through which the application reads and mutates guest comments.
///
/// Presentation/application layers depend on this abstraction only, which keeps
/// the Firestore implementation swappable and the state layer testable with an
/// in-memory fake.
abstract interface class CommentsRepository {
  /// Emits the (filtered, newest-first) comment list whenever it changes.
  Stream<List<WeddingComment>> watchComments();

  /// One-shot read used when a live stream cannot be established.
  Future<CommentsLoadResult> getCommentsOnce();

  /// Creates a comment. [accessCode] is the owner's private edit/delete code.
  Future<CommentResult> addComment(WeddingComment comment, String accessCode);

  /// Proves ownership of [commentId] before an edit/delete. On success the
  /// caller may reuse the same [accessCode] for the follow-up mutation.
  Future<CommentResult> verifyAccessCode(String commentId, String accessCode);

  Future<CommentResult> updateComment(
    String commentId,
    String newCommentText,
    String accessCode,
  );

  Future<CommentResult> deleteComment(String commentId, String accessCode);
}
