import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/domain/entities/conversation.dart';
import 'package:meri_nashra/domain/entities/message.dart';
import 'package:meri_nashra/domain/entities/outbox_operation.dart';
import 'package:meri_nashra/persistence/mappers.dart';
import 'package:meri_nashra/persistence/schema.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

Map<String, Object?> legacyConversationMap(Conversation conversation) {
  final map = conversationToMap(conversation);
  map.remove(DbColumns.deletedAtUtc);
  return map;
}

Map<String, Object?> legacyMessageMap(Message message) {
  final map = messageToMap(message);
  map.remove(DbColumns.revision);
  map.remove(DbColumns.deletedAtUtc);
  return map;
}

Map<String, Object?> legacyOutboxMap(OutboxOperation operation) {
  final map = outboxToMap(operation);
  map.remove(DbColumns.lastAttemptAtUtc);
  return map;
}

void main() {
  setUpAll(initializeSqliteFfi);

  test('version 1 data survives migration to version 2', () async {
    final directory = await createTestDirectory();
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    final path = databasePath(directory, 'migration.db');

    final legacy = makeTestDatabase(path);
    await legacy.open(version: 1);
    final legacyDb = await legacy.database;
    await legacyDb.insert(
      DbTables.conversations,
      legacyConversationMap(testConversation()),
    );
    await legacyDb.insert(
      DbTables.messages,
      legacyMessageMap(testMessage()),
    );
    await legacyDb.insert(
      DbTables.outbox,
      legacyOutboxMap(testOperation()),
    );
    await legacy.close();

    final upgraded = makeTestDatabase(path);
    await upgraded.open();
    addTearDown(upgraded.close);
    final db = await upgraded.database;

    final messageColumns = await db.rawQuery('PRAGMA table_info(messages)');
    final conversationColumns =
        await db.rawQuery('PRAGMA table_info(conversations)');
    final outboxColumns = await db.rawQuery('PRAGMA table_info(outbox)');

    final messageColumnNames =
        messageColumns.map((row) => row['name']).toList();
    expect(messageColumnNames, contains(DbColumns.revision));
    expect(messageColumnNames, contains(DbColumns.deletedAtUtc));
    expect(
      conversationColumns.map((row) => row['name']),
      contains(DbColumns.deletedAtUtc),
    );
    expect(
      outboxColumns.map((row) => row['name']),
      contains(DbColumns.lastAttemptAtUtc),
    );

    final messages = await db.query(DbTables.messages);
    expect(messages, hasLength(1));
    final migratedMessage = messageFromMap(messages.first);
    expect(migratedMessage.id, 'message-1');
    expect(migratedMessage.content, 'Hello Nashra');
    expect(migratedMessage.revision, 0);
    expect(migratedMessage.deletedAtUtc, isNull);

    final conversations = await db.query(DbTables.conversations);
    expect(conversationFromMap(conversations.first).title, 'General');

    final outbox = await db.query(DbTables.outbox);
    expect(outboxFromMap(outbox.first).idempotencyKey, 'message-1:upsert');

    final userVersion = await db.rawQuery('PRAGMA user_version');
    expect(userVersion.first.values.first, DbSchema.version);
  });
}
