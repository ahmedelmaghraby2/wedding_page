import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/data/wedding_comment.dart';

void main() {
  group('WeddingComment', () {
    test('parses valid data correctly', () {
      final comment = WeddingComment(
        fullName: 'John Doe',
        comment: 'Congratulations!',
        avatarSeed: 'John Doe',
      );
      expect(comment.fullName, 'John Doe');
      expect(comment.comment, 'Congratulations!');
    });

    test('handles null values defensively', () {
      const comment = WeddingComment();
      expect(comment.fullName, null);
      expect(comment.comment, null);
    });

    test('toMapForCreate trims values', () {
      final comment = WeddingComment(
        fullName: '  John  ',
        comment: '  Hi  ',
      );
      final map = comment.toMapForCreate();
      expect(map['fullName'], 'John');
      expect(map['comment'], 'Hi');
    });

    test('toMapForCreate sets default avatar seed', () {
      final comment = WeddingComment(fullName: 'Jane');
      final map = comment.toMapForCreate();
      expect(map['avatarSeed'], 'Jane');
    });

    test('toMapForCreate handles empty values', () {
      const comment = WeddingComment();
      final map = comment.toMapForCreate();
      expect(map['fullName'], '');
      expect(map['comment'], '');
      expect(map['avatarSeed'], 'Guest');
      expect(map['weddingId'], '');
    });

    test('toMapForCreate keeps a provided weddingId', () {
      const comment = WeddingComment(weddingId: 'ahmed-aya');
      final map = comment.toMapForCreate();
      expect(map['weddingId'], 'ahmed-aya');
    });
  });
}
