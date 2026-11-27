import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

import '../domain/entities/chat_enums.dart';
import '../domain/entities/outbox_operation.dart';
import '../domain/repositories/outbox_repository.dart';
import 'app_database.dart';
import 'mappers.dart';
import 'schema.dart';

class SqliteOutboxRepository implements OutboxRepository {
  SqliteOutboxRepository(this._database);

  final AppDatabase _database;

  @override
  Future<bool> enqueue(OutboxOperation operation) async {
    final db = await _database.database;
    final inserted = await db.insert(
      DbTables.outbox,
      outboxToMap(operation),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return inserted > 0;
  }

  @override
  Future<OutboxOperation?> claimNext({DateTime? nowUtc}) async {
    final db = await _database.database;
    final now = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    final nowMillis = utcToMillis(now);

    return db.transaction((txn) async {
      final rows = await txn.query(
        DbTables.outbox,
        where: '${DbColumns.status} IN (?, ?) '
            'AND ${DbColumns.nextAttemptAtUtc} <= ?',
        whereArgs: [
          OutboxStatus.pending.name,
          OutboxStatus.failed.name,
          nowMillis,
        ],
        orderBy: '${DbColumns.createdAtUtc} ASC, ${DbColumns.operationId} ASC',
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final current = outboxFromMap(rows.first);
      final attempts = current.attempts + 1;
      await txn.update(
        DbTables.outbox,
        {
          DbColumns.status: OutboxStatus.processing.name,
          DbColumns.attempts: attempts,
          DbColumns.lastAttemptAtUtc: nowMillis,
          DbColumns.updatedAtUtc: nowMillis,
        },
        where: '${DbColumns.operationId} = ?',
        whereArgs: [current.operationId],
      );

      return current.copyWith(
        status: OutboxStatus.processing,
        attempts: attempts,
        lastAttemptAtUtc: now,
        updatedAtUtc: now,
      );
    });
  }

  @override
  Future<List<OutboxOperation>> list({
    OutboxStatus? status,
    int? limit,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      DbTables.outbox,
      where: status == null ? null : '${DbColumns.status} = ?',
      whereArgs: status == null ? null : [status.name],
      orderBy: '${DbColumns.createdAtUtc} ASC, ${DbColumns.operationId} ASC',
      limit: limit,
    );
    return rows.map(outboxFromMap).toList(growable: false);
  }

  @override
  Future<OutboxOperation?> findById(String operationId) async {
    final db = await _database.database;
    final rows = await db.query(
      DbTables.outbox,
      where: '${DbColumns.operationId} = ?',
      whereArgs: [operationId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return outboxFromMap(rows.first);
  }

  @override
  Future<void> markCompleted(String operationId, {DateTime? nowUtc}) async {
    final db = await _database.database;
    final now = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    await db.update(
      DbTables.outbox,
      {
        DbColumns.status: OutboxStatus.completed.name,
        DbColumns.nextAttemptAtUtc: utcToMillis(now),
        DbColumns.updatedAtUtc: utcToMillis(now),
      },
      where: '${DbColumns.operationId} = ?',
      whereArgs: [operationId],
    );
  }

  @override
  Future<void> markFailed(
    String operationId,
    String error, {
    DateTime? nextAttemptAtUtc,
    DateTime? nowUtc,
  }) async {
    final db = await _database.database;
    final now = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    await db.transaction((txn) async {
      final rows = await txn.query(
        DbTables.outbox,
        where: '${DbColumns.operationId} = ?',
        whereArgs: [operationId],
        limit: 1,
      );
      if (rows.isEmpty) return;

      final current = outboxFromMap(rows.first);
      final exhausted = current.attempts >= current.maxAttempts;
      final backoffSeconds = 1 << math.min(current.attempts, 6);
      final nextAttempt = (nextAttemptAtUtc ??
              now.add(Duration(seconds: backoffSeconds)))
          .toUtc();

      await txn.update(
        DbTables.outbox,
        {
          DbColumns.status: exhausted
              ? OutboxStatus.deadLetter.name
              : OutboxStatus.failed.name,
          DbColumns.lastError: error,
          DbColumns.nextAttemptAtUtc: utcToMillis(nextAttempt),
          DbColumns.updatedAtUtc: utcToMillis(now),
        },
        where: '${DbColumns.operationId} = ?',
        whereArgs: [operationId],
      );
    });
  }

  @override
  Future<int> recoverStaleProcessing({
    required DateTime staleBeforeUtc,
    DateTime? nowUtc,
  }) async {
    final db = await _database.database;
    final now = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    return db.update(
      DbTables.outbox,
      {
        DbColumns.status: OutboxStatus.pending.name,
        DbColumns.nextAttemptAtUtc: utcToMillis(now),
        DbColumns.updatedAtUtc: utcToMillis(now),
      },
      where: '${DbColumns.status} = ? AND COALESCE('
          '${DbColumns.lastAttemptAtUtc}, ${DbColumns.updatedAtUtc}) < ?',
      whereArgs: [
        OutboxStatus.processing.name,
        utcToMillis(staleBeforeUtc),
      ],
    );
  }

  @override
  Future<int> retry(String operationId, {DateTime? nowUtc}) async {
    final db = await _database.database;
    final now = nowUtc?.toUtc() ?? DateTime.now().toUtc();
    final current = await findById(operationId);
    if (current == null ||
        (current.status != OutboxStatus.failed &&
            current.status != OutboxStatus.deadLetter)) {
      return 0;
    }

    return db.update(
      DbTables.outbox,
      {
        DbColumns.status: OutboxStatus.pending.name,
        DbColumns.attempts: 0,
        DbColumns.nextAttemptAtUtc: utcToMillis(now),
        DbColumns.lastError: null,
        DbColumns.updatedAtUtc: utcToMillis(now),
      },
      where: '${DbColumns.operationId} = ?',
      whereArgs: [operationId],
    );
  }

  @override
  Future<int> count({OutboxStatus? status}) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DbTables.outbox}'
      '${status == null ? '' : ' WHERE ${DbColumns.status} = ?'}',
      status == null ? null : [status.name],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
