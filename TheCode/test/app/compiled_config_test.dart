import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/main.dart' as entry;

void main() {
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
      expect(
        find.text('Preview workspace · Storage not connected'),
        findsOneWidget,
      );
      expect(find.text('Review lecture notes'), findsNothing);
    } else {
      expect(find.text('Review lecture notes'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
