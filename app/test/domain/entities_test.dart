import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/application/ids.dart';
import 'package:meri_nashra/domain/entities/chat_enums.dart';

import '../support/fixtures.dart';

void main() {
  test('required domain enums are defined', () {
    expect(MessageRole.values, containsAll([MessageRole.user, MessageRole.assistant, MessageRole.system]));
    expect(SyncStatus.values, containsAll([
      SyncStatus.localOnly,
      SyncStatus.pending,
      SyncStatus.synced,
      SyncStatus.conflict,
      SyncStatus.tombstone,
    ]));
    expect(ModelSource.values, containsAll([
      ModelSource.unknown,
      ModelSource.placeholder,
      ModelSource.local,
      ModelSource.online,
    ]));
  });

  test('message copy preserves identity and supports clearing optional fields', () {
    final original = testMessage(
      modelSource: ModelSource.local,
      modelIdentifier: 'litertlm:test',
      deletedAt: updatedAt,
    );

    final renamed = original.copyWith(content: 'Updated');
    expect(renamed.id, original.id);
    expect(renamed.userId, original.userId);
    expect(renamed.conversationId, original.conversationId);
    expect(renamed.deviceId, original.deviceId);
    expect(renamed.role, original.role);
    expect(renamed.modelSource, ModelSource.local);
    expect(renamed.modelIdentifier, 'litertlm:test');
    expect(renamed.content, 'Updated');
    expect(renamed.deletedAtUtc, updatedAt);
    expect(renamed.isDeleted, isTrue);

    final cleared = renamed.copyWith(
      clearModelIdentifier: true,
      clearDeletedAt: true,
    );
    expect(cleared.modelIdentifier, isNull);
    expect(cleared.deletedAtUtc, isNull);
    expect(cleared.isDeleted, isFalse);
  });

  test('conversation copy preserves identity and deletion state', () {
    final original = testConversation();
    final updated = original.copyWith(
      title: 'Renamed',
      isDeleted: true,
      deletedAtUtc: updatedAt,
    );

    expect(updated.id, original.id);
    expect(updated.userId, original.userId);
    expect(updated.title, 'Renamed');
    expect(updated.createdAtUtc, original.createdAtUtc);
    expect(updated.isDeleted, isTrue);
    expect(updated.deletedAtUtc, updatedAt);
  });

  test('identifier generator produces unique RFC4122 v4 UUIDs', () {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    final ids = {
      Ids.newMessageId(),
      Ids.newConversationId(),
      Ids.newDeviceId(),
      Ids.newOperationId(),
    };

    expect(ids.length, 4);
    for (final id in ids) {
      expect(id, matches(uuidPattern));
    }
  });
}
