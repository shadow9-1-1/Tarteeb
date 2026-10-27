import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/core/theme/app_theme.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/data/in_memory_task_repository.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_repository.dart';

class _RetryRepository implements TaskRepository {
  final first = Completer<List<Task>>();
  var requests = 0;

  @override
  Future<List<Task>> fetchTasks(TaskMode mode) {
    requests++;
    return requests == 1 ? first.future : Future.value([]);
  }
}

Widget _app(TaskRepository repository, {ThemeMode mode = ThemeMode.system}) =>
    ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(repository)],
      child: TarteebApp(themeMode: mode),
    );

void _viewport(WidgetTester tester, Size size, double scale) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

// Overflow exceptions alone miss silently truncated or height-clipped text.
void _expectFullParagraphs(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  for (final paragraph in tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  )) {
    expect(paragraph.didExceedMaxLines, isFalse);
    final painter = TextPainter(
      text: paragraph.text,
      textDirection: paragraph.textDirection,
      textScaler: paragraph.textScaler,
      strutStyle: paragraph.strutStyle,
      textHeightBehavior: paragraph.textHeightBehavior,
      locale: paragraph.locale,
    )..layout(maxWidth: paragraph.size.width);
    expect(
      paragraph.size.height + 0.01,
      greaterThanOrEqualTo(painter.height),
      reason: paragraph.text.toPlainText(),
    );
    painter.dispose();
  }
}

void main() {
  testWidgets('system brightness updates the shared app theme', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(_app(InMemoryTaskRepository([])));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme,
      AppTheme.light.colorScheme,
    );
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme,
      AppTheme.dark.colorScheme,
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scenario in [
      (const Size(320, 568), 1.0),
      (const Size(320, 568), 2.0),
      (const Size(320, 568), 3.0),
      (const Size(568, 320), 3.0),
    ]) {
      final (size, scale) = scenario;
      testWidgets(
        '${mode.name} $size at ${scale}x: both modes wrap long titles',
        (tester) async {
          _viewport(tester, size, scale);
          const title =
              'Prepare a detailed plan for the coming week and review '
              'all outstanding tasks with the study group';
          await tester.pumpWidget(
            _app(
              InMemoryTaskRepository([
                for (final taskMode in TaskMode.values)
                  Task(id: taskMode.name, title: title, mode: taskMode),
              ]),
              mode: mode,
            ),
          );
          await tester.pumpAndSettle();
          for (final label in ['Campus', 'Personal']) {
            if (label == 'Personal') {
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
            }
            await tester.scrollUntilVisible(find.text('$label tasks'), 100);
            final heading = tester.widget<Text>(find.text('$label tasks'));
            final theme = Theme.of(tester.element(find.text('$label tasks')));
            expect(heading.style, theme.textTheme.headlineSmall);
            await tester.scrollUntilVisible(find.text(title), 100);
            expect(
              tester.widget<Text>(find.text(title)).style,
              theme.textTheme.bodyLarge,
            );
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text(title),
                matching: find.byType(RichText),
              ),
            );
            expect(paragraph.textScaler.scale(16), 16 * scale);
            _expectFullParagraphs(tester);
            await Scrollable.ensureVisible(
              tester.element(find.byType(Card)),
              alignment: 1,
            );
            await tester.pumpAndSettle();
            _expectFullParagraphs(tester);
            final card = tester.getRect(find.byType(Card));
            final viewport = tester.getRect(find.byType(CustomScrollView));
            expect(card.bottom, lessThanOrEqualTo(viewport.bottom));
            expect(card.bottom, greaterThan(viewport.top));
          }
        },
      );
    }

    testWidgets(
      '${mode.name} 3x: loading, retry and empty states remain usable',
      (tester) async {
        _viewport(tester, const Size(320, 568), 3);
        final repository = _RetryRepository();
        await tester.pumpWidget(_app(repository, mode: mode));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.scrollUntilVisible(
          find.byType(CircularProgressIndicator),
          100,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        _expectFullParagraphs(tester);
        repository.first.completeError(StateError('Test error'));
        await tester.pumpAndSettle();
        _expectFullParagraphs(tester);
        await tester.ensureVisible(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Retry').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(repository.requests, 2);
        expect(
          find.text('No tasks yet. Your plans will appear here.'),
          findsOneWidget,
        );
        _expectFullParagraphs(tester);
      },
    );
  }
}
