import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/config/wedding_config.dart';

void main() {
  group('WeddingConfig.fromJson', () {
    test('parses a minimal valid config', () {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test-couple',
        'title': {'en': 'Test Couple'},
        'developer': 'Test Dev',
        'groom': 'Ahmed',
        'bride': 'Sara',
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test-couple/hero.jpg',
        'musicSource': 'assets/weddings/test-couple/song.mp3',
        'caption': {'en': 'Welcome'},
      });

      expect(config.weddingId, 'test-couple');
      expect(config.pageTitle, 'Test Couple');
      expect(config.monogramLabel, 'AS');
      expect(config.developer.resolve('en'), 'Test Dev');
      expect(config.groom.resolve('en'), 'Ahmed');
      expect(config.bride.resolve('en'), 'Sara');
      expect(config.groom.resolve('ar'), 'Ahmed', reason: 'falls back to en');
      expect(config.bride.resolve('ar'), 'Sara', reason: 'falls back to en');
      expect(config.showCountdown, isTrue, reason: 'defaults to true');
      expect(config.showComments, isTrue, reason: 'defaults to true');
      expect(config.hasStory, isFalse);
      expect(config.galleryImages, [config.heroImage]);
      expect(config.musicAssetSource, 'weddings/test-couple/song.mp3');
    });

    test('story and booleans are respected when provided', () {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test-couple',
        'title': {'en': 'Test Couple'},
        'developer': 'Test Dev',
        'groom': 'Ahmed',
        'bride': 'Sara',
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test-couple/hero.jpg',
        'musicSource': 'assets/weddings/test-couple/song.mp3',
        'caption': {'en': 'Welcome'},
        'story': {
          'en': ['Once upon a time.'],
        },
        'gallery': [
          'assets/weddings/test-couple/a.jpg',
          'assets/weddings/test-couple/b.jpg',
        ],
        'showCountdown': false,
        'showComments': false,
      });

      expect(config.showCountdown, isFalse);
      expect(config.showComments, isFalse);
      expect(config.hasStory, isTrue);
      expect(config.storyFor('ar'), config.storyFor('en'));
      expect(config.gallery.length, 2);
    });

    test('developer, groom and bride accept localized maps', () {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test-couple',
        'title': {'en': 'Test Couple'},
        'developer': {'en': 'Studio', 'ar': 'استوديو'},
        'groom': {'en': 'Ahmed', 'ar': 'أحمد'},
        'bride': {'en': 'Sara', 'ar': 'سارة'},
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test-couple/hero.jpg',
        'musicSource': 'assets/weddings/test-couple/song.mp3',
        'caption': {'en': 'Welcome'},
      });

      expect(config.developer.resolve('en'), 'Studio');
      expect(config.developer.resolve('ar'), 'استوديو');
      expect(config.groom.resolve('en'), 'Ahmed');
      expect(config.groom.resolve('ar'), 'أحمد');
      expect(config.bride.resolve('en'), 'Sara');
      expect(config.bride.resolve('ar'), 'سارة');
      expect(config.monogramLabel, 'AS', reason: 'monogram stays Latin');
      expect(config.pageTitle, 'Test Couple');
      expect(config.pageTitleFor('ar'), 'Test Couple');
    });

    test('plain-string developer/groom/bride stay backward compatible', () {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test-couple',
        'title': {'en': 'Test Couple'},
        'developer': 'Test Dev',
        'groom': 'Ahmed',
        'bride': 'Sara',
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test-couple/hero.jpg',
        'musicSource': 'assets/weddings/test-couple/song.mp3',
        'caption': {'en': 'Welcome'},
      });

      expect(config.developer.resolve('en'), 'Test Dev');
      expect(config.groom.resolve('en'), 'Ahmed');
      expect(config.bride.resolve('en'), 'Sara');
      expect(config.groom.resolve('ar'), 'Ahmed', reason: 'no ar value yet');
      expect(config.monogramLabel, 'AS');
      expect(config.pageTitle, 'Test Couple');
    });

    test('resolves groom, bride and developer per locale', () {
      final config = WeddingConfig.fromJson({
        'weddingId': 'test-couple',
        'title': {'en': 'Test Couple'},
        'developer': {'en': 'Studio', 'ar': 'استوديو'},
        'groom': {'en': 'Ahmed', 'ar': 'أحمد'},
        'bride': {'en': 'Sara', 'ar': 'سارة'},
        'event': {
          'countdownDateTime': '2027-01-01T20:00:00+02:00',
          'display': {
            'date': {'en': '01/01/2027'},
            'time': {'en': '8:00 PM'},
            'venue': {'en': 'Halla'},
            'city': {'en': 'Cairo'},
          },
          'mapsUrl': 'https://maps.example.com/1',
        },
        'heroImage': 'assets/weddings/test-couple/hero.jpg',
        'musicSource': 'assets/weddings/test-couple/song.mp3',
        'caption': {'en': 'Welcome'},
      });

      expect(config.groom.resolve('ar'), 'أحمد');
      expect(config.bride.resolve('ar'), 'سارة');
      expect(config.developer.resolve('ar'), 'استوديو');
    });

    test('rejects an invalid config and reports every issue', () {
      expect(
        () => WeddingConfig.fromJson({
          'weddingId': 'Bad_ID!',
          'event': {
            'display': {'mapsUrl': 'not-a-url'},
          },
        }),
        throwsA(
          isA<ConfigValidationException>().having(
            (e) => e.issues.length,
            'issue count',
            greaterThan(3),
          ),
        ),
      );
    });

    test('rejects non-ISO date strings', () {
      expect(
        () => WeddingConfig.fromJson({
          'weddingId': 'good-id',
          'title': {'en': 'x'},
          'groom': 'a',
          'bride': 'b',
          'event': {
            'countdownDateTime': 'tomorrowish',
            'display': {
              'date': {'en': '1'},
              'time': {'en': '2'},
              'venue': {'en': 'v'},
              'city': {'en': 'c'},
            },
            'mapsUrl': 'https://x.example/1',
          },
          'heroImage': 'assets/weddings/good-id/hero.jpg',
          'musicSource': 'assets/weddings/good-id/song.mp3',
          'caption': {'en': 'c'},
        }),
        throwsA(
          isA<ConfigValidationException>().having(
            (e) => e.issues.any((i) => i.contains('countdownDateTime')),
            'mentions countdownDateTime',
            isTrue,
          ),
        ),
      );
    });
  });

  group('shipped config files', () {
    test('config/wedding_config.json is valid', () {
      final source = File('config/wedding_config.json').readAsStringSync();
      final config = WeddingConfig.fromJsonString(source);
      expect(config.weddingId, 'ahmed-aya');
    });

    test('config/wedding_demo.json is schema-valid', () {
      final source = File('config/wedding_demo.json').readAsStringSync();
      final demo = WeddingConfig.fromJsonString(source);
      expect(demo.weddingId, startsWith('demo-'));
    });

    test('config files use distinct weddingIds', () {
      final ids = ['config/wedding_config.json', 'config/wedding_demo.json']
          .map((path) {
            final source = File(path).readAsStringSync();
            return (jsonDecode(source) as Map<String, dynamic>)['weddingId']
                as String;
          })
          .toSet();
      expect(ids.length, 2);
    });
  });
}
