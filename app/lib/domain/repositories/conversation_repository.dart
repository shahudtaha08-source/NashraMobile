import '../entities/conversation.dart';
import '../entities/outbox_operation.dart';

abstract interface class ConversationRepository {
  /// Inserts a conversation without overwriting an existing row with the same ID.
  Future<bool> insert(Conversation conversation);

  /// Writes the conversation and its outbox operation in one transaction.
  Future<bool> saveLocally(Conversation conversation, OutboxOperation operation);

  Future<Conversation?> findById(String id);

  Future<List<Conversation>> listForUser(
    String userId, {
    bool includeDeleted = false,
  });

  Future<int> rename(
    String conversationId,
    String title, {
    DateTime? updatedAtUtc,
  });

  Future<int> markDeleted(
    String conversationId, {
    DateTime? deletedAtUtc,
  });
}
