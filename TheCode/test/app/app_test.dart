import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/app/demo_tasks.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/data/in_memory_task_repository.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_repository.dart';
import 'package:tarteeb/main.dart' as entry;

class CallbackTaskRepository implements TaskRepository {
  CallbackTaskRepository(this.fetch);
  final Future<List<Task>> Function(TaskMode) fetch;

  @override
  Future<List<Task>> fetchTasks(TaskMode mode) => fetch(mode);
}

Widget appWith(TaskRepository repository) => ProviderScope(
  overrides: [taskRepositoryProvider.overrideWithValue(repository)],
  child: const TarteebApp(),
);

void main() {
  testWidgets('default entry starts without Firebase and switches modes', (
    tester,
  ) async {
    entry.main();
    await tester.pumpAndSettle();
    expect(find.text('Campus tasks'), findsOneWidget);
    expect(find.text('Review lecture notes'), findsOneWidget);
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.text('Personal tasks'), findsOneWidget);
    expect(find.text('Review lecture notes'), findsNothing);
    expect(
      find.text('No tasks yet. Your plans will appear here.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Campus'));
    await tester.pumpAndSettle();
    expect(find.text('Review lecture notes'), findsOneWidget);
  });

  testWidgets('loading transitions to error and explicit retry recovers', (
    tester,
  ) async {
    final firstRequest = Completer<List<Task>>();
    final retryRequest = Completer<List<Task>>();
    var calls = 0;
    final repository = CallbackTaskRepository((mode) {
      calls++;
      return calls == 1 ? firstRequest.future : retryRequest.future;
    });
    await tester.pumpWidget(appWith(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    firstRequest.completeError(StateError('Private backend details'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tasks could not be loaded. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('Private backend'), findsNothing);
    expect(calls, 1);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    retryRequest.complete([
      const Task(id: 'c', title: 'Recovered task', mode: TaskMode.campus),
    ]);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Recovered task'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('late Campus response cannot replace Personal tasks', (
    tester,
  ) async {
    final campus = Completer<List<Task>>();
    final repository = CallbackTaskRepository((mode) async {
      if (mode == TaskMode.campus) return campus.future;
      return [
        const Task(id: 'p', title: 'Personal plan', mode: TaskMode.personal),
      ];
    });
    await tester.pumpWidget(appWith(repository));
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    campus.complete([
      const Task(id: 'c', title: 'Campus plan', mode: TaskMode.campus),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Personal plan'), findsOneWidget);
    expect(find.text('Campus plan'), findsNothing);
  });

  testWidgets('small viewport with large text can render and switch modes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(appWith(InMemoryTaskRepository(demoTasks)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Personal tasks'), findsOneWidget);
  });
}
