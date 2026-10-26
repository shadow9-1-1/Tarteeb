import 'task.dart';
import 'task_mode.dart';

/// Returns only the selected mode's tasks; an empty list is a successful read.
/// Failures complete the future with an error, never an empty success result.
abstract interface class TaskRepository {
  Future<List<Task>> fetchTasks(TaskMode mode);
}
