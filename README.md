# Tarteeb

Smart Planning & Productivity Platform for Campus and Personal planning.

The complete Flutter project is in **[TheCode](TheCode/)**, including Android,
iOS, web, shared Dart source, tests, configuration, and architecture documentation.
Original project requirements remain in [Documents](Documents/).

```text
TheCode/
  android/       Android app
  ios/           iOS app and Xcode workspace
  web/           Web app
  lib/           Shared Flutter source for all platforms
  test/          Automated tests
  tool/          Screenshot tooling
  docs/          Architecture, ADR, verification, and screenshots
  pubspec.yaml   Dependencies and SDK constraints
  pubspec.lock   Locked dependency versions
```

Run commands from `TheCode`:

```sh
cd TheCode
flutter pub get
flutter run -d chrome
```

For Android or iOS, choose the device shown by `flutter devices` and run
`flutter run -d <device-id>`. iOS builds require macOS and Xcode.

See the [project README](TheCode/README.md) for setup and checks, and the
[architecture](TheCode/docs/architecture.md) for the layered structure.
