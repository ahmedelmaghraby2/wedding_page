import 'package:wedding/features/wedding/domain/wedding_comment.dart';

/// Storage-agnostic failure reasons surfaced by [CommentsRepository].
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

/// Outcome of a single comment mutation (create/update/delete/verify).
class CommentResult {
  const CommentResult._(this.failure);

  const CommentResult.success() : this._(null);

  const CommentResult.failure(CommentFailure failure) : this._(failure);

  final CommentFailure? failure;

  bool get isSuccess => failure == null;

  bool get isFailure => failure != null;
}

/// Outcome of loading a comment list.
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
