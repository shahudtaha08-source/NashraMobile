import '../entities/chat_enums.dart';
import '../entities/message.dart';
import '../entities/outbox_operation.dart';

abstract interface class MessageRepository {
  /// Inserts a message without overwriting an existing row with the same ID.
  Future<bool> insert(Message message);

  /// Writes the message and its outbox operation in one local transaction.
  ///
  /// Returns `false` when the message ID already exists; no duplicate outbox
  /// operation is created in that case.
  Future<bool> saveLocally(Message message, OutboxOperation operation);

  Future<Message?> findById(String id);

  Future<List<Message>> listForConversation(
    String conversationId, {
    bool includeDeleted = false,
  });

  Future<int> updateSyncStatus(
    String messageId,
    SyncStatus status, {
    DateTime? updatedAtUtc,
  });

  Future<int> markDeleted(
    String messageId, {
    DateTime? deletedAtUtc,
  });
}
