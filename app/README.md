# Meri Nashra — Flutter application

This directory contains the Flutter application for Meri Nashra. Phase 1 provides the preserved chat UI, local SQLite data model, repositories, persistent sync outbox, and automated tests.

## Requirements

- Flutter 3.50.0 stable with Dart 3.14.0 (validated versions).
- Android SDK with Platform Tools.
- JDK 17 for Android Gradle builds.
- For Windows host-side SQLite tests, `sqlite3.dll` must be available on `PATH`. This is only needed because local Application Control blocks the generated DLL in the build directory; the Android app uses platform SQLite.

## Install dependencies

From this `app/` directory:

```bash
flutter pub get
```

## Static analysis

```bash
flutter analyze
```

## Tests

```bash
flutter test
```

This runs unit tests, the preserved widget test, database persistence tests, migration tests, duplicate-message tests, outbox recovery tests, and a SQLite close/reopen persistence test.

## Debug APK build

```bash
flutter build apk --debug
```

APK output path:

```
build/app/outputs/flutter-apk/app-debug.apk
```

## Install on Android

With a device connected and authorized:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

This installs the current `com.nashra.meri_nashra` package without uninstalling or erasing data from any previously installed application package.

## Current implementation limitations

- The UI still uses in-memory messages and a fixed placeholder reply.
- SQLite repositories exist but are not yet wired into the UI.
- Authentication, cloud sync, local/online AI, and model routing are not implemented.
- Persistence has been verified across database close/reopen in tests, not a full application-process restart.
- Only debug builds are validated; no signed release build is configured.
- Launcher icon resources are generated from the user-supplied photograph; visual launcher confirmation on the device is still required.
