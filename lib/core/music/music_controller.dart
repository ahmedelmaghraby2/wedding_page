import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum MusicStatus { idle, loading, playing, paused, error }

/// Owns the single, app-wide wedding-song player.
///
/// A [MusicController] is created once (in `main`) and shared through the
/// widget tree, so scrolling, locale changes and any other rebuilds never
/// create a second player or restart the song.
class MusicController extends ChangeNotifier {
  MusicController({this.assetPath = ''});

  /// Path relative to the `assets/` folder (declared in pubspec). Supplied by
  /// `main` from the active `WeddingConfig.musicAssetSource`.
  final String assetPath;

  AudioPlayer? _player;
  bool _initialized = false;
  bool _disposed = false;
  bool _muted = false;
  MusicStatus _status = MusicStatus.idle;
  String? _errorMessage;

  MusicStatus get status => _status;
  bool get isPlaying => _status == MusicStatus.playing;
  bool get isMuted => _muted;
  bool get hasError => _status == MusicStatus.error;
  String? get errorMessage => _errorMessage;

  /// Prepares the player (creates the single [AudioPlayer], sets loop mode and
  /// loads the source) without starting playback. Call once after the first
  /// frame so the later "Open Invitation" gesture can call `resume()` quickly,
  /// which browsers are far more likely to honour.
  Future<void> warmUp() async {
    try {
      await _ensureInitialized();
    } catch (_) {
      // Loading errors surface on play(); ignore here so the page still loads.
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized || _disposed) return;
    final player = AudioPlayer();
    _player = player;
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(_muted ? 0 : 0.85);
    await player.setSource(AssetSource(assetPath));
    player.onPlayerStateChanged.listen((state) {
      if (_disposed) return;
      switch (state) {
        case PlayerState.playing:
          _setStatus(MusicStatus.playing);
          break;
        case PlayerState.paused:
          if (_status != MusicStatus.error) _setStatus(MusicStatus.paused);
          break;
        case PlayerState.stopped:
        case PlayerState.completed:
        case PlayerState.disposed:
          break;
      }
    });
    _initialized = true;
  }

  /// Starts playback. Must be called from a user gesture on first run to
  /// satisfy browser autoplay policies.
  Future<void> play() async {
    if (_disposed) return;
    _errorMessage = null;
    _setStatus(MusicStatus.loading);
    try {
      await _ensureInitialized();
      await _player?.resume();
      _setStatus(MusicStatus.playing);
    } catch (error) {
      _errorMessage = error.toString();
      _setStatus(MusicStatus.error);
    }
  }

  Future<void> pause() async {
    if (_disposed) return;
    try {
      await _player?.pause();
      _setStatus(MusicStatus.paused);
    } catch (_) {
      // Ignore transient pause failures.
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    try {
      await _player?.setVolume(_muted ? 0 : 0.85);
    } catch (_) {
      // Ignore volume failures; state still reflects intent.
    }
    notifyListeners();
  }

  void _setStatus(MusicStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _player?.dispose();
    _player = null;
    super.dispose();
  }
}
