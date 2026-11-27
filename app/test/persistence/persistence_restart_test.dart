import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/domain/entities/chat_enums.dart';
import 'package:meri_nashra/persistence/local_stores.dart';

import '../support/fixtures.dart';
import '../support/test_database.dart';

void main() {
  setUpAll(initializeSqliteFfi);

  test('local data persists across closing and reopening the database', () async {
    final directory = await createTestDirectory();
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    final path = databasePath(directory, 'restart.db');

    final firstRun = makeTestDatabase(path);
    await firstRun.open();
    final firstStores = LocalStores(firstRun);
    final conversation = testConversation(title: 'Persisted chat');
    final message = testMessage(
      content: 'This survives a restart',
      modelSource: ModelSource.local,
      modelIdentifier: 'local:test-model',
      syncStatus: SyncStatus.pending,
    );
    final operation = testOperation();

    await firstStores.conversations.insert(conversation);
    expect(await firstStores.messages.saveLocally(message, operation), isTrue);
    await firstRun.close();

    final secondRun = makeTestDatabase(path);
    await secondRun.open();
    addTearDown(secondRun.close);
    final secondStores = LocalStores(secondRun);

    final storedConversation =
        await secondStores.conversations.findById(conversation.id);
    expect(storedConversation, isNotNull);
    expect(storedConversation!.title, 'Persisted chat');

    final storedMessage = await secondStores.messages.findById(message.id);
    expect(storedMessage, isNotNull);
    expect(storedMessage!.content, 'This survives a restart');
    expect(storedMessage.modelSource, ModelSource.local);
    expect(storedMessage.modelIdentifier, 'local:test-model');
    expect(storedMessage.syncStatus, SyncStatus.pending);
    expect(storedMessage.createdAtUtc, createdAt);
    expect(storedMessage.updatedAtUtc, updatedAt);

    final storedOperation = await secondStores.outbox.findById(operation.operationId);
    expect(storedOperation, isNotNull);
    expect(storedOperation!.idempotencyKey, 'message-1:upsert');
    expect(storedOperation.status, OutboxStatus.pending);
  });
}
