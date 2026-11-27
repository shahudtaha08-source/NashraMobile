import 'package:uuid/uuid.dart';

/// Generates the stable identifiers used as sync idempotency keys.
abstract final class Ids {
  static final Uuid _uuid = const Uuid();

  static String newMessageId() => _uuid.v4();

  static String newConversationId() => _uuid.v4();

  static String newDeviceId() => _uuid.v4();

  static String newOperationId() => _uuid.v4();
}
