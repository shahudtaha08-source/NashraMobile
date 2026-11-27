import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/domain/entities/chat_enums.dart';
import 'package:meri_nashra/persistence/outbox_repository.dart';
import 'package:sqflite/sqflite.dart' show inMemoryDatabasePath;

import '../support/fixtures.dart';
import '../support/test_database.dart';

void main() {
  setUpAll(initializeSqliteFfi);

  test('enqueue is idempotent for operation IDs and idempotency keys', () async {
    final database = makeTestDatabase(inMemoryDatabasePath);
    await database.open();
    addTearDown(database.close);
    final repository = SqliteOutboxRepository(database);

    expect(await repository.enqueue(testOperation()), isTrue);
    expect(await repository.enqueue(testOperation()), isFalse);
    expect(
      await repository.enqueue(testOperation(operationId: 'operation-2')),
      isFalse,
      reason: 'Duplicate idempotency key must not create a second operation.',
    );

    expect(await repository.count(), 1);
  });

  test('claim, failure, retry and completion track attempts safely', () async {
    final database = makeTestDatabase(inMemoryDatabasePath);
    await database.open();
    addTearDown(database.close);
    final repository = SqliteOutboxRepository(database);
    await repository.enqueue(testOperation());

    final now = DateTime.utc(2026, 11, 27, 12, 0);
    final firstClaim = await repository.claimNext(nowUtc: now);
    expect(firstClaim, isNotNull);
    expect(firstClaim!.status, OutboxStatus.processing);
    expect(firstClaim.attempts, 1);
    expect(firstClaim.lastAttemptAtUtc, now);

    await repository.markFailed(
      firstClaim.operationId,
      'offline',
      nextAttemptAtUtc: now,
      nowUtc: now,
    );
    var stored = await repository.findById(firstClaim.operationId);
    expect(stored!.status, OutboxStatus.failed);
    expect(stored.lastError, 'offline');
    expect(stored.attempts, 1);

    final secondClaim = await repository.claimNext(nowUtc: now);
    expect(secondClaim, isNotNull);
    expect(secondClaim!.attempts, 2);

    await repository.markCompleted(secondClaim.operationId, nowUtc: now);
    stored = await repository.findById(secondClaim.operationId);
    expect(stored!.status, OutboxStatus.completed);
    expect(await repository.claimNext(nowUtc: now), isNull);
  });

  test('exhausted operations move to dead letter instead of retrying forever',
      () async {
    final database = makeTestDatabase(inMemoryDatabasePath);
    await database.open();
    addTearDown(database.close);
    final repository = SqliteOutboxRepository(database);
    await repository.enqueue(testOperation(maxAttempts: 1));

    final claimed = await repository.claimNext();
    expect(claimed, isNotNull);
    await repository.markFailed(claimed!.operationId, 'persistent failure');

    final stored = await repository.findById(claimed.operationId);
    expect(stored!.status, OutboxStatus.deadLetter);
    expect(await repository.claimNext(), isNull);

    final now = DateTime.utc(2026, 11, 27, 12, 30);
    expect(await repository.retry(claimed.operationId, nowUtc: now), 1);
    expect(
      (await repository.findById(claimed.operationId))!.status,
      OutboxStatus.pending,
    );
  });

  test('processing operations are recovered after an interrupted run', () async {
    final directory = await createTestDirectory();
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    final path = databasePath(directory, 'outbox_recovery.db');
    final firstRun = makeTestDatabase(path);
    await firstRun.open();
    final firstRepository = SqliteOutboxRepository(firstRun);
    await firstRepository.enqueue(testOperation());

    final claimedAt = DateTime.utc(2026, 11, 27, 13, 0);
    final claimed = await firstRepository.claimNext(nowUtc: claimedAt);
    expect(claimed!.status, OutboxStatus.processing);
    await firstRun.close();

    final secondRun = makeTestDatabase(path);
    await secondRun.open();
    addTearDown(secondRun.close);
    final recoveredRepository = SqliteOutboxRepository(secondRun);

    expect(
      await recoveredRepository.recoverStaleProcessing(
        staleBeforeUtc: claimedAt.add(const Duration(seconds: 1)),
        nowUtc: claimedAt.add(const Duration(seconds: 2)),
      ),
      1,
    );

    final recovered = await recoveredRepository.findById(claimed.operationId);
    expect(recovered!.status, OutboxStatus.pending);

    final reclaimed = await recoveredRepository.claimNext(
      nowUtc: claimedAt.add(const Duration(seconds: 2)),
    );
    expect(reclaimed, isNotNull);
    expect(reclaimed!.operationId, claimed.operationId);
  });
}
