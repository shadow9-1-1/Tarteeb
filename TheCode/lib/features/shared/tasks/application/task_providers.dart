import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task.dart';
import '../domain/task_mode.dart';
import '../domain/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) =>
      throw StateError('Configure TaskRepository at the app composition root.'),
);

final tasksProvider = FutureProvider.autoDispose.family<List<Task>, TaskMode>(
  (ref, mode) => ref.watch(taskRepositoryProvider).fetchTasks(mode),
  // Show a stable error with explicit retry instead of hidden background retries.
  retry: (retryCount, error) => null,
);
