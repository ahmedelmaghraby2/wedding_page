import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/domain/countdown.dart';

void main() {
  group('timeUntil', () {
    test('returns the remaining duration for a future target', () {
      final now = DateTime.utc(2026, 1, 1, 12);
      final target = DateTime.utc(2026, 1, 3, 12);
      expect(timeUntil(target, now: now), const Duration(days: 2));
    });

    test('clamps to zero once the target has passed', () {
      final now = DateTime.utc(2026, 1, 3, 12);
      final target = DateTime.utc(2026, 1, 1, 12);
      expect(timeUntil(target, now: now), Duration.zero);
    });

    test('is zero at the exact moment', () {
      final instant = DateTime.utc(2026, 1, 1, 12);
      expect(timeUntil(instant, now: instant), Duration.zero);
    });

    test('is timezone-agnostic', () {
      final now = DateTime.parse('2026-01-01T12:00:00+02:00');
      final target = DateTime.utc(2026, 1, 1, 11);
      expect(timeUntil(target, now: now), const Duration(hours: 1));
    });
  });
}
