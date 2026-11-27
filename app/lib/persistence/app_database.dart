import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'schema.dart';

/// Owns the single local SQLite connection and schema migrations.
class AppDatabase {
  AppDatabase(this.path, {this._factory});

  final String path;
  final DatabaseFactory? _factory;
  Database? _database;

  static Future<String> defaultPath() async {
    final databasesPath = await getDatabasesPath();
    return '$databasesPath${Platform.pathSeparator}${DbSchema.databaseName}';
  }

  Future<Database> get database => open();

  Future<Database> open({int? version}) async {
    final current = _database;
    if (current != null && current.isOpen) return current;

    final targetVersion = version ?? DbSchema.version;
    final options = OpenDatabaseOptions(
      version: targetVersion,
      singleInstance: false,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, createdVersion) async {
        await createSchemaAtVersion(db, createdVersion);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.transaction((txn) async {
          if (oldVersion < 2 && newVersion >= 2) {
            await _upgradeV1ToV2(txn);
          }
        });
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        throw UnsupportedError(
          'Downgrading Nashra local database from $oldVersion to '
          '$newVersion is not supported; migrate forward instead.',
        );
      },
    );

    final opened = await (_factory ?? databaseFactory).openDatabase(
      path,
      options: options,
    );
    _database = opened;
    return opened;
  }

  Future<void> close() async {
    final current = _database;
    _database = null;
    if (current != null && current.isOpen) {
      await current.close();
    }
  }

  /// Creates the schema for a given historical version.
  ///
  /// Used by `onCreate` and by migration tests that need to seed an older
  /// database before upgrading it.
  Future<void> createSchemaAtVersion(Database db, int version) async {
    await db.transaction((txn) async {
      if (version >= 1) {
        await _createV1(txn);
      }
      if (version >= 2) {
        await _upgradeV1ToV2(txn);
      }
    });
  }

  Future<void> _createV1(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.conversations} (
        ${DbColumns.id} TEXT PRIMARY KEY,
        ${DbColumns.userId} TEXT NOT NULL,
        ${DbColumns.title} TEXT NOT NULL,
        ${DbColumns.createdAtUtc} INTEGER NOT NULL,
        ${DbColumns.updatedAtUtc} INTEGER NOT NULL,
        ${DbColumns.isDeleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.messages} (
        ${DbColumns.id} TEXT PRIMARY KEY,
        ${DbColumns.userId} TEXT NOT NULL,
        ${DbColumns.conversationId} TEXT NOT NULL,
        ${DbColumns.deviceId} TEXT NOT NULL,
        ${DbColumns.role} TEXT NOT NULL,
        ${DbColumns.content} TEXT NOT NULL,
        ${DbColumns.createdAtUtc} INTEGER NOT NULL,
        ${DbColumns.updatedAtUtc} INTEGER NOT NULL,
        ${DbColumns.modelSource} TEXT NOT NULL,
        ${DbColumns.modelIdentifier} TEXT,
        ${DbColumns.syncStatus} TEXT NOT NULL,
        FOREIGN KEY (${DbColumns.conversationId})
          REFERENCES ${DbTables.conversations} (${DbColumns.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.outbox} (
        ${DbColumns.operationId} TEXT PRIMARY KEY,
        ${DbColumns.idempotencyKey} TEXT NOT NULL UNIQUE,
        ${DbColumns.entityType} TEXT NOT NULL,
        ${DbColumns.entityId} TEXT NOT NULL,
        ${DbColumns.operationType} TEXT NOT NULL,
        ${DbColumns.conversationId} TEXT,
        ${DbColumns.payloadJson} TEXT NOT NULL,
        ${DbColumns.status} TEXT NOT NULL,
        ${DbColumns.attempts} INTEGER NOT NULL DEFAULT 0,
        ${DbColumns.maxAttempts} INTEGER NOT NULL DEFAULT 5,
        ${DbColumns.nextAttemptAtUtc} INTEGER NOT NULL,
        ${DbColumns.lastError} TEXT,
        ${DbColumns.createdAtUtc} INTEGER NOT NULL,
        ${DbColumns.updatedAtUtc} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_messages_conversation_created
      ON ${DbTables.messages} (${DbColumns.conversationId}, ${DbColumns.createdAtUtc})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_messages_sync_status
      ON ${DbTables.messages} (${DbColumns.syncStatus})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_outbox_status_next
      ON ${DbTables.outbox} (${DbColumns.status}, ${DbColumns.nextAttemptAtUtc})
    ''');
  }

  Future<void> _upgradeV1ToV2(DatabaseExecutor db) async {
    await db.execute(
      'ALTER TABLE ${DbTables.messages} ADD COLUMN ${DbColumns.revision} '
      'INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE ${DbTables.messages} ADD COLUMN ${DbColumns.deletedAtUtc} '
      'INTEGER',
    );
    await db.execute(
      'ALTER TABLE ${DbTables.conversations} ADD COLUMN '
      '${DbColumns.deletedAtUtc} INTEGER',
    );
    await db.execute(
      'ALTER TABLE ${DbTables.outbox} ADD COLUMN '
      '${DbColumns.lastAttemptAtUtc} INTEGER',
    );

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_messages_conversation_updated
      ON ${DbTables.messages} (${DbColumns.conversationId}, ${DbColumns.updatedAtUtc})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_messages_deleted_at
      ON ${DbTables.messages} (${DbColumns.deletedAtUtc})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_conversations_user_updated
      ON ${DbTables.conversations} (${DbColumns.userId}, ${DbColumns.updatedAtUtc})
    ''');
  }
}
