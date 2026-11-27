import 'package:sqflite/sqflite.dart';

import '../domain/entities/chat_enums.dart';
import '../domain/entities/message.dart';
import '../domain/entities/outbox_operation.dart';
import '../domain/repositories/message_repository.dart';
import 'app_database.dart';
import 'mappers.dart';
import 'schema.dart';

class SqliteMessageRepository implements MessageRepository {
  SqliteMessageRepository(this._database);

  final AppDatabase _database;

  @override
  Future<bool> insert(Message message) async {
    final db = await _database.database;
    final inserted = await db.insert(
      DbTables.messages,
      messageToMap(message),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return inserted > 0;
  }

  @override
  Future<bool> saveLocally(Message message, OutboxOperation operation) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      final inserted = await txn.insert(
        DbTables.messages,
        messageToMap(message),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (inserted == 0) {
        return false;
      }

      await txn.insert(
        DbTables.outbox,
        outboxToMap(operation),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    });
  }

  @override
  Future<Message?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      DbTables.messages,
      where: '${DbColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return messageFromMap(rows.first);
  }

  @override
  Future<List<Message>> listForConversation(
    String conversationId, {
    bool includeDeleted = false,
  }) async {
    final db = await _database.database;
    final deletedFilter = includeDeleted ? '' : 'AND ${DbColumns.deletedAtUtc} IS NULL';
    final rows = await db.query(
      DbTables.messages,
      where: '${DbColumns.conversationId} = ? $deletedFilter',
      whereArgs: [conversationId],
      orderBy: '${DbColumns.createdAtUtc} ASC, ${DbColumns.id} ASC',
    );
    return rows.map(messageFromMap).toList(growable: false);
  }

  @override
  Future<int> updateSyncStatus(
    String messageId,
    SyncStatus status, {
    DateTime? updatedAtUtc,
  }) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        DbTables.messages,
        columns: [DbColumns.revision],
        where: '${DbColumns.id} = ?',
        whereArgs: [messageId],
        limit: 1,
      );
      if (rows.isEmpty) return 0;

      final revision = (rows.first[DbColumns.revision] as int?) ?? 0;
      return txn.update(
        DbTables.messages,
        {
          DbColumns.syncStatus: status.name,
          DbColumns.updatedAtUtc: utcToMillis(
            updatedAtUtc ?? DateTime.now().toUtc(),
          ),
          DbColumns.revision: revision + 1,
        },
        where: '${DbColumns.id} = ?',
        whereArgs: [messageId],
      );
    });
  }

  @override
  Future<int> markDeleted(
    String messageId, {
    DateTime? deletedAtUtc,
  }) async {
    final db = await _database.database;
    final deletedAt = deletedAtUtc ?? DateTime.now().toUtc();

    return db.transaction((txn) async {
      final rows = await txn.query(
        DbTables.messages,
        columns: [DbColumns.revision],
        where: '${DbColumns.id} = ?',
        whereArgs: [messageId],
        limit: 1,
      );
      if (rows.isEmpty) return 0;

      final revision = (rows.first[DbColumns.revision] as int?) ?? 0;
      return txn.update(
        DbTables.messages,
        {
          DbColumns.deletedAtUtc: utcToMillis(deletedAt),
          DbColumns.updatedAtUtc: utcToMillis(deletedAt),
          DbColumns.syncStatus: SyncStatus.tombstone.name,
          DbColumns.revision: revision + 1,
        },
        where: '${DbColumns.id} = ?',
        whereArgs: [messageId],
      );
    });
  }
}
