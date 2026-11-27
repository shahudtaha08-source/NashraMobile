import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/domain/entities/chat_enums.dart';
import 'package:meri_nashra/persistence/app_database.dart';
import 'package:meri_nashra/persistence/conversation_repository.dart';
import 'package:meri_nashra/persistence/message_repository.dart';
import 'package:meri_nashra/persistence/outbox_repository.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late SqliteMessageRepository repository;
  late SqliteConversationRepository conversations;
  late SqliteOutboxRepository outbox;

  setUpAll(initializeSqliteFfi);

  setUp(() async {
    directory = await createTestDirectory();
    database = makeTestDatabase(databasePath(directory));
    await database.open();
    repository = SqliteMessageRepository(database);
    conversations = SqliteConversationRepository(database);
    outbox = SqliteOutboxRepository(database);
    await conversations.insert(testConversation());
  });

  tearDown(() async {
    await database.close();
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  test('stores and reads the complete message contract', () async {
    final message = testMessage(
      modelSource: ModelSource.online,
      modelIdentifier: 'test-provider:test-model',
      syncStatus: SyncStatus.synced,
      revision: 3,
    );

    expect(await repository.insert(message), isTrue);

    final stored = await repository.findById(message.id);
    expect(stored, isNotNull);
    expect(stored!.id, message.id);
    expect(stored.userId, 'user-1');
    expect(stored.conversationId, 'conversation-1');
    expect(stored.deviceId, 'device-1');
    expect(stored.role, MessageRole.user);
    expect(stored.content, 'Hello Nashra');
    expect(stored.createdAtUtc, createdAt);
    expect(stored.updatedAtUtc, updatedAt);
    expect(stored.modelSource, ModelSource.online);
    expect(stored.modelIdentifier, 'test-provider:test-model');
    expect(stored.syncStatus, SyncStatus.synced);
    expect(stored.revision, 3);
    expect(stored.deletedAtUtc, isNull);
  });

  test('duplicate message IDs never overwrite stored content', () async {
    final original = testMessage(content: 'Original');
    final duplicate = testMessage(content: 'Overwritten');

    expect(await repository.insert(original), isTrue);
    expect(await repository.insert(duplicate), isFalse);

    final stored = await repository.findById(original.id);
    expect(stored!.content, 'Original');
  });

  test('conversation listing excludes tombstones unless requested', () async {
    await repository.insert(testMessage(
      id: 'message-1',
      created: DateTime.utc(2026, 11, 27, 10, 0),
    ));
    await repository.insert(testMessage(
      id: 'message-2',
      content: 'Second',
      created: DateTime.utc(2026, 11, 27, 10, 2),
    ));
    await repository.insert(testMessage(
      id: 'message-3',
      content: 'Deleted',
      created: DateTime.utc(2026, 11, 27, 10, 3),
      deletedAt: DateTime.utc(2026, 11, 27, 10, 4),
      syncStatus: SyncStatus.tombstone,
    ));

    final visible = await repository.listForConversation('conversation-1');
    expect(visible.map((m) => m.id), ['message-1', 'message-2']);

    final all = await repository.listForConversation(
      'conversation-1',
      includeDeleted: true,
    );
    expect(all.map((m) => m.id), ['message-1', 'message-2', 'message-3']);
  });

  test('local write and outbox enqueue are atomic for duplicates', () async {
    final message = testMessage();
    final operation = testOperation();

    expect(await repository.saveLocally(message, operation), isTrue);
    expect(await outbox.count(), 1);

    expect(await repository.saveLocally(message, operation), isFalse);
    expect(await outbox.count(), 1);
  });

  test('sync status and deletion transitions increment revision', () async {
    await repository.insert(testMessage());

    await repository.updateSyncStatus('message-1', SyncStatus.synced);
    var stored = await repository.findById('message-1');
    expect(stored!.syncStatus, SyncStatus.synced);
    expect(stored.revision, 1);

    await repository.markDeleted('message-1');
    stored = await repository.findById('message-1');
    expect(stored!.syncStatus, SyncStatus.tombstone);
    expect(stored.isDeleted, isTrue);
    expect(stored.revision, 2);
  });
}
