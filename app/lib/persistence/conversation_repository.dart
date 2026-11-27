import 'package:sqflite/sqflite.dart';

import '../domain/entities/conversation.dart';
import '../domain/entities/outbox_operation.dart';
import '../domain/repositories/conversation_repository.dart';
import 'app_database.dart';
import 'mappers.dart';
import 'schema.dart';

class SqliteConversationRepository implements ConversationRepository {
  SqliteConversationRepository(this._database);

  final AppDatabase _database;

  @override
  Future<bool> insert(Conversation conversation) async {
    final db = await _database.database;
    final inserted = await db.insert(
      DbTables.conversations,
      conversationToMap(conversation),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return inserted > 0;
  }

  @override
  Future<bool> saveLocally(
    Conversation conversation,
    OutboxOperation operation,
  ) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      final inserted = await txn.insert(
        DbTables.conversations,
        conversationToMap(conversation),
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
  Future<Conversation?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      DbTables.conversations,
      where: '${DbColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return conversationFromMap(rows.first);
  }

  @override
  Future<List<Conversation>> listForUser(
    String userId, {
    bool includeDeleted = false,
  }) async {
    final db = await _database.database;
    final deletedFilter = includeDeleted ? '' : 'AND ${DbColumns.isDeleted} = 0';
    final rows = await db.query(
      DbTables.conversations,
      where: '${DbColumns.userId} = ? $deletedFilter',
      whereArgs: [userId],
      orderBy: '${DbColumns.updatedAtUtc} DESC, ${DbColumns.id} ASC',
    );
    return rows.map(conversationFromMap).toList(growable: false);
  }

  @override
  Future<int> rename(
    String conversationId,
    String title, {
    DateTime? updatedAtUtc,
  }) async {
    final db = await _database.database;
    return db.update(
      DbTables.conversations,
      {
        DbColumns.title: title,
        DbColumns.updatedAtUtc: utcToMillis(
          updatedAtUtc ?? DateTime.now().toUtc(),
        ),
      },
      where: '${DbColumns.id} = ?',
      whereArgs: [conversationId],
    );
  }

  @override
  Future<int> markDeleted(
    String conversationId, {
    DateTime? deletedAtUtc,
  }) async {
    final db = await _database.database;
    final deletedAt = deletedAtUtc ?? DateTime.now().toUtc();
    return db.update(
      DbTables.conversations,
      {
        DbColumns.isDeleted: 1,
        DbColumns.deletedAtUtc: utcToMillis(deletedAt),
        DbColumns.updatedAtUtc: utcToMillis(deletedAt),
      },
      where: '${DbColumns.id} = ?',
      whereArgs: [conversationId],
    );
  }
}
