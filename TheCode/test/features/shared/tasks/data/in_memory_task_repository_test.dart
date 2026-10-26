import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/features/shared/tasks/data/in_memory_task_repository.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';

void main() {
  const campus = Task(id: 'c', title: 'Study', mode: TaskMode.campus);
  const personal = Task(id: 'p', title: 'Read', mode: TaskMode.personal);

  test('one repository keeps Campus and Personal results separate', () async {
    final repository = InMemoryTaskRepository([campus, personal]);
    expect(await repository.fetchTasks(TaskMode.campus), [campus]);
    expect(await repository.fetchTasks(TaskMode.personal), [personal]);
  });

  test('an empty mode is a successful empty read', () async {
    final repository = InMemoryTaskRepository([campus]);
    expect(await repository.fetchTasks(TaskMode.personal), isEmpty);
  });

  test('callers cannot mutate stored tasks through input or results', () async {
    final input = [campus];
    final repository = InMemoryTaskRepository(input);
    input.clear();
    final result = await repository.fetchTasks(TaskMode.campus);
    expect(result, [campus]);
    expect(() => result.clear(), throwsUnsupportedError);
    expect(await repository.fetchTasks(TaskMode.campus), [campus]);
  });
}
