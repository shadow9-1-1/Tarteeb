import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/main.dart' as entry;

import '../support/navigation.dart';

void main() {
  setUp(mockNavigationPreferences);
  // Run this file separately with production defines or mismatched native flavor
  // to verify compile-time values actually reach the real entry point.
  testWidgets('compiled configuration reaches bootstrap', (tester) async {
    entry.main();
    await tester.pumpAndSettle();
    const environment = String.fromEnvironment('APP_ENV');
    const flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    if (environment == 'production' && flavor == 'development') {
      expect(
        find.text(
          'This build is not configured correctly. Please contact the app team.',
        ),
        findsOneWidget,
      );
      expect(find.text('Campus tasks'), findsNothing);
    } else if (environment == 'production' || flavor == 'production') {
      await finishIntroduction(tester);
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      expect(find.text('Review lecture notes'), findsNothing);
    } else {
      await enterDemo(tester);
      expect(find.text('Review lecture notes'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
