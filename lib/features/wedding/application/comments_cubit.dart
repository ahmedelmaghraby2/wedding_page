import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/comments_repository.dart';
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

/// Owns all guest-comment business logic and exposes it as testable state.
///
/// Depends only on the [CommentsRepository] port, so it can be exercised with an
/// in-memory fake. Localization is intentionally absent here: the UI renders
/// [CommentsState.submitResult] via `messageForFailure`.
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository) : super(const CommentsState()) {
    subscribe();
  }

  final CommentsRepository _repository;
  StreamSubscription<List<WeddingComment>>? _subscription;
  int _generation = 0;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }

  /// (Re)subscribes to the comment stream. Safe to call repeatedly (retry).
  void subscribe() {
    _subscription?.cancel();
    final generation = ++_generation;
    emit(state.copyWith(isLoading: true, loadFailure: null));

    var received = false;
    _subscription = _repository.watchComments().listen(
      (comments) {
        received = true;
        if (generation != _generation || isClosed) return;
        emit(
          state.copyWith(
            comments: List.unmodifiable(comments),
            isLoading: false,
            loadFailure: null,
          ),
        );
      },
      onError: (Object _) {
        if (generation != _generation || isClosed) return;
        emit(
          state.copyWith(
            isLoading: false,
            loadFailure: CommentFailure.unknown,
          ),
        );
      },
      onDone: () {
        if (generation != _generation || isClosed || received) return;
        emit(
          state.copyWith(
            isLoading: false,
            loadFailure: CommentFailure.firebaseUnavailable,
          ),
        );
      },
    );
  }

  /// Creates a comment. Returns the raw [CommentResult] so the caller can react
  /// (e.g. clear the form); duplicate submissions are ignored.
  Future<CommentResult> addComment({
    required String fullName,
    required String comment,
    required String accessCode,
  }) async {
    if (state.isSubmitting) {
      return const CommentResult.failure(CommentFailure.conflict);
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        submitResult: null,
      ),
    );
    final trimmedName = fullName.trim();
    final result = await _repository.addComment(
      WeddingComment(
        fullName: trimmedName,
        comment: comment.trim(),
      ),
      accessCode,
    );
    if (isClosed) return result;
    emit(state.copyWith(isSubmitting: false, submitResult: result));
    return result;
  }

  Future<CommentResult> verifyAccessCode(
    String commentId,
    String accessCode,
  ) => _repository.verifyAccessCode(commentId, accessCode);

  Future<CommentResult> updateComment(
    String commentId,
    String newText,
    String accessCode,
  ) => _repository.updateComment(commentId, newText, accessCode);

  Future<CommentResult> deleteComment(
    String commentId,
    String accessCode,
  ) => _repository.deleteComment(commentId, accessCode);
}
