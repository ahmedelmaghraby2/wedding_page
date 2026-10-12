import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';

/// Translation between the pure [WeddingComment] domain model and Firestore
/// documents. Kept in the data layer so the domain model stays storage-free.
class WeddingCommentMapper {
  WeddingCommentMapper._();

  static WeddingComment fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return WeddingComment(id: doc.id);
    return WeddingComment(
      id: doc.id,
      fullName: _stringOrEmpty(data['fullName']),
      comment: _stringOrEmpty(data['comment']),
      avatarSeed: _stringOrEmpty(data['avatarSeed'], fallback: 'Guest'),
      weddingId: _stringOrEmpty(data['weddingId']),
      createdAt: _dateOrNull(data['createdAt']),
    );
  }

  static Map<String, dynamic> toCreateMap(
    WeddingComment comment, {
    String? weddingId,
  }) {
    final name = comment.fullName.trim();
    final seed = comment.avatarSeed.trim();
    final scopedId = (weddingId ?? comment.weddingId).trim();
    return {
      'fullName': name,
      'comment': comment.comment.trim(),
      'avatarSeed': seed.isNotEmpty
          ? seed
          : (name.isNotEmpty ? name : 'Guest'),
      'weddingId': scopedId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String _stringOrEmpty(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static DateTime? _dateOrNull(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
