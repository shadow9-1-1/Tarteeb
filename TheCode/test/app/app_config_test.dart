import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/app/bootstrap.dart';
import 'package:tarteeb/app/config/app_config.dart';

void main() {
  test('no configuration starts a credential-free development build', () {
    expect(AppConfig.parse().useDemoData, isTrue);
  });

  test('native production flavor cannot fall back to demo data', () {
    final config = AppConfig.parse(flavor: 'production');
    expect(config.environment, AppEnvironment.production);
    expect(config.useDemoData, isFalse);
  });

  test('public configuration samples select their matching native flavors', () {
    for (final environment in AppEnvironment.values) {
      final values = jsonDecode(
        File('config/${environment.name}.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(values.keys, ['APP_ENV']);
      final config = AppConfig.parse(
        environment: values['APP_ENV'] as String,
        flavor: environment.name,
      );
      expect(config.environment, environment);
    }
  });

  test('invalid environment or flavor mismatch is rejected', () {
    expect(() => AppConfig.parse(environment: 'prod'), throwsFormatException);
    expect(() => AppConfig.parse(flavor: 'unknown'), throwsFormatException);
    expect(
      () => AppConfig.parse(environment: 'production', flavor: 'development'),
      throwsFormatException,
    );
    expect(
      () => AppConfig.parse(environment: 'development', flavor: 'production'),
      throwsFormatException,
    );
  });

  testWidgets('production composition has no demo fixtures in either mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      createApp(const AppConfig(AppEnvironment.production)),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Preview workspace · Storage not connected'),
      findsOneWidget,
    );
    expect(find.text('Review lecture notes'), findsNothing);
    expect(
      find.text('No tasks yet. Your plans will appear here.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(
      find.text('No tasks yet. Your plans will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
