import 'package:cloud_firestore/cloud_firestore.dart';

class WeddingComment {
  final String? fullName;
  final String? comment;
  final String? avatarSeed;
  final Timestamp? createdAt;
  final String? id;

  const WeddingComment({
    this.fullName,
    this.comment,
    this.avatarSeed,
    this.createdAt,
    this.id,
  });

  factory WeddingComment.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data();
      if (data is! Map<String, dynamic>) {
        return WeddingComment(id: doc.id);
      }
      return WeddingComment(
        id: doc.id,
        fullName: data['fullName'] is String
            ? data['fullName'] as String
            : null,
        comment: data['comment'] is String ? data['comment'] as String : null,
        avatarSeed: data['avatarSeed'] is String
            ? data['avatarSeed'] as String
            : null,
        createdAt: data['createdAt'] is Timestamp
            ? data['createdAt'] as Timestamp
            : null,
      );
    } catch (_) {
      return WeddingComment(id: doc.id);
    }
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'fullName': fullName?.trim() ?? '',
      'comment': comment?.trim() ?? '',
      'avatarSeed': avatarSeed?.trim().isNotEmpty == true
          ? avatarSeed?.trim()
          : (fullName?.trim().isNotEmpty == true ? fullName?.trim() : 'Guest'),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
