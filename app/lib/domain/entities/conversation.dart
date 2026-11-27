class Conversation {
  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.isDeleted = false,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  final DateTime? deletedAtUtc;

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    bool? isDeleted,
    DateTime? deletedAtUtc,
    bool clearDeletedAt = false,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAtUtc: clearDeletedAt ? null : (deletedAtUtc ?? this.deletedAtUtc),
    );
  }
}
