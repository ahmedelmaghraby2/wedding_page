import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/data/comment_access_code.dart';

void main() {
  group('CommentAccessCode.generate', () {
    test('always contains upper, lower, digit and special characters', () {
      for (var seed = 0; seed < 200; seed++) {
        final code = CommentAccessCode.generate(random: Random(seed));
        expect(code.length, CommentAccessCode.length, reason: code);
        expect(
          code.split('').any(CommentAccessCode.upper.contains),
          isTrue,
          reason: code,
        );
        expect(
          code.split('').any(CommentAccessCode.lower.contains),
          isTrue,
          reason: code,
        );
        expect(
          code.split('').any(CommentAccessCode.digits.contains),
          isTrue,
          reason: code,
        );
        expect(
          code.split('').any(CommentAccessCode.special.contains),
          isTrue,
          reason: code,
        );
      }
    });
  });

  group('CommentAccessCode.validate', () {
    test('rejects empty input', () {
      expect(CommentAccessCode.validate(''), AccessCodeIssue.empty);
    });

    test('treats whitespace-only input as empty', () {
      expect(CommentAccessCode.validate('    '), AccessCodeIssue.empty);
    });

    test('rejects short codes', () {
      expect(CommentAccessCode.validate('Ab1!'), AccessCodeIssue.tooShort);
    });

    test('accepts a valid code', () {
      expect(CommentAccessCode.validate('A7m#K2p!'), isNull);
    });
  });

  group('CommentAccessCode.digest', () {
    test('is a 64 character lowercase hex string', () {
      final digest = CommentAccessCode.digest('A7m#K2p!');
      expect(digest.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(digest), isTrue);
    });

    test('is deterministic', () {
      expect(
        CommentAccessCode.digest('A7m#K2p!'),
        CommentAccessCode.digest('A7m#K2p!'),
      );
    });

    test('changes when the code changes', () {
      expect(
        CommentAccessCode.digest('A7m#K2p!'),
        isNot(CommentAccessCode.digest('A7m#K2p?')),
      );
    });

    test('ignores surrounding whitespace', () {
      expect(
        CommentAccessCode.digest('  A7m#K2p!  '),
        CommentAccessCode.digest('A7m#K2p!'),
      );
    });
  });

  group('CommentAccessCode.newNonce', () {
    test('produces 32 hex characters', () {
      final nonce = CommentAccessCode.newNonce(Random(1));
      expect(nonce.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(nonce), isTrue);
    });

    test('produces distinct values', () {
      expect(
        CommentAccessCode.newNonce(Random(1)),
        isNot(CommentAccessCode.newNonce(Random(2))),
      );
    });
  });
}
