import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tarteeb/app/routing/auth_session.dart';
import 'package:tarteeb/app/routing/navigation_controller.dart';
import 'package:tarteeb/app/routing/navigation_store.dart';

class MemoryNavigationStore implements NavigationStore {
  MemoryNavigationStore([this.snapshot = const NavigationSnapshot()]);
  NavigationSnapshot snapshot;
  bool fail = false;
  @override
  Future<NavigationSnapshot> read() async {
    if (fail) throw StateError('Synthetic storage failure');
    return snapshot;
  }

  @override
  Future<void> write(NavigationSnapshot value) async {
    if (fail) throw StateError('Synthetic storage failure');
    snapshot = value;
  }
}

class TestAuthSession extends AuthSession {
  TestAuthSession({this.authenticated = true});
  bool authenticated;
  Future<void>? restoration;
  @override
  bool get isAuthenticated => authenticated;
  @override
  bool get canSignIn => true;
  @override
  Future<void> restore() async {
    await restoration;
  }

  @override
  Future<void> signIn() async {
    authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    authenticated = false;
    notifyListeners();
  }
}

NavigationController testNavigation({
  AuthSession? auth,
  NavigationStore? store,
}) {
  final session = auth ?? TestAuthSession();
  final navigation = NavigationController(
    auth: session,
    store:
        store ??
        MemoryNavigationStore(const NavigationSnapshot(onboarded: true)),
  );
  addTearDown(() {
    navigation.dispose();
    session.dispose();
  });
  return navigation;
}

Future<NavigationController> readyNavigation() async {
  final navigation = testNavigation();
  await navigation.initialize();
  return navigation;
}

void mockNavigationPreferences() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> finishIntroduction(WidgetTester tester, {String? mode}) async {
  await tester.pumpAndSettle();
  final uri = GoRouter.of(tester.element(find.byType(Scaffold)))
      .routeInformationProvider
      .value
      .uri;
  final selected =
      mode ??
      (uri.queryParameters['from'] == '/personal' ||
              uri.path == '/preview/personal'
          ? 'Personal'
          : 'Campus');
  if (find.text('Get started').evaluate().isNotEmpty) {
    await tapVisible(tester, find.text('Get started'));
  }
  if (find.text('Choose your space').evaluate().isNotEmpty) {
    await tapVisible(tester, find.text('Choose your space'));
  }
  if (find.text('Choose your starting space').evaluate().isNotEmpty) {
    await tapVisible(tester, find.bySemanticsLabel('Preview $selected'));
  }
  await tapVisible(tester, find.text('Continue with $selected'));
}

Future<void> enterDemo(WidgetTester tester) async {
  await tester.pumpAndSettle();
  if (find.text('Get started').evaluate().isNotEmpty) {
    await finishIntroduction(tester);
  }
  await tapVisible(tester, find.text('Enter demo workspace'));
  if (find.text('Choose your space').evaluate().isNotEmpty) {
    await finishIntroduction(tester);
    await tapVisible(tester, find.text('Enter demo workspace'));
  }
}
