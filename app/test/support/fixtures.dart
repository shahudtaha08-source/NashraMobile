import 'package:meri_nashra/domain/entities/chat_enums.dart';
import 'package:meri_nashra/domain/entities/conversation.dart';
import 'package:meri_nashra/domain/entities/message.dart';
import 'package:meri_nashra/domain/entities/outbox_operation.dart';

final DateTime createdAt = DateTime.utc(2026, 11, 27, 10, 0);
final DateTime updatedAt = DateTime.utc(2026, 11, 27, 10, 1);

Conversation testConversation({
  String id = 'conversation-1',
  String userId = 'user-1',
  String title = 'General',
  DateTime? created,
  DateTime? updated,
  bool isDeleted = false,
  DateTime? deletedAt,
}) {
  return Conversation(
    id: id,
    userId: userId,
    title: title,
    createdAtUtc: created ?? createdAt,
    updatedAtUtc: updated ?? updatedAt,
    isDeleted: isDeleted,
    deletedAtUtc: deletedAt,
  );
}

Message testMessage({
  String id = 'message-1',
  String userId = 'user-1',
  String conversationId = 'conversation-1',
  String deviceId = 'device-1',
  MessageRole role = MessageRole.user,
  String content = 'Hello Nashra',
  DateTime? created,
  DateTime? updated,
  ModelSource modelSource = ModelSource.unknown,
  String? modelIdentifier,
  SyncStatus syncStatus = SyncStatus.pending,
  int revision = 0,
  DateTime? deletedAt,
}) {
  return Message(
    id: id,
    userId: userId,
    conversationId: conversationId,
    deviceId: deviceId,
    role: role,
    content: content,
    createdAtUtc: created ?? createdAt,
    updatedAtUtc: updated ?? updatedAt,
    modelSource: modelSource,
    modelIdentifier: modelIdentifier,
    syncStatus: syncStatus,
    revision: revision,
    deletedAtUtc: deletedAt,
  );
}

OutboxOperation testOperation({
  String operationId = 'operation-1',
  String idempotencyKey = 'message-1:upsert',
  OutboxEntityType entityType = OutboxEntityType.message,
  String entityId = 'message-1',
  OutboxOperationType operationType = OutboxOperationType.upsert,
  String? conversationId = 'conversation-1',
  String payloadJson = '{"id":"message-1"}',
  OutboxStatus status = OutboxStatus.pending,
  int attempts = 0,
  int maxAttempts = 5,
  DateTime? nextAttemptAt,
  String? lastError,
  DateTime? created,
  DateTime? updated,
  DateTime? lastAttemptAt,
}) {
  return OutboxOperation(
    operationId: operationId,
    idempotencyKey: idempotencyKey,
    entityType: entityType,
    entityId: entityId,
    operationType: operationType,
    conversationId: conversationId,
    payloadJson: payloadJson,
    status: status,
    attempts: attempts,
    maxAttempts: maxAttempts,
    nextAttemptAtUtc: nextAttemptAt ?? createdAt,
    lastError: lastError,
    createdAtUtc: created ?? createdAt,
    updatedAtUtc: updated ?? updatedAt,
    lastAttemptAtUtc: lastAttemptAt,
  );
}
