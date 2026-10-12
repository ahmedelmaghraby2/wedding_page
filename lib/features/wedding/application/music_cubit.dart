import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedding/core/music/music_controller.dart';

/// Immutable view state for the background-music controls.
class MusicState {
  const MusicState({required this.status, required this.muted, this.errorMessage});

  final MusicStatus status;
  final bool muted;
  final String? errorMessage;

  bool get isPlaying => status == MusicStatus.playing;
  bool get isLoading => status == MusicStatus.loading;
  bool get hasError => status == MusicStatus.error;
}

/// Exposes the app-wide [MusicController] as Bloc state so controls are
/// declarative and testable. It owns the controller's lifetime: [close] disposes
/// the underlying player exactly once.
class MusicCubit extends Cubit<MusicState> {
  MusicCubit({required MusicController controller})
    : _controller = controller,
      super(_from(controller)) {
    _controller.addListener(_sync);
  }

  final MusicController _controller;

  static MusicState _from(MusicController controller) => MusicState(
    status: controller.status,
    muted: controller.isMuted,
    errorMessage: controller.errorMessage,
  );

  void _sync() {
    if (isClosed) return;
    emit(_from(_controller));
  }

  Future<void> warmUp() => _controller.warmUp();

  Future<void> play() => _controller.play();

  Future<void> pause() => _controller.pause();

  Future<void> togglePlayPause() => _controller.togglePlayPause();

  Future<void> toggleMute() => _controller.toggleMute();

  @override
  Future<void> close() {
    _controller.removeListener(_sync);
    _controller.dispose();
    return super.close();
  }
}
