import 'chat_enums.dart';

/// A locally authoritative chat message.
///
/// The identifier is the idempotency key used by persistence and, in later
/// phases, synchronization. User-authored content is never silently replaced
/// by a duplicate or remote write.
class Message {
  const Message({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.deviceId,
    required this.role,
    required this.content,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.modelSource,
    required this.modelIdentifier,
    required this.syncStatus,
    this.revision = 0,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String conversationId;
  final String deviceId;
  final MessageRole role;
  final String content;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final ModelSource modelSource;
  final String? modelIdentifier;
  final SyncStatus syncStatus;

  /// Optimistic-concurrency value; incremented by local status transitions.
  final int revision;

  /// Non-null when the message is a tombstone.
  final DateTime? deletedAtUtc;

  bool get isDeleted => deletedAtUtc != null;

  Message copyWith({
    String? id,
    String? userId,
    String? conversationId,
    String? deviceId,
    MessageRole? role,
    String? content,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    ModelSource? modelSource,
    String? modelIdentifier,
    bool clearModelIdentifier = false,
    SyncStatus? syncStatus,
    int? revision,
    DateTime? deletedAtUtc,
    bool clearDeletedAt = false,
  }) {
    return Message(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      deviceId: deviceId ?? this.deviceId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      modelSource: modelSource ?? this.modelSource,
      modelIdentifier: clearModelIdentifier
          ? null
          : (modelIdentifier ?? this.modelIdentifier),
      syncStatus: syncStatus ?? this.syncStatus,
      revision: revision ?? this.revision,
      deletedAtUtc: clearDeletedAt ? null : (deletedAtUtc ?? this.deletedAtUtc),
    );
  }
}
