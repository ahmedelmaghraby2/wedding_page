import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/features/wedding/application/music_cubit.dart';
import 'package:wedding/widgets/music_button.dart';

void main() {
  group('MusicCubit mirrors its single MusicController', () {
    test('initial state matches the controller', () {
      final controller = MusicController();
      final cubit = MusicCubit(controller: controller);
      addTearDown(() async {
        await cubit.close();
      });

      expect(cubit.state.status, MusicStatus.idle);
      expect(cubit.state.isPlaying, isFalse);
      expect(cubit.state.muted, isFalse);
      expect(cubit.state.hasError, isFalse);
    });

    test('reflects a mute toggle made directly on the controller', () async {
      final controller = MusicController();
      final cubit = MusicCubit(controller: controller);
      addTearDown(() async {
        await cubit.close();
      });

      final states = <MusicState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      await controller.toggleMute();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.muted, isTrue);
      expect(states.last.muted, isTrue);
    });

    test('close disposes the cubit without a live player', () async {
      final controller = MusicController();
      final cubit = MusicCubit(controller: controller);

      await cubit.close();

      expect(cubit.isClosed, isTrue);
    });
  });

  group('single shared player (no duplicate sources)', () {
    testWidgets('two controls bound to one cubit render without conflict', (
      tester,
    ) async {
      final controller = MusicController();
      final cubit = MusicCubit(controller: controller);
      addTearDown(() async {
        await cubit.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MusicButton(cubit: cubit),
                const SizedBox(width: 24),
                MusicButton(cubit: cubit),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(MusicButton), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
