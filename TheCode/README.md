# Tarteeb

Smart Planning & Productivity Platform for Campus and Personal planning.

Development runs with fictional in-memory tasks and requires no Firebase account
or credentials. Production configuration starts an empty preview with no demo
fixtures. Neither environment has persistent storage or task editing yet.

## Run from a fresh clone

Use Flutter **3.47.6 stable**, which includes Dart **3.13.5**. `.fvmrc` pins the
exact Flutter release for FVM users; with an existing FVM installation, run
`fvm install` in `TheCode/` and prefix the commands below with `fvm`. Otherwise
install that exact SDK release and check `flutter --version`. Do not install a
separate Dart SDK. `pubspec.yaml` bounds compatibility to Flutter 3.47.x / Dart
3.13.x, pins direct dependencies, and `pubspec.lock` locks transitive dependencies.

For Android, install Android Studio or the Android SDK with command-line tools,
platform-tools, API 36, build-tools 36.0.0 and NDK 28.2.13676358. Use JDK 17 or a
compatible newer JDK supported by Gradle 9.3.1. Run `flutter doctor -v`, review and
accept Android SDK licenses locally with `flutter doctor --android-licenses`, and
start an API 24+ emulator or connect a device with USB debugging enabled.
The pinned Flutter SDK sets Android compile/target API 36 and minimum API 24.

The complete runnable project lives in `TheCode/`. Open this folder in your IDE.
From the repository root:

```sh
cd TheCode
flutter pub get
flutter doctor -v
flutter devices
flutter run -d <android-device-id> --flavor development --dart-define-from-file=config/development.json
```

Replace `<android-device-id>` with an ID from `flutter devices` (do not type the
angle brackets). The installed app is **Tarteeb Dev**, ID `com.tarteeb.tarteeb.dev`.
No local environment file is needed: the committed JSON contains public settings.

For a quick web run with Chrome installed:

```sh
flutter run -d chrome --dart-define-from-file=config/development.json
```

See [environments and signing](docs/environments.md) for production builds,
configuration precedence, local overrides and troubleshooting.
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
flutter build apk --debug --flavor development --dart-define-from-file=config/development.json
flutter build web --dart-define-from-file=config/production.json
```

The tests cover real bootstrap, mode separation, immutable repository results,
loading/error/retry behavior, stale asynchronous responses, small-screen layout,
and dependency directions, plus configuration validation and production fixture
isolation. See [environment verification](docs/environment-verification.md) and
[earlier architecture verification](docs/verification.md).

## Architecture

- [Material 3 theme, design tokens and reusable style usage](docs/design-system.md)
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
