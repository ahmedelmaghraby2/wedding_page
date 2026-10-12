import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/features/wedding/application/music_cubit.dart';

void main() {
  test('reflects the controller state on creation', () {
    final cubit = MusicCubit(controller: MusicController());
    expect(cubit.state.status, MusicStatus.idle);
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.muted, isFalse);
    cubit.close();
  });

  test('toggleMute updates both the cubit and the controller', () async {
    final controller = MusicController();
    final cubit = MusicCubit(controller: controller);

    await cubit.toggleMute();
    expect(cubit.state.muted, isTrue);
    expect(controller.isMuted, isTrue);

    await cubit.toggleMute();
    expect(cubit.state.muted, isFalse);

    await cubit.close();
  });
}
