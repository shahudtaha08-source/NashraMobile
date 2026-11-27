import '../entities/chat_enums.dart';
import '../entities/outbox_operation.dart';

abstract interface class OutboxRepository {
  /// Inserts an operation idempotently.
  ///
  /// Returns `false` when either the operation ID or idempotency key exists.
  Future<bool> enqueue(OutboxOperation operation);

  /// Atomically claims the oldest due pending/failed operation.
  Future<OutboxOperation?> claimNext({DateTime? nowUtc});

  Future<List<OutboxOperation>> list({
    OutboxStatus? status,
    int? limit,
  });

  Future<OutboxOperation?> findById(String operationId);

  Future<void> markCompleted(String operationId, {DateTime? nowUtc});

  /// Records a failure and schedules the next retry.
  ///
  /// Operations that exhaust [OutboxOperation.maxAttempts] move to
  /// [OutboxStatus.deadLetter] instead of retrying forever.
  Future<void> markFailed(
    String operationId,
    String error, {
    DateTime? nextAttemptAtUtc,
    DateTime? nowUtc,
  });

  /// Returns operations that were left in `processing` by an interrupted run.
  Future<int> recoverStaleProcessing({
    required DateTime staleBeforeUtc,
    DateTime? nowUtc,
  });

  /// Requeues a failed or dead-letter operation for another attempt.
  Future<int> retry(String operationId, {DateTime? nowUtc});

  Future<int> count({OutboxStatus? status});
}
