import 'task_mode.dart';

/// Domain data contains no Flutter, Riverpod, or Firebase types.
class Task {
  const Task({required this.id, required this.title, required this.mode});

  final String id;
  final String title;
  final TaskMode mode;
}
