import 'app_database.dart';
import 'conversation_repository.dart';
import 'message_repository.dart';
import 'outbox_repository.dart';

/// Composition root for the local-first repositories.
class LocalStores {
  LocalStores(this.database)
      : messages = SqliteMessageRepository(database),
        conversations = SqliteConversationRepository(database),
        outbox = SqliteOutboxRepository(database);

  final AppDatabase database;

  final SqliteMessageRepository messages;
  final SqliteConversationRepository conversations;
  final SqliteOutboxRepository outbox;
}
