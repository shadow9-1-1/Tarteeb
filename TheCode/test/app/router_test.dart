import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarteeb/app/bootstrap.dart';
import 'package:tarteeb/app/config/app_config.dart';
import 'package:tarteeb/app/routing/app_router.dart';
import 'package:tarteeb/app/routing/app_routes.dart';
import 'package:tarteeb/app/routing/navigation_controller.dart';
import 'package:tarteeb/app/routing/navigation_store.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_repository.dart';

import '../support/navigation.dart';

class RecordingRepository implements TaskRepository {
  final calls = <TaskMode>[];
  @override
  Future<List<Task>> fetchTasks(TaskMode mode) async {
    calls.add(mode);
    return [
      for (var i = 0; i < 30; i++)
        Task(id: '${mode.name}-$i', title: '${mode.name} plan $i', mode: mode),
    ];
  }
}

Widget app(
  NavigationController navigation, {
  String? location,
  TaskRepository? repository,
}) => ProviderScope(
  overrides: [
    taskRepositoryProvider.overrideWithValue(
      repository ?? RecordingRepository(),
    ),
  ],
  child: TarteebApp(
    navigation: navigation,
    initialLocation: location,
    demoAccessEnabled: true,
  ),
);

GoRouter router(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
        as GoRouter;

void main() {
  setUp(mockNavigationPreferences);

  for (final target in [AppRoutes.campusPath, AppRoutes.personalPath]) {
    testWidgets('signed-out users cannot build $target or fetch its data', (
      tester,
    ) async {
      final auth = TestAuthSession(authenticated: false);
      final navigation = testNavigation(auth: auth);
      final repository = RecordingRepository();
      await tester.pumpWidget(
        app(navigation, location: target, repository: repository),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(repository.calls, isEmpty);
      router(tester).go(target);
      await tester.pumpAndSettle();
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        AppRoutes.signInPath,
      );
      expect(repository.calls, isEmpty);
      await tester.tap(find.text('Enter demo workspace'));
      await tester.pumpAndSettle();
      expect(router(tester).routeInformationProvider.value.uri.path, target);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        target == AppRoutes.campusPath ? 0 : 1,
      );
    });
  }

  testWidgets(
    'startup waits for auth and preserves deep link through onboarding',
    (tester) async {
      final restored = Completer<void>();
      final auth = TestAuthSession(authenticated: false)
        ..restoration = restored.future;
      final store = MemoryNavigationStore();
      final navigation = testNavigation(auth: auth, store: store);
      final repository = RecordingRepository();
      await tester.pumpWidget(
        app(navigation, location: '/personal', repository: repository),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Starting Tarteeb'), findsOneWidget);
      expect(repository.calls, isEmpty);
      restored.complete();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Tarteeb'), findsOneWidget);
      router(tester).go('/sign-in?from=%2Fpersonal');
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Tarteeb'), findsOneWidget);
      await enterDemo(tester);
      expect(find.text('Personal tasks'), findsOneWidget);
      expect(store.snapshot.onboarded, isTrue);
      expect(store.snapshot.location, '/personal');
      expect(repository.calls, [TaskMode.personal]);
    },
  );

  testWidgets('mode branches retain scroll and do not mix their data', (
    tester,
  ) async {
    final navigation = await readyNavigation();
    final repository = RecordingRepository();
    await tester.pumpWidget(app(navigation, repository: repository));
    await tester.pumpAndSettle();
    expect(router(tester).namedLocation(AppRoutes.campus), '/campus');
    expect(router(tester).namedLocation(AppRoutes.personal), '/personal');
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final offset = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.text('personal plan 0'), findsOneWidget);
    expect(find.textContaining('campus plan'), findsNothing);
    await tester.tap(find.text('Campus'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      offset,
    );
    expect(repository.calls, [TaskMode.campus, TaskMode.personal]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'session expiry removes both protected branches and guards back navigation',
    (tester) async {
      final auth = TestAuthSession();
      final navigation = testNavigation(auth: auth);
      await tester.pumpWidget(app(navigation));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      expect(find.text('Campus tasks', skipOffstage: false), findsNothing);
      expect(find.text('Personal tasks', skipOffstage: false), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      router(tester).goNamed(AppRoutes.personal);
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      await tester.tap(find.text('Enter demo workspace'));
      await tester.pumpAndSettle();
      expect(find.text('Personal tasks'), findsOneWidget);
      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
    },
  );

  testWidgets(
    'fresh launch restores preferences; explicit links take precedence',
    (tester) async {
      final store = PreferencesNavigationStore(namespace: 'test');
      await store.write(const NavigationSnapshot(onboarded: true));
      var navigation = testNavigation(store: store);
      await tester.pumpWidget(app(navigation));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();
      expect((await store.read()).location, '/personal');
      await tester.pumpWidget(const SizedBox.shrink());
      navigation = testNavigation(
        store: PreferencesNavigationStore(namespace: 'test'),
      );
      await tester.pumpWidget(app(navigation));
      await tester.pumpAndSettle();
      expect(find.text('Personal tasks'), findsOneWidget);
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      expect(find.text('Personal tasks'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        app(testNavigation(store: store), location: '/campus'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Campus tasks'), findsOneWidget);
    },
  );

  testWidgets('restoring old navigation cannot revive an expired session', (
    tester,
  ) async {
    final auth = TestAuthSession();
    final navigation = testNavigation(auth: auth);
    await tester.pumpWidget(app(navigation, location: '/personal'));
    await tester.pumpAndSettle();
    final restoration = await tester.getRestorationData();
    await auth.signOut();
    await tester.pumpAndSettle();
    await tester.restoreFrom(restoration);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to Tarteeb'), findsOneWidget);
    expect(find.text('Personal tasks', skipOffstage: false), findsNothing);
  });

  testWidgets('saved mode cannot authenticate; production has no demo bypass', (
    tester,
  ) async {
    final store = PreferencesNavigationStore(namespace: 'production');
    await store.write(
      const NavigationSnapshot(onboarded: true, location: '/personal'),
    );
    await tester.pumpWidget(
      createApp(const AppConfig(AppEnvironment.production)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in to Tarteeb'), findsOneWidget);
    expect(find.text('Enter demo workspace'), findsNothing);
    router(tester).go('/personal');
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Review lecture notes'), findsNothing);
  });

  testWidgets(
    'startup errors are retryable without rendering protected content',
    (tester) async {
      final store = MemoryNavigationStore()..fail = true;
      final navigation = testNavigation(store: store);
      await tester.pumpWidget(app(navigation, location: '/personal'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tarteeb could not start. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
      store.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Tarteeb'), findsOneWidget);
      store.fail = true;
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(
        find.text('Your setup could not be saved. Please try again.'),
        findsOneWidget,
      );
      expect(navigation.onboarded, isFalse);
      store.fail = false;
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.text('Personal tasks'), findsOneWidget);
    },
  );

  testWidgets('unknown authenticated route has a safe way home', (
    tester,
  ) async {
    await tester.pumpWidget(app(await readyNavigation(), location: '/missing'));
    await tester.pumpAndSettle();
    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go to home'));
    await tester.pumpAndSettle();
    expect(find.text('Campus tasks'), findsOneWidget);
  });

  test(
    'return URLs cannot redirect outside the supported mode routes',
    () async {
      final navigation = await readyNavigation();
      for (final value in [
        'https://example.com/personal',
        '//example.com/personal',
        '/sign-in',
        '/missing',
        '/personal/../../sign-in',
      ]) {
        expect(AppRoutes.destination(value), isNull);
        final uri = Uri(path: '/sign-in', queryParameters: {'from': value});
        expect(navigationRedirect(navigation, uri), '/campus');
      }
    },
  );

  test(
    'corrupt preferences fall back safely and namespaces stay separate',
    () async {
      await SharedPreferencesAsync().setString(
        'tarteeb.test.navigation.v1',
        '{bad json',
      );
      final store = PreferencesNavigationStore(namespace: 'test');
      expect((await store.read()).onboarded, isFalse);
      await store.write(
        const NavigationSnapshot(onboarded: true, location: '/personal'),
      );
      expect((await store.read()).location, '/personal');
      expect(
        (await PreferencesNavigationStore(
          namespace: 'production',
        ).read()).onboarded,
        isFalse,
      );
    },
  );
}
