# Meri Nashra

Meri Nashra is a local-first Flutter companion app for Android. The current repository contains the Phase 1 foundation: the existing chat UI, a SQLite data model, repositories, a persistent sync outbox, and automated tests.

## Current status

Phase 1 is implemented and validated:

- Chat UI preserved from the original application, now using explicit theme tokens.
- Domain entities for messages, conversations, and outbox operations.
- Sync-status, model-source, role, and outbox enums.
- SQLite schema version 2 with forward migration from version 1.
- Repository contracts plus SQLite implementations.
- Persistent outbox with idempotency keys, retry attempts, failure state, dead-letter handling, and stale-operation recovery.
- Unit, database, migration, duplicate-handling, outbox-recovery, theme-token, and widget tests.
- Android launcher icons generated from the user-supplied photograph at the project root.

The app UI still uses in-memory messages and a fixed placeholder reply. The repositories are not yet wired into the UI. Authentication, synchronization, AI routing, local/online model execution, and release signing are not implemented.

## Architecture overview

```
app/lib/main.dart                    Existing chat UI and app entry point
app/lib/app/theme/                   Exact colors, typography, spacing, sizes, strings
app/lib/application/                 Stable UUID generation helpers
app/lib/domain/entities/             Message, Conversation, OutboxOperation, enums
app/lib/domain/repositories/         Repository contracts
app/lib/persistence/                 SQLite schema, mappers, repositories, composition root
app/android/                         Android application, manifest, resources, Gradle wrapper
app/test/                            Unit, widget, and database tests
```

The data layer is local-first: repositories own durable SQLite state, and local writes can enqueue outbox operations atomically. Outbox operations are keyed by stable IDs and idempotency keys so duplicate handling is safe.

## Repository structure

```
.
├── .gitignore
├── README.md
├── ChatGPT Image Nov 27, 2026, 10_38_18 PM.png   # Official icon source image
├── app/
│   ├── .metadata
│   ├── .gitignore
│   ├── README.md
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── lib/
│   ├── test/
│   └── android/
└── gradle wrapper, Android resources, and generated local SDK/JDK folders
```

Local SDK/JDK directories, build outputs, IDE metadata, temporary logs, screenshots, and old third-party source trees are intentionally excluded from Git.

## Development prerequisites

- Flutter 3.50.0 stable (Dart 3.14.0 was used for validation).
- Android SDK with Platform Tools and a JDK 17 installation.
- A connected Android device or emulator for on-device installation.
- On Windows host testing, `sqlite3.dll` must be available on `PATH` for SQLite FFI tests. The app's Android build uses the platform SQLite implementation and does not require this host-only setup.

## Setup and build

From `app/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Debug APK output:

```
app/build/app/outputs/flutter-apk/app-debug.apk
```

Install on a connected Android device from `app/`:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Testing instructions

Run all unit, widget, persistence, migration, duplicate-handling, and outbox-recovery tests from `app/`:

```bash
flutter test
```

The existing widget test verifies the preserved chat screen title, subtitle, message entry, and placeholder reply. Database tests use `sqflite_common_ffi` and temporary SQLite files on the host.

## Planned but not implemented

- Android and PC clients.
- Firebase authentication and cloud account identity.
- Firestore conversation and message synchronization.
- Local AI execution (LiteRT-LM) and Ollama integration.
- Online AI providers with automatic online-to-local fallback.
- AI routing and provider selection.
- Release signing and store distribution.
- Windows desktop build support.

## Known limitations

- Messages are currently in-memory in the UI; SQLite repositories are not yet connected to the screen.
- The assistant reply is a fixed placeholder.
- Persistence is verified across SQLite close/reopen in tests, not across a full application-process restart.
- The launcher icon is built from the supplied photograph, but launcher visibility on the device must be visually confirmed after installation.
- No production-ready claim is made; only debug builds have been validated.
