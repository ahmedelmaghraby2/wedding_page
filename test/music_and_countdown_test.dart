import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/features/wedding/presentation/sections/countdown_section.dart';

void main() {
  group('wedding instant', () {
    test('represents 20:00 Cairo (UTC+3) as 17:00 UTC', () {
      expect(weddingInstant.isUtc, isTrue);
      expect(weddingInstant, DateTime.utc(2026, 10, 16, 17, 0, 0));
    });

    test('difference to a known instant is positive before the event', () {
      final now = DateTime.utc(2026, 10, 9, 12, 0, 0);
      expect(weddingInstant.difference(now).inDays, 7);
    });
  });

  group('MusicController', () {
    test('starts idle, unmuted and not playing', () {
      final controller = MusicController();
      expect(controller.status, MusicStatus.idle);
      expect(controller.isPlaying, isFalse);
      expect(controller.isMuted, isFalse);
      controller.dispose();
    });

    test('toggleMute flips the muted flag without a live player', () async {
      final controller = MusicController();
      await controller.toggleMute();
      expect(controller.isMuted, isTrue);
      await controller.toggleMute();
      expect(controller.isMuted, isFalse);
      controller.dispose();
    });
  });
}
