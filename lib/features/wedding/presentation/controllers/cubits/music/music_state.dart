import 'package:wedding/core/music/music_controller.dart';

/// Immutable view state for the background-music controls.
class MusicState {
  const MusicState({
    required this.status,
    required this.muted,
    this.errorMessage,
  });

  final MusicStatus status;
  final bool muted;
  final String? errorMessage;

  bool get isPlaying => status == MusicStatus.playing;
  bool get isLoading => status == MusicStatus.loading;
  bool get hasError => status == MusicStatus.error;
}
