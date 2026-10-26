# Tarteeb

Smart Planning & Productivity Platform for Campus and Personal planning.

The architecture starter runs with fictional in-memory tasks and requires no
Firebase account, credentials, or environment files. Campus displays sample tasks;
Personal demonstrates an empty list. Task editing and persistent storage are not
implemented yet.

## Run from a fresh clone

Install Flutter **3.47.6 stable** (Dart **3.13.5**, the verified SDK versions) and
Chrome. For Android, also install the Android SDK/JDK prerequisites reported by
`flutter doctor` and start an emulator or connect a device.

The complete runnable project lives in `TheCode/`. Open this folder in your IDE.
From the repository root:

```sh
cd TheCode
flutter pub get
flutter run -d chrome
```

For Android, use `flutter devices`, then `flutter run -d <android-device-id>`.
Android, iOS and web scaffolds are included and share the Dart code in `lib/`.
For iOS, use a Mac with Xcode and a configured simulator or connected device, then
run `flutter run -d <ios-device-id>` from `TheCode`. The Xcode workspace is
`ios/Runner.xcworkspace`; device signing is configured locally in Xcode.
iOS builds cannot be verified on this Windows host.
Commit `pubspec.lock` so application dependencies stay reproducible. First-time
dependency/tool downloads require network access; app startup needs no backend.

## Verify

Run from `TheCode/`:

```sh
flutter analyze
flutter test
flutter build web
```

The tests cover real bootstrap, mode separation, immutable repository results,
loading/error/retry behavior, stale asynchronous responses, small-screen layout,
and dependency directions. See [verification evidence](docs/verification.md).

## Architecture

- [Structure, dependency diagram and naming conventions](docs/architecture.md)
- [ADR 0001: feature-first layered architecture](docs/adr/0001-feature-first-layered-architecture.md)
- [Original requirements](../Documents/Tarteeb_SRS_v1.docx)

`lib/app` composes the app, `lib/core` holds technical foundations, and
`lib/features/{shared,campus,personal}` owns product behavior. Both modes use
`features/shared/tasks` with Riverpod state and an injected domain repository.

## Firebase and private configuration

Live Firebase setup is a follow-up, described in the architecture document.
Do not run configuration tools against a private project as part of routine demo
startup. When integration is implemented, initialize Firebase in app bootstrap and
inject its repository adapter; keep SDK types in the data layer.

Local environment files, generated Firebase config, service-account filenames and
signing keys are ignored. Ignore patterns are a safeguard, not secret detection:
review `git diff --cached` before committing. Never commit credentials, production
exports, private student records or screenshots containing personal information.
Only fictional fixtures belong in tests and demo data.
