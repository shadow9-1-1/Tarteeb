import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tarteeb/app/routing/app_routes.dart';
import 'package:tarteeb/app/routing/navigation_controller.dart';
import 'package:tarteeb/app/routing/auth_session.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_repository.dart';

import '../support/navigation.dart';

class _Tasks implements TaskRepository {
  final calls = <TaskMode>[];
  @override
  Future<List<Task>> fetchTasks(TaskMode mode) async {
    calls.add(mode);
    return [];
  }
}

Widget _app(
  NavigationController navigation, {
  String? location,
  bool demo = true,
  ThemeMode theme = ThemeMode.light,
  TaskRepository? tasks,
}) => ProviderScope(
  key: ObjectKey(navigation),
  overrides: [
    if (tasks != null) taskRepositoryProvider.overrideWithValue(tasks),
  ],
  child: TarteebApp(
    navigation: navigation,
    initialLocation: location,
    demoAccessEnabled: demo,
    themeMode: theme,
  ),
);

void main() {
  for (final mode in ['Campus', 'Personal']) {
    testWidgets(
      '$mode choice previews only sample data and opens the matching workspace',
      (tester) async {
        final store = MemoryNavigationStore();
        final auth = TestAuthSession(authenticated: false);
        final navigation = testNavigation(auth: auth, store: store);
        final tasks = _Tasks();
        await tester.pumpWidget(_app(navigation, tasks: tasks));
        await tester.pumpAndSettle();
        expect(find.text('Welcome to Tarteeb'), findsOneWidget);
        await tapVisible(tester, find.text('Get started'));
        expect(find.text('Your plans. Your choice.'), findsOneWidget);
        expect(
          find.textContaining('Notifications are not enabled'),
          findsOneWidget,
        );
        await tapVisible(tester, find.text('Choose your space'));
        expect(find.text('Choose your starting space'), findsOneWidget);
        final selection = tester
            .getSemantics(find.bySemanticsLabel('Preview $mode'))
            .getSemanticsData();
        expect(selection.flagsCollection.isButton, isTrue);
        expect(selection.hasAction(SemanticsAction.tap), isTrue);
        await tapVisible(tester, find.bySemanticsLabel('Preview $mode'));
        expect(find.text('$mode dashboard preview'), findsOneWidget);
        expect(
          find.text(mode == 'Campus' ? 'Study group' : 'Morning walk'),
          findsOneWidget,
        );
        expect(
          find.text(mode == 'Campus' ? 'Morning walk' : 'Study group'),
          findsNothing,
        );
        expect(tasks.calls, isEmpty);
        expect(auth.isAuthenticated, isFalse);
        expect(store.snapshot.onboarded, isFalse);
        await tapVisible(tester, find.text('Continue with $mode'));
        expect(store.snapshot.onboarded, isTrue);
        expect(store.snapshot.location, '/${mode.toLowerCase()}');
        expect(find.text('Sign in to Tarteeb'), findsOneWidget);
        await tapVisible(tester, find.text('Enter demo workspace'));
        expect(find.text('$mode tasks'), findsOneWidget);
        expect(tasks.calls, mode == 'Campus' ? isEmpty : [TaskMode.personal]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('welcome account entry points work without creating an account', (
    tester,
  ) async {
    final auth = TestAuthSession(authenticated: false);
    final navigation = testNavigation(
      auth: auth,
      store: MemoryNavigationStore(),
    );
    await tester.pumpWidget(_app(navigation));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Create account'));
    expect(find.text('Your next chapter starts here'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.textContaining('Account creation is not available'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Already have an account? Sign in'));
    expect(find.text('Sign in to Tarteeb'), findsOneWidget);
    await tapVisible(tester, find.text('Enter demo workspace'));
    expect(find.text('Your plans. Your choice.'), findsOneWidget);
    expect(auth.isAuthenticated, isFalse);
    expect(navigation.onboarded, isFalse);
  });

  testWidgets(
    'compare and back preserve intent; confirmed choice survives relaunch',
    (tester) async {
      final store = MemoryNavigationStore();
      var navigation = testNavigation(
        auth: TestAuthSession(authenticated: false),
        store: store,
      );
      await tester.pumpWidget(
        _app(navigation, location: AppRoutes.campusPreviewPath),
      );
      await tester.pumpAndSettle();
      expect(find.text('Campus dashboard preview'), findsOneWidget);
      await tapVisible(tester, find.text('Compare the other space'));
      await tapVisible(tester, find.bySemanticsLabel('Preview Personal'));
      await tapVisible(tester, find.byTooltip('Back'));
      expect(find.text('Choose your starting space'), findsOneWidget);
      await tapVisible(tester, find.bySemanticsLabel('Preview Personal'));
      await tapVisible(tester, find.text('Continue with Personal'));
      navigation = testNavigation(
        auth: TestAuthSession(authenticated: false),
        store: store,
      );
      await tester.pumpWidget(_app(navigation, tasks: _Tasks()));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      await tapVisible(tester, find.text('Enter demo workspace'));
      expect(find.text('Personal tasks'), findsOneWidget);
    },
  );

  testWidgets(
    'production previews are public but protected dashboards remain locked',
    (tester) async {
      final tasks = _Tasks();
      final navigation = testNavigation(
        auth: SignedOutAuthSession(),
        store: MemoryNavigationStore(),
      );
      await tester.pumpWidget(
        _app(
          navigation,
          demo: false,
          location: AppRoutes.personalPreviewPath,
          tasks: tasks,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Personal dashboard preview'), findsOneWidget);
      await tapVisible(tester, find.text('Continue with Personal'));
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      expect(find.text('Enter demo workspace'), findsNothing);
      final router = GoRouter.of(tester.element(find.byType(Scaffold)));
      router.goNamed(AppRoutes.personal);
      await tester.pumpAndSettle();
      expect(find.text('Personal tasks'), findsNothing);
      expect(tasks.calls, isEmpty);
      router.go('/register');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Explore the spaces'));
      expect(find.text('Your plans. Your choice.'), findsOneWidget);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      '${dark ? 'dark' : 'light'} introduction scales to 3x without text clipping',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        for (final path in AppRoutes.publicPaths) {
          final navigation = testNavigation(
            auth: TestAuthSession(authenticated: false),
            store: MemoryNavigationStore(),
          );
          await tester.pumpWidget(
            _app(
              navigation,
              location: path,
              theme: dark ? ThemeMode.dark : ThemeMode.light,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: path);
          for (final paragraph in tester.renderObjectList<RenderParagraph>(
            find.byType(RichText),
          )) {
            expect(
              paragraph.didExceedMaxLines,
              isFalse,
              reason: '$path: ${paragraph.text.toPlainText()}',
            );
          }
          final buttons = find.byType(TextButton);
          if (buttons.evaluate().isNotEmpty) {
            await tester.ensureVisible(buttons.last);
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull, reason: path);
        }
      },
    );
  }
}
