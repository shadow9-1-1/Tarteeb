import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/task_providers.dart';
import '../domain/task_mode.dart';

/// Both modes share rendering and async-state handling here.
class TaskList extends ConsumerWidget {
  const TaskList({required this.mode, super.key});

  final TaskMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider(mode));
    return tasks.when(
      skipLoadingOnRefresh: false,
      loading: () => const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading tasks'),
      ),
      error: (error, stackTrace) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40),
              const SizedBox(height: 16),
              const Text('Tasks could not be loaded. Please try again.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(tasksProvider(mode)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No tasks yet. Your plans will appear here.'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => Card(
            child: ListTile(
              key: ValueKey(items[index].id),
              leading: const Icon(Icons.task_alt),
              title: Text(items[index].title),
            ),
          ),
        );
      },
    );
  }
}
