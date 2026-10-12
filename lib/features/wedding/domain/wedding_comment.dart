/// A guestbook entry as used across the application.
///
/// Deliberately free of any persistence types (`Timestamp`, `FieldValue`,
/// snapshots): the data layer maps to and from Firestore. Fields are non-null
/// with sensible defaults so a partially populated document can never crash the
/// UI. [id] and [createdAt] are null until the entry exists in storage.
class WeddingComment {
  const WeddingComment({
    this.id,
    this.fullName = '',
    this.comment = '',
    this.avatarSeed = '',
    this.weddingId = '',
    this.createdAt,
  });

  final String? id;
  final String fullName;
  final String comment;
  final String avatarSeed;
  final String weddingId;
  final DateTime? createdAt;

  WeddingComment copyWith({
    String? id,
    String? fullName,
    String? comment,
    String? avatarSeed,
    String? weddingId,
    DateTime? createdAt,
  }) {
    return WeddingComment(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      comment: comment ?? this.comment,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      weddingId: weddingId ?? this.weddingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
