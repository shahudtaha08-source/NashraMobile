/// Values shared by the local store and later synchronization/AI layers.
enum MessageRole { user, assistant, system }

enum SyncStatus { localOnly, pending, synced, conflict, tombstone }

enum ModelSource { unknown, placeholder, local, online }

enum OutboxEntityType { message, conversation }

enum OutboxOperationType { upsert, delete }

enum OutboxStatus { pending, processing, failed, completed, deadLetter }
