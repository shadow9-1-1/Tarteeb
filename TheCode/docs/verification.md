# Architecture starter verification

Date: 2026-10-26. Host: Windows. Flutter 3.47.6 stable / Dart 3.13.5.

This records the earlier architecture work. For the subsequent environment and
Android flavor changes, see [environment verification](environment-verification.md).

## Project relocation and iOS scaffold

The complete Flutter project now lives in `TheCode/`, including `android/`,
`ios/`, `web/`, `lib/`, tests, tooling, configuration and these documents. Original
requirements remain in the repository's `Documents/` folder. All Flutter commands
must run from `TheCode/`.

After relocation, generated caches were cleaned with `flutter clean`, dependencies
were restored with `flutter pub get`, analysis passed with no issues, all eight
Flutter tests passed, and `flutter build web --no-pub` succeeded from the new
project root. Local configuration and generated
build outputs remain ignored by Git using `TheCode/.gitignore` and platform rules.

The iOS runner and Xcode workspace were generated with Flutter. iOS compilation,
signing and device verification are pending because this host runs Windows; they
require macOS and Xcode. Shared Dart code is used by all three platform runners.
The earlier clean-source snapshot described below was temporary and was removed
with generated build caches during relocation.

## Automated checks

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` (after dependency restore) | Passed, no issues; includes screenshot tooling |
| `flutter test --no-pub` | Passed, 8 tests |
| `flutter build web` | Passed, release output generated in `build/web` |
| Offline screenshot harness | Passed; four PNGs generated |
| `git diff --check` | Passed; Git reports only its usual LF/CRLF conversion notice |
| Common credential pattern scan of new source/config | No private-key blocks, service-account private keys, Firebase API key strings or GitHub tokens found |

Behavior coverage:

1. One repository separates Campus and Personal results.
2. An empty mode produces a successful empty list.
3. Mutating the input or returned list cannot change repository state.
4. Source imports respect architecture boundaries.
5. The actual `main()` entry point starts without Firebase, switches to Personal,
   and switches back to Campus.
6. Loading becomes a safe error; Retry makes a new request and recovers.
7. A late Campus response cannot overwrite Personal state.
8. A 320 x 568 viewport at double text size renders and switches without exceptions.

The initial checks found five brace-style issues in the architecture test and an
animation-clock issue from calling `runApp` repeatedly in the test harness. Both
were corrected; the layout test now uses `pumpWidget`, while the startup test
continues to exercise the real entry point. Final checks above passed.

The web build emitted a non-fatal CupertinoIcons font-family warning. The starter
uses Material icons; these render correctly in the offline images. This is not a
claim that browser rendering has been checked.

## Clean source startup

Copied the version-control candidate files from
`git ls-files --cached --others --exclude-standard` into the ignored
`build/fresh-clone-check` directory. This excludes `.dart_tool`, build caches,
local properties and Firebase/environment configuration. Then ran:

```sh
flutter pub get
flutter test test/app/app_test.dart --plain-name "default entry starts without Firebase and switches modes" --no-pub
```

Both passed. This verifies clean-source dependency restoration and app bootstrap
in Flutter's widget runner. It is a source-snapshot check, not a remote clone or
an Android installation. The machine's installed Flutter SDK/package cache is
still available, as it would be for a developer following the README.

## Visual evidence

These are **offline Flutter widget renders**, not screenshots from a device or
browser. Captured at 390 x 844 with Roboto and the bundled Material icon font.
The generated images were visually inspected for text wrapping, spacing, icons,
mode labels and state-specific content. All show fictional sample data only.

| State | Evidence |
| --- | --- |
| Campus task data | [campus.png](screenshots/campus.png) |
| Personal empty state | [personal-empty.png](screenshots/personal-empty.png) |
| Pending request | [loading.png](screenshots/loading.png) |
| Failed request with retry | [error.png](screenshots/error.png) |

Reproduce from `TheCode/`, the Flutter project root (replace the local font path):

```sh
flutter test tool/capture_screenshots.dart --dart-define=SCREENSHOT_FONT=/path/to/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf
```

The harness uses the real app widgets and overrides the repository to exercise
loading/error states. It does not alter the app's production entry point or access
a network service. Screenshots are evidence, not pixel-comparison golden tests.

## Manual browser and device status

- Browser: **pending**. Attempted to open the locally served web build, but the
  browser permission gate denied access to `http://127.0.0.1:8765`. No alternate
  browser workaround was attempted. The local server was stopped.
- Android: **pending**. `flutter devices` listed Windows, Chrome and Edge, with
  no connected Android device. No Android APK build or device run is claimed.
- Firebase: intentionally not configured in this architecture task; no live
  authentication, Firestore read, rules, or emulator validation is claimed.

Manual follow-up procedure:

1. Follow the README startup commands on Chrome or an Android device.
2. Confirm Campus displays two sample tasks and the demo-data notice.
3. Select Personal and confirm the empty state, then return to Campus.
4. Verify text/icon rendering, touch or keyboard navigation, and no clipping at
   a narrow viewport and increased system text size.
5. Record the device/browser, version, date, result and a screenshot here.

Architecture, shared ownership and automated startup checks are complete.
Manual platform verification remains open; this report does not mark it passed.
