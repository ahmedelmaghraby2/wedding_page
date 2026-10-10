import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

enum AccessCodeIssue { empty, tooShort }

class CommentAccessCode {
  CommentAccessCode._();

  static const int minLength = 8;
  static const int length = 8;

  static const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String digits = '0123456789';
  static const String special = r'!@#$%^&*()-_=+[]{}?.,~';
  static const String _all = '$upper$lower$digits$special';

  static const String _pepper = 'soltan-aya-comments-v1';

  static String generate({Random? random}) {
    final rng = random ?? Random.secure();
    final chars = <String>[
      upper[rng.nextInt(upper.length)],
      lower[rng.nextInt(lower.length)],
      digits[rng.nextInt(digits.length)],
      special[rng.nextInt(special.length)],
    ];
    while (chars.length < length) {
      chars.add(_all[rng.nextInt(_all.length)]);
    }
    for (var i = chars.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return chars.join();
  }

  static String normalize(String rawCode) => rawCode.trim();

  static AccessCodeIssue? validate(String rawCode) {
    final code = normalize(rawCode);
    if (code.isEmpty) return AccessCodeIssue.empty;
    if (code.length < minLength) return AccessCodeIssue.tooShort;
    return null;
  }

  static String digest(String rawCode) {
    final normalized = normalize(rawCode);
    return sha256.convert(utf8.encode('$_pepper$normalized')).toString();
  }

  static String newNonce([Random? random]) {
    final rng = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
