import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/features/campus/application/campus_providers.dart';
import 'package:tarteeb/features/campus/domain/campus_data.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/data/in_memory_task_repository.dart';

import '../support/navigation.dart';

GoRouter router(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
        as GoRouter;

Future<void> mount(
  WidgetTester tester, {
  Future<CampusData> Function()? source,
  String path = '/campus',
  bool signedIn = true,
  ThemeMode theme = ThemeMode.light,
}) async {
  final navigation = testNavigation(
    auth: TestAuthSession(authenticated: signedIn),
  );
  await navigation.initialize();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (source != null) campusSourceProvider.overrideWithValue(source),
        taskRepositoryProvider.overrideWithValue(InMemoryTaskRepository([])),
      ],
      child: TarteebApp(
        navigation: navigation,
        initialLocation: path,
        themeMode: theme,
        demoAccessEnabled: true,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'quick actions, event cards and courses open their relevant screens',
    (tester) async {
      await mount(tester);
      await tester.pumpAndSettle();
      expect(find.text('Your campus day'), findsOneWidget);
      for (final item in [
        ('Class schedule', 'classes', 'Usability testing studio'),
        ('Deadlines', 'deadlines', 'Usability reflection'),
        ('Resources', 'resources', 'Your resource shelf'),
        ('Campus tasks', 'tasks', 'No tasks yet. Your plans will appear here.'),
      ]) {
        await tapVisible(tester, find.text(item.$1));
        expect(
          router(tester).routeInformationProvider.value.uri.path,
          '/campus/${item.$2}',
        );
        expect(find.text(item.$3), findsOneWidget);
        await tapVisible(tester, find.text('Campus dashboard'));
      }
      await tapVisible(tester, find.text('Prototyping workshop'));
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        '/campus/courses/software',
      );
      expect(find.text('Phase 1 prototype'), findsOneWidget);
      expect(find.text('SQL practice set 4'), findsNothing);
      await tapVisible(tester, find.text('Campus dashboard'));
      await tapVisible(tester, find.text('Database Systems'));
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        '/campus/courses/database',
      );
      expect(find.text('SQL practice set 4'), findsOneWidget);
      expect(find.text('Phase 1 prototype'), findsNothing);
      router(tester).go('/campus/courses/missing');
      await tester.pumpAndSettle();
      expect(find.text('Course not found'), findsOneWidget);
    },
  );

  testWidgets(
    'nested Campus deep link stays guarded and is restored after sign-in',
    (tester) async {
      var requests = 0;
      await mount(
        tester,
        path: '/campus/courses/software',
        signedIn: false,
        source: () async {
          requests++;
          return sampleCampus;
        },
      );
      await tester.pumpAndSettle();
      expect(requests, 0);
      expect(find.text('Sign in to Tarteeb'), findsOneWidget);
      await tapVisible(tester, find.text('Enter demo workspace'));
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        '/campus/courses/software',
      );
      expect(find.text('Software Application Development'), findsOneWidget);
      expect(requests, 1);
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Campus'));
      await tester.pumpAndSettle();
      expect(
        router(tester).routeInformationProvider.value.uri.path,
        '/campus/courses/software',
      );
    },
  );

  testWidgets(
    'loading illustration, sanitized error and retry to empty state',
    (tester) async {
      final pending = Completer<CampusData>();
      var calls = 0;
      await mount(
        tester,
        source: () {
          calls++;
          return calls == 1 ? pending.future : Future.value(const CampusData());
        },
      );
      await tester.pump();
      expect(find.text('Loading your campus day'), findsOneWidget);
      pending.completeError(StateError('Private implementation detail'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Private implementation'), findsNothing);
      await tapVisible(tester, find.text('Retry'));
      expect(calls, 2);
      expect(find.text('A fresh semester'), findsOneWidget);
      expect(find.text('A little breathing room'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final (size, scale) in [
      (const Size(320, 568), 3.0),
      (const Size(1280, 900), 1.0),
    ]) {
      testWidgets('${theme.name} Campus pages fit $size at $scale text scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await mount(tester, theme: theme);
        for (final path in [
          '/campus',
          '/campus/classes',
          '/campus/deadlines',
          '/campus/courses',
          '/campus/courses/software',
          '/campus/resources',
        ]) {
          router(tester).go(path);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final paragraph in tester.renderObjectList<RenderParagraph>(
            find.byType(RichText),
          )) {
            expect(paragraph.didExceedMaxLines, isFalse);
          }
          await tester.drag(
            find.byType(CustomScrollView).last,
            const Offset(0, -6000),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
