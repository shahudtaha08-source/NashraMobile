import '../domain/entities/chat_enums.dart';
import '../domain/entities/conversation.dart';
import '../domain/entities/message.dart';
import '../domain/entities/outbox_operation.dart';
import 'schema.dart';

int utcToMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;

int? nullableUtcToMillis(DateTime? value) =>
    value == null ? null : utcToMillis(value);

DateTime millisToUtc(Object? value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value), isUtc: true);
  }
  throw FormatException('Expected UTC milliseconds, got $value');
}

DateTime? nullableMillisToUtc(Object? value) =>
    value == null ? null : millisToUtc(value);

T parseEnum<T extends Enum>(Iterable<T> values, Object? raw, String field) {
  if (raw is! String) {
    throw FormatException('Expected $field to be a String, got $raw');
  }
  for (final value in values) {
    if (value.name == raw) return value;
  }
  throw FormatException('Unknown $field value: $raw');
}

Map<String, Object?> messageToMap(Message message) => {
      DbColumns.id: message.id,
      DbColumns.userId: message.userId,
      DbColumns.conversationId: message.conversationId,
      DbColumns.deviceId: message.deviceId,
      DbColumns.role: message.role.name,
      DbColumns.content: message.content,
      DbColumns.createdAtUtc: utcToMillis(message.createdAtUtc),
      DbColumns.updatedAtUtc: utcToMillis(message.updatedAtUtc),
      DbColumns.modelSource: message.modelSource.name,
      DbColumns.modelIdentifier: message.modelIdentifier,
      DbColumns.syncStatus: message.syncStatus.name,
      DbColumns.revision: message.revision,
      DbColumns.deletedAtUtc: nullableUtcToMillis(message.deletedAtUtc),
    };

Message messageFromMap(Map<String, Object?> map) => Message(
      id: map[DbColumns.id]! as String,
      userId: map[DbColumns.userId]! as String,
      conversationId: map[DbColumns.conversationId]! as String,
      deviceId: map[DbColumns.deviceId]! as String,
      role: parseEnum(MessageRole.values, map[DbColumns.role], 'role'),
      content: map[DbColumns.content]! as String,
      createdAtUtc: millisToUtc(map[DbColumns.createdAtUtc]),
      updatedAtUtc: millisToUtc(map[DbColumns.updatedAtUtc]),
      modelSource: parseEnum(
        ModelSource.values,
        map[DbColumns.modelSource],
        'model_source',
      ),
      modelIdentifier: map[DbColumns.modelIdentifier] as String?,
      syncStatus: parseEnum(
        SyncStatus.values,
        map[DbColumns.syncStatus],
        'sync_status',
      ),
      revision: (map[DbColumns.revision] as int?) ?? 0,
      deletedAtUtc: nullableMillisToUtc(map[DbColumns.deletedAtUtc]),
    );

Map<String, Object?> conversationToMap(Conversation conversation) => {
      DbColumns.id: conversation.id,
      DbColumns.userId: conversation.userId,
      DbColumns.title: conversation.title,
      DbColumns.createdAtUtc: utcToMillis(conversation.createdAtUtc),
      DbColumns.updatedAtUtc: utcToMillis(conversation.updatedAtUtc),
      DbColumns.isDeleted: conversation.isDeleted ? 1 : 0,
      DbColumns.deletedAtUtc: nullableUtcToMillis(conversation.deletedAtUtc),
    };

Conversation conversationFromMap(Map<String, Object?> map) => Conversation(
      id: map[DbColumns.id]! as String,
      userId: map[DbColumns.userId]! as String,
      title: map[DbColumns.title]! as String,
      createdAtUtc: millisToUtc(map[DbColumns.createdAtUtc]),
      updatedAtUtc: millisToUtc(map[DbColumns.updatedAtUtc]),
      isDeleted: (map[DbColumns.isDeleted] as int?) == 1,
      deletedAtUtc: nullableMillisToUtc(map[DbColumns.deletedAtUtc]),
    );

Map<String, Object?> outboxToMap(OutboxOperation operation) => {
      DbColumns.operationId: operation.operationId,
      DbColumns.idempotencyKey: operation.idempotencyKey,
      DbColumns.entityType: operation.entityType.name,
      DbColumns.entityId: operation.entityId,
      DbColumns.operationType: operation.operationType.name,
      DbColumns.conversationId: operation.conversationId,
      DbColumns.payloadJson: operation.payloadJson,
      DbColumns.status: operation.status.name,
      DbColumns.attempts: operation.attempts,
      DbColumns.maxAttempts: operation.maxAttempts,
      DbColumns.nextAttemptAtUtc: utcToMillis(operation.nextAttemptAtUtc),
      DbColumns.lastError: operation.lastError,
      DbColumns.createdAtUtc: utcToMillis(operation.createdAtUtc),
      DbColumns.updatedAtUtc: utcToMillis(operation.updatedAtUtc),
      DbColumns.lastAttemptAtUtc:
          nullableUtcToMillis(operation.lastAttemptAtUtc),
    };

OutboxOperation outboxFromMap(Map<String, Object?> map) => OutboxOperation(
      operationId: map[DbColumns.operationId]! as String,
      idempotencyKey: map[DbColumns.idempotencyKey]! as String,
      entityType: parseEnum(
        OutboxEntityType.values,
        map[DbColumns.entityType],
        'entity_type',
      ),
      entityId: map[DbColumns.entityId]! as String,
      operationType: parseEnum(
        OutboxOperationType.values,
        map[DbColumns.operationType],
        'operation_type',
      ),
      conversationId: map[DbColumns.conversationId] as String?,
      payloadJson: map[DbColumns.payloadJson]! as String,
      status: parseEnum(
        OutboxStatus.values,
        map[DbColumns.status],
        'outbox_status',
      ),
      attempts: (map[DbColumns.attempts] as int?) ?? 0,
      maxAttempts: (map[DbColumns.maxAttempts] as int?) ?? 5,
      nextAttemptAtUtc: millisToUtc(map[DbColumns.nextAttemptAtUtc]),
      lastError: map[DbColumns.lastError] as String?,
      createdAtUtc: millisToUtc(map[DbColumns.createdAtUtc]),
      updatedAtUtc: millisToUtc(map[DbColumns.updatedAtUtc]),
      lastAttemptAtUtc: nullableMillisToUtc(map[DbColumns.lastAttemptAtUtc]),
    );
