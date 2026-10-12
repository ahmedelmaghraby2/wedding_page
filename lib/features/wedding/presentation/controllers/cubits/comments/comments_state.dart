import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

/// Sentinel used by [CommentsState.copyWith] to distinguish "leave unchanged"
/// from "set to null" for nullable fields.
const Object _unset = Object();

/// Immutable UI state for the guest-wishes section.
class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.isLoading = true,
    this.loadFailure,
    this.isSubmitting = false,
    this.submitResult,
  });

  final List<WeddingComment> comments;

  /// The initial/live load is in flight.
  final bool isLoading;

  /// Non-null when the comment list could not be loaded.
  final CommentFailure? loadFailure;

  /// A create request is in flight (guards duplicate submissions).
  final bool isSubmitting;

  /// Result of the most recent create request, for the form to render.
  final CommentResult? submitResult;

  bool get hasLoadFailure => loadFailure != null;

  CommentsState copyWith({
    List<WeddingComment>? comments,
    bool? isLoading,
    Object? loadFailure = _unset,
    bool? isSubmitting,
    Object? submitResult = _unset,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      loadFailure: identical(loadFailure, _unset)
          ? this.loadFailure
          : loadFailure as CommentFailure?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitResult: identical(submitResult, _unset)
          ? this.submitResult
          : submitResult as CommentResult?,
    );
  }
}
