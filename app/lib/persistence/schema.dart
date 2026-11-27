/// Stable names for the local SQLite schema.
abstract final class DbSchema {
  static const int version = 2;
  static const String databaseName = 'nashra_lite.db';
}

abstract final class DbTables {
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String outbox = 'outbox';
}

abstract final class DbColumns {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String conversationId = 'conversation_id';
  static const String deviceId = 'device_id';
  static const String role = 'role';
  static const String title = 'title';
  static const String content = 'content';
  static const String createdAtUtc = 'created_at_utc';
  static const String updatedAtUtc = 'updated_at_utc';
  static const String deletedAtUtc = 'deleted_at_utc';
  static const String isDeleted = 'is_deleted';
  static const String modelSource = 'model_source';
  static const String modelIdentifier = 'model_identifier';
  static const String syncStatus = 'sync_status';
  static const String revision = 'revision';

  static const String operationId = 'operation_id';
  static const String idempotencyKey = 'idempotency_key';
  static const String entityType = 'entity_type';
  static const String entityId = 'entity_id';
  static const String operationType = 'operation_type';
  static const String payloadJson = 'payload_json';
  static const String status = 'status';
  static const String attempts = 'attempts';
  static const String maxAttempts = 'max_attempts';
  static const String nextAttemptAtUtc = 'next_attempt_at_utc';
  static const String lastError = 'last_error';
  static const String lastAttemptAtUtc = 'last_attempt_at_utc';
}
