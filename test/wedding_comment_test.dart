import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/data/wedding_comment_mapper.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

void main() {
  group('WeddingComment', () {
    test('has safe defaults', () {
      const comment = WeddingComment();
      expect(comment.id, isNull);
      expect(comment.fullName, '');
      expect(comment.comment, '');
      expect(comment.avatarSeed, '');
      expect(comment.weddingId, '');
      expect(comment.createdAt, isNull);
    });

    test('copyWith overrides only the given fields', () {
      final comment = WeddingComment(fullName: 'Jane', comment: 'Hi');
      final copy = comment.copyWith(comment: 'Hello');
      expect(copy.fullName, 'Jane');
      expect(copy.comment, 'Hello');
      expect(copy.avatarSeed, '');
    });
  });

  group('WeddingCommentMapper.toCreateMap', () {
    test('trims values and falls back avatarSeed to the name', () {
      final map = WeddingCommentMapper.toCreateMap(
        const WeddingComment(fullName: '  John  ', comment: '  Hi  '),
      );
      expect(map['fullName'], 'John');
      expect(map['comment'], 'Hi');
      expect(map['avatarSeed'], 'John');
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('keeps an explicit avatarSeed', () {
      final map = WeddingCommentMapper.toCreateMap(
        const WeddingComment(fullName: 'Jane', avatarSeed: 'J'),
      );
      expect(map['avatarSeed'], 'J');
    });

    test('defaults avatarSeed to Guest when both are empty', () {
      final map = WeddingCommentMapper.toCreateMap(const WeddingComment());
      expect(map['avatarSeed'], 'Guest');
    });

    test('applies the scoped weddingId override', () {
      final map = WeddingCommentMapper.toCreateMap(
        const WeddingComment(weddingId: 'ignored'),
        weddingId: 'ahmed-aya',
      );
      expect(map['weddingId'], 'ahmed-aya');
    });
  });
}
