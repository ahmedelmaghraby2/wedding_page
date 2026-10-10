import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/config/wedding_config.dart';
import 'package:wedding/core/music/music_controller.dart';

void main() {
  group('wedding instant (config/wedding_config.json)', () {
    late WeddingConfig config;

    setUpAll(() {
      final source = File('config/wedding_config.json').readAsStringSync();
      config = WeddingConfig.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
    });

    test('loads and parses the default wedding config', () {
      expect(config.weddingId, 'ahmed-aya');
      expect(config.groom.resolve('en'), isNotEmpty);
      expect(config.groom.resolve('ar'), isNotEmpty);
      expect(config.bride.resolve('en'), isNotEmpty);
      expect(config.bride.resolve('ar'), isNotEmpty);
      expect(config.showCountdown, isTrue);
      expect(config.showComments, isTrue);
    });

    test('represents 20:00 Cairo (UTC+3) as 17:00 UTC', () {
      final instant = config.event.countdownDateTime!;
      expect(instant.isUtc, isTrue);
      expect(instant, DateTime.utc(2026, 10, 28, 17, 0, 0));
    });

    test('difference to a known instant is positive before the event', () {
      final instant = config.event.countdownDateTime!;
      final now = DateTime.now();
      expect(instant.difference(now).inDays, greaterThan(0));
    });

    test('asset keys reference bundled files', () {
      expect(config.heroImage, startsWith('assets/'));
      expect(config.musicAssetSource, startsWith('weddings/'));
      for (final image in config.gallery) {
        expect(image, startsWith('assets/'));
      }
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
