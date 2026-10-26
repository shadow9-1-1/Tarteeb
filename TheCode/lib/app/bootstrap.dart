import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/shared/tasks/application/task_providers.dart';
import '../features/shared/tasks/data/in_memory_task_repository.dart';
import 'demo_tasks.dart';
import 'tarteeb_app.dart';

/// The composition root selects infrastructure. Features only see contracts.
void bootstrap() {
  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWith(
          (ref) => InMemoryTaskRepository(demoTasks),
        ),
      ],
      child: const TarteebApp(),
    ),
  );
}
