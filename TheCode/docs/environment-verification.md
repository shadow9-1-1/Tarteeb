# Environment setup verification

Verified on 2026-10-26 and continued on 2026-10-27 (Africa/Cairo), on Windows.
Flutter 3.47.6 / Dart 3.13.5. All commands below run from `TheCode/`.

## Completed checks

| Check | Result |
| --- | --- |
| `flutter pub get` | Passed; resolved package versions unchanged, SDK bounds tightened in lockfile |
| `flutter analyze --no-pub` | Passed, no issues |
| `flutter test --no-pub` | Passed, 14 tests |
| `flutter test test/app/compiled_config_test.dart --no-pub --dart-define-from-file=config/production.json` | Passed; real entry point selects the production preview without demo tasks |
| `flutter test test/app/compiled_config_test.dart --no-pub --flavor development --dart-define-from-file=config/production.json` | Passed; real entry point displays the configuration-error screen for a mismatch |
| `flutter build web --no-pub --dart-define-from-file=config/production.json` | Passed; release web output generated |
| Offline screenshot capture | Passed; production preview and configuration-error renders inspected |
| `git diff --check` | Passed |

The new tests cover default development configuration, production selection from
the native flavor alone, committed config samples, invalid values, flavor/define
mismatch, and absence of demo tasks in both production modes. Existing async
loading/error/retry, mode isolation, small-screen, repository and architecture
tests continue to pass.

Flutter reserves `FLUTTER_APP_FLAVOR`; an initial attempt to supply it as a Dart
define was rejected by the CLI. The passing mismatch check above uses `--flavor`,
which is the supported way to exercise that value.

The production web build emitted the existing non-fatal CupertinoIcons font-family
warning. The app uses Material icons; those render correctly in the inspected images.

## Android build and device status

Android development APK compilation was attempted with:

```sh
flutter build apk --debug --flavor development --dart-define-from-file=config/development.json
```

The initial attempt installed API 36 using an already accepted local SDK license.
`flutter doctor -v` nevertheless reports missing command-line tools and unknown
license status. No license acceptance or security settings were automated.
The build was interrupted across the session boundary and restarted with output
recorded locally at `build/android-development-build.log`.

The restarted attempt failed after 6m 41s at
`:app:processDevelopmentDebugResources`: Gradle could not read workspace metadata
for cached transform `16406a333fca135423c0728b17aa5a5a` under its user cache. A
targeted cache quarantine was attempted, but another process held its lock file.
The partially moved workspace was restored; no shared cache was deleted and no
unrelated Gradle process was stopped. A subsequent retry and a production attempt
were canceled before completion. This is a local cache/tooling blocker, not a
passing Android check; native compilation remains unverified.

Android APK build verification is pending; no successful APK or release-signing
verification is claimed in this report. Production APK verification is also
pending. The environment configuration and native Gradle flavor definitions must
still complete an Android build on a working toolchain.

An existing `Medium_Phone_API_37.0` emulator was launched for a manual check, but
`flutter devices` reported `emulator-5554` offline. The Windows computer-use
helper's `list_apps` timed out on the initial request, retry, and retry after
reset. No app interaction was possible. The emulator was shut down afterward.
Manual device verification remains **pending**, not passed.

To complete it after following the [setup guide](../README.md):

1. Build both debug variants using the commands in [environments](environments.md).
2. Install both on a running Android device; confirm **Tarteeb Dev** and **Tarteeb**
   coexist with separate IDs.
3. Open Development: confirm Campus samples and Personal empty state; switch back.
4. Open Production: confirm the storage-not-connected notice and no demo tasks.
5. Record the device/API, date, results and screenshots here.

## Screenshot evidence

These are offline Flutter widget renders at 390 x 844, not device screenshots.
They use the actual widgets and production composition. Both new images were
visually inspected for legibility and clipping.

- [Production preview](screenshots/production-preview.png)
- [Configuration error](screenshots/configuration-error.png)
- Existing [development](screenshots/campus.png), [empty](screenshots/personal-empty.png),
  [loading](screenshots/loading.png), and [error/retry](screenshots/error.png) states
  were regenerated with the same harness.

Reproduce with a local SDK font path:

```sh
flutter test tool/capture_screenshots.dart --no-pub --dart-define=SCREENSHOT_FONT=/path/to/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf
```

## Configuration hygiene

`git check-ignore` confirmed local JSON overrides, environment files, private
signing properties, keystores, generated Firebase config and FVM caches are ignored.
The Android Kotlin cache is ignored as well. `git ls-files` found no tracked
credential/config files matching the private-file patterns checked. A common
private-key/token pattern scan of app/config/test/tooling source found no matches.
These checks are not a complete historical secret audit.

Only public environment names and placeholder signing values were added. No real
credentials, Firebase project, private student data, release signing operation,
publication, or Git commit was created by this task.
