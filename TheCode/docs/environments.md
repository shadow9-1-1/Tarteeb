# Development and production environments

Run all commands from `TheCode/`. These environments use one Flutter entry point
(`lib/main.dart`) and one shared feature implementation.

| Setting | Development | Production |
| --- | --- | --- |
| Android flavor | `development` | `production` |
| Android application ID | `com.tarteeb.tarteeb.dev` | `com.tarteeb.tarteeb` |
| Android launcher label | Tarteeb Dev | Tarteeb |
| Public define file | `config/development.json` | `config/production.json` |
| Task fixtures | Fictional Campus samples | None |
| Backend | In memory | Empty in-memory preview; storage not connected |

The app IDs allow both Android variants to coexist. Flavor controls the environment;
debug/profile/release controls compilation and signing. A production **debug**
build is useful for local verification; it is not a store release.

## Configuration rules

`APP_ENV` accepts exactly `development` or `production`. If omitted, the native
`appFlavor` chooses the environment. If both are absent (for example a plain web
run), development is the default. If both are present, they must match. Unknown
values and mismatches show a configuration-error screen before creating a repository;
they never silently switch to development data.

The committed files are complete, non-secret examples. Optional local overrides:

```sh
cp config/development.json config/development.local.json
flutter run --flavor development --dart-define-from-file=config/development.local.json
```

In PowerShell, use `Copy-Item` in place of `cp` if preferred. `*.local.json` under
`config/` is ignored. Changing defines requires a stop/rebuild; hot reload does not
replace compile-time settings. Do not use `--flavor` on web. iOS uses its existing
Runner scheme and the JSON defines; separate Xcode flavors/identities are outside
this Android-focused task.

## Commands

```sh
# Android development: install or produce a debug APK
flutter run -d <android-device-id> --flavor development --dart-define-from-file=config/development.json
flutter build apk --debug --flavor development --dart-define-from-file=config/development.json

# Android production configuration, still debug-signed for local inspection
flutter run -d <android-device-id> --flavor production --dart-define-from-file=config/production.json
flutter build apk --debug --flavor production --dart-define-from-file=config/production.json

# Web production preview (no native flavor)
flutter run -d chrome --dart-define-from-file=config/production.json
flutter build web --dart-define-from-file=config/production.json

# macOS/Xcode only: same public production settings, existing Runner scheme
flutter run -d <ios-device-id> --dart-define-from-file=config/production.json
```

Debug APKs appear under `build/app/outputs/flutter-apk/`, named
`app-development-debug.apk` and `app-production-debug.apk`.

## Release signing

Development and production debug builds need no private signing setup. For a
signed release, copy `android/key.properties.example` to `android/key.properties`,
fill in local passwords/alias and a keystore path, and keep the keystore outside
the repository. `storeFile` accepts an absolute path (forward slashes work on
Windows) or a path relative to `android/`.

```sh
flutter build appbundle --release --flavor production --dart-define-from-file=config/production.json
```

Release builds use the private signing configuration only when it exists. They
never fall back to the debug key. Without a signing file, Gradle has no release
signing configuration: an APK may be unsigned and a signed publishing workflow
cannot complete. A present but incomplete signing file fails with the missing
property name, not its secret value. Release signing and Play Store publication
have not been verified or performed. Production is still an empty preview, not a
finished product connected to a live service.

## Reproducibility and credentials

- Flutter 3.47.6 / bundled Dart 3.13.5 are pinned via `.fvmrc`; the README also
  supports installing that SDK directly. Do not run `flutter upgrade` or
  `flutter pub upgrade` as onboarding steps.
- Commit `pubspec.lock`; it pins the complete application dependency graph.
  Gradle 9.3.1, Android Gradle Plugin 9.1.0 and Kotlin 2.4.0 are pinned in the
  existing Android scaffold. Android SDK levels/NDK come from the pinned Flutter SDK.
- JSON defines are embedded in app binaries and are **not secret storage**.
  Never add service-account keys, passwords, access tokens, signing secrets or
  private student data to defines, assets, fixtures, screenshots, or source.
- Git ignores local environment/configuration files, Firebase configuration,
  signing keys, FVM caches, build outputs and SDK-local paths. Ignore rules do not
  remove secrets that were already tracked. Review `git diff --cached` before committing.
- Live Firebase Auth/Firestore setup remains a separate task. Future environments
  must use separate Firebase projects and matching native registrations, with
  access enforced by authentication and security rules, not just the build flavor.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| Android command-line tools missing | Install Android SDK Command-line Tools through Android Studio's SDK Manager, then rerun `flutter doctor -v`. |
| Licenses unknown/not accepted | Review and accept them yourself using `flutter doctor --android-licenses`. |
| No Android device | Start an emulator or connect a USB-debugging device; confirm it in `flutter devices`. |
| SDK/NDK missing | Install API 36, build-tools 36.0.0 and NDK 28.2.13676358 in SDK Manager. |
| Java/Gradle compatibility error | Check the Java path in `flutter doctor -v`; use a supported JDK and, if needed, `flutter config --jdk-dir=<local-jdk-path>`. |
| No matching Android variant | Supply `--flavor development` or `--flavor production`. |
| Configuration-error screen | Match `--flavor` and the JSON's `APP_ENV`, then stop and rebuild. |
| Old paths after moving the checkout | Run `flutter clean` and `flutter pub get` inside `TheCode`. |
| Gradle cannot read transform `workspace/metadata.bin` | Close builds using that Gradle cache, then retry with a fresh `GRADLE_USER_HOME` or repair the specific failed cache entry. Do not delete shared caches while other builds use them. |

References: [Flutter Android flavors](https://docs.flutter.dev/deployment/flavors)
and [Android release signing](https://docs.flutter.dev/deployment/android).
