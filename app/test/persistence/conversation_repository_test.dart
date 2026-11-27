import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/domain/entities/chat_enums.dart';
import 'package:meri_nashra/persistence/app_database.dart';
import 'package:meri_nashra/persistence/conversation_repository.dart';
import 'package:meri_nashra/persistence/outbox_repository.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late SqliteConversationRepository repository;
  late SqliteOutboxRepository outbox;

  setUpAll(initializeSqliteFfi);

  setUp(() async {
    directory = await createTestDirectory();
    database = makeTestDatabase(databasePath(directory));
    await database.open();
    repository = SqliteConversationRepository(database);
    outbox = SqliteOutboxRepository(database);
  });

  tearDown(() async {
    await database.close();
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  test('stores and reads the complete conversation contract', () async {
    final conversation = testConversation(
      isDeleted: true,
      deletedAt: updatedAt,
    );

    expect(await repository.insert(conversation), isTrue);
    final stored = await repository.findById(conversation.id);

    expect(stored, isNotNull);
    expect(stored!.id, 'conversation-1');
    expect(stored.userId, 'user-1');
    expect(stored.title, 'General');
    expect(stored.createdAtUtc, createdAt);
    expect(stored.updatedAtUtc, updatedAt);
    expect(stored.isDeleted, isTrue);
    expect(stored.deletedAtUtc, updatedAt);
  });

  test('duplicate conversation IDs never overwrite stored title', () async {
    await repository.insert(testConversation(title: 'Original'));
    expect(
      await repository.insert(testConversation(title: 'Overwritten')),
      isFalse,
    );

    final stored = await repository.findById('conversation-1');
    expect(stored!.title, 'Original');
  });

  test('user listing excludes deleted conversations unless requested', () async {
    await repository.insert(testConversation(id: 'conversation-1'));
    await repository.insert(testConversation(
      id: 'conversation-2',
      title: 'Deleted',
      isDeleted: true,
      deletedAt: updatedAt,
    ));

    final visible = await repository.listForUser('user-1');
    expect(visible.map((c) => c.id), ['conversation-1']);

    final all = await repository.listForUser('user-1', includeDeleted: true);
    expect(all.map((c) => c.id), containsAll(['conversation-1', 'conversation-2']));
  });

  test('local write and outbox enqueue are atomic for duplicates', () async {
    final conversation = testConversation();
    final operation = testOperation(
      entityType: OutboxEntityType.conversation,
      entityId: 'conversation-1',
      idempotencyKey: 'conversation-1:upsert',
      payloadJson: '{"id":"conversation-1"}',
    );

    expect(await repository.saveLocally(conversation, operation), isTrue);
    expect(await outbox.count(), 1);

    expect(await repository.saveLocally(conversation, operation), isFalse);
    expect(await outbox.count(), 1);
  });

  test('rename and delete update timestamps and deletion status', () async {
    await repository.insert(testConversation());

    final renamedAt = DateTime.utc(2026, 11, 27, 11, 0);
    await repository.rename('conversation-1', 'Prayer', updatedAtUtc: renamedAt);
    var stored = await repository.findById('conversation-1');
    expect(stored!.title, 'Prayer');
    expect(stored.updatedAtUtc, renamedAt);

    final deletedAt = DateTime.utc(2026, 11, 27, 11, 5);
    await repository.markDeleted('conversation-1', deletedAtUtc: deletedAt);
    stored = await repository.findById('conversation-1');
    expect(stored!.isDeleted, isTrue);
    expect(stored.deletedAtUtc, deletedAt);
  });
}
