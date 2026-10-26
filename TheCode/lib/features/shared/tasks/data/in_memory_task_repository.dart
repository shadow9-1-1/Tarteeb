import '../domain/task.dart';
import '../domain/task_mode.dart';
import '../domain/task_repository.dart';

/// A deterministic, credential-free adapter for the architecture starter.
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository(Iterable<Task> tasks)
    : _tasks = List.unmodifiable(tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> fetchTasks(TaskMode mode) async =>
      List.unmodifiable(_tasks.where((task) => task.mode == mode));
}
