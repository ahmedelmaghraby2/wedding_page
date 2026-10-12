import 'dart:async';

import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/comments_repository.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

/// In-memory [CommentsRepository] double shared by unit and widget tests.
///
/// Tests drive the stream via [emitComments]/[emitError] and choose the result
/// of each mutation through the `*Result` fields; no Firebase is required.
class FakeCommentsRepository implements CommentsRepository {
  final StreamController<List<WeddingComment>> _controller =
      StreamController<List<WeddingComment>>.broadcast();

  CommentResult addResult = const CommentResult.success();
  CommentResult verifyResult = const CommentResult.success();
  CommentResult updateResult = const CommentResult.success();
  CommentResult deleteResult = const CommentResult.success();
  CommentsLoadResult loadResult = const CommentsLoadResult.success([]);

  int addCalls = 0;
  int verifyCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  Completer<void>? addGate;

  void emitComments(List<WeddingComment> comments) =>
      _controller.add(comments);

  void emitError(Object error) => _controller.addError(error);

  Future<void> closeStream() => _controller.close();

  @override
  Stream<List<WeddingComment>> watchComments() => _controller.stream;

  @override
  Future<CommentsLoadResult> getCommentsOnce() async => loadResult;

  @override
  Future<CommentResult> addComment(
    WeddingComment comment,
    String accessCode,
  ) async {
    addCalls++;
    if (addGate != null) await addGate!.future;
    return addResult;
  }

  @override
  Future<CommentResult> verifyAccessCode(
    String commentId,
    String accessCode,
  ) async {
    verifyCalls++;
    return verifyResult;
  }

  @override
  Future<CommentResult> updateComment(
    String commentId,
    String newCommentText,
    String accessCode,
  ) async {
    updateCalls++;
    return updateResult;
  }

  @override
  Future<CommentResult> deleteComment(
    String commentId,
    String accessCode,
  ) async {
    deleteCalls++;
    return deleteResult;
  }
}
