import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/application/comments_cubit.dart';
import 'package:wedding/features/wedding/domain/comment_failure.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

import 'support/fake_comments_repository.dart';

void main() {
  late FakeCommentsRepository fake;
  late CommentsCubit cubit;

  setUp(() {
    fake = FakeCommentsRepository();
    cubit = CommentsCubit(fake);
  });

  tearDown(() async {
    await cubit.close();
    await fake.closeStream();
  });

  test('starts in a loading state and subscribes immediately', () {
    expect(cubit.state.isLoading, isTrue);
    expect(cubit.state.comments, isEmpty);
    expect(cubit.state.hasLoadFailure, isFalse);
  });

  test('emits comments and clears loading on stream data', () async {
    fake.emitComments(const [WeddingComment(id: '1', fullName: 'Jane')]);
    await pumpEventQueue();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.comments, hasLength(1));
    expect(cubit.state.comments.single.fullName, 'Jane');
    expect(cubit.state.hasLoadFailure, isFalse);
  });

  test('empty list is a successful, non-error state', () async {
    fake.emitComments(const []);
    await pumpEventQueue();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.comments, isEmpty);
    expect(cubit.state.hasLoadFailure, isFalse);
  });

  test('stream error becomes a load failure', () async {
    fake.emitError(StateError('boom'));
    await pumpEventQueue();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.loadFailure, CommentFailure.unknown);
  });

  test('a closed stream with no data reports firebaseUnavailable', () async {
    await fake.closeStream();
    await pumpEventQueue();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.loadFailure, CommentFailure.firebaseUnavailable);
  });

  test('subscribe() resets to loading and re-listens', () async {
    fake.emitComments(const [WeddingComment(id: '1')]);
    await pumpEventQueue();
    expect(cubit.state.comments, hasLength(1));

    cubit.subscribe();
    expect(cubit.state.isLoading, isTrue);

    fake.emitComments(const [WeddingComment(id: '2')]);
    await pumpEventQueue();
    expect(cubit.state.comments.single.id, '2');
  });

  test('addComment emits submitting then success', () async {
    final future = cubit.addComment(
      fullName: 'Jane',
      comment: 'Congrats',
      accessCode: 'A7m#K2p!',
    );
    expect(cubit.state.isSubmitting, isTrue);

    final result = await future;
    expect(result.isSuccess, isTrue);
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.submitResult?.isSuccess, isTrue);
    expect(fake.addCalls, 1);
  });

  test('addComment surfaces a failure result', () async {
    fake.addResult = const CommentResult.failure(CommentFailure.network);
    final result = await cubit.addComment(
      fullName: 'Jane',
      comment: 'Congrats',
      accessCode: 'A7m#K2p!',
    );
    expect(result.failure, CommentFailure.network);
    expect(cubit.state.submitResult?.failure, CommentFailure.network);
  });

  test('duplicate submissions are ignored while one is in flight', () async {
    final gate = Completer<void>();
    fake.addGate = gate;

    final first = cubit.addComment(
      fullName: 'Jane',
      comment: 'One',
      accessCode: 'A7m#K2p!',
    );
    await pumpEventQueue();
    expect(cubit.state.isSubmitting, isTrue);

    final second = await cubit.addComment(
      fullName: 'Jane',
      comment: 'Two',
      accessCode: 'A7m#K2p!',
    );
    expect(second.failure, CommentFailure.conflict);
    expect(fake.addCalls, 1);

    gate.complete();
    await first;
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('verify/update/delete delegate to the repository', () async {
    await cubit.verifyAccessCode('1', 'A7m#K2p!');
    await cubit.updateComment('1', 'New', 'A7m#K2p!');
    await cubit.deleteComment('1', 'A7m#K2p!');

    expect(fake.verifyCalls, 1);
    expect(fake.updateCalls, 1);
    expect(fake.deleteCalls, 1);
  });
}
