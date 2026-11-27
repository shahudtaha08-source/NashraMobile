import 'chat_enums.dart';

/// A durable local record describing work that still needs to be synchronized.
///
/// [idempotencyKey] is unique, so retrying or replaying an operation cannot
/// create a second logical operation.
class OutboxOperation {
  const OutboxOperation({
    required this.operationId,
    required this.idempotencyKey,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadJson,
    required this.status,
    required this.attempts,
    required this.maxAttempts,
    required this.nextAttemptAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.conversationId,
    this.lastError,
    this.lastAttemptAtUtc,
  });

  final String operationId;
  final String idempotencyKey;
  final OutboxEntityType entityType;
  final String entityId;
  final OutboxOperationType operationType;
  final String? conversationId;
  final String payloadJson;
  final OutboxStatus status;
  final int attempts;
  final int maxAttempts;
  final DateTime nextAttemptAtUtc;
  final String? lastError;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? lastAttemptAtUtc;

  bool get isClaimable =>
      status == OutboxStatus.pending || status == OutboxStatus.failed;

  OutboxOperation copyWith({
    String? operationId,
    String? idempotencyKey,
    OutboxEntityType? entityType,
    String? entityId,
    OutboxOperationType? operationType,
    String? conversationId,
    bool clearConversationId = false,
    String? payloadJson,
    OutboxStatus? status,
    int? attempts,
    int? maxAttempts,
    DateTime? nextAttemptAtUtc,
    String? lastError,
    bool clearLastError = false,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    DateTime? lastAttemptAtUtc,
    bool clearLastAttemptAt = false,
  }) {
    return OutboxOperation(
      operationId: operationId ?? this.operationId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      conversationId: clearConversationId
          ? null
          : (conversationId ?? this.conversationId),
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      nextAttemptAtUtc: nextAttemptAtUtc ?? this.nextAttemptAtUtc,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      lastAttemptAtUtc: clearLastAttemptAt
          ? null
          : (lastAttemptAtUtc ?? this.lastAttemptAtUtc),
    );
  }
}
