import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../application/task_providers.dart';
import '../domain/task_mode.dart';

/// Shared task sliver, placed after the screen heading in a CustomScrollView.
/// Headers and all async states can scroll together at large text sizes.
class TaskList extends ConsumerWidget {
  const TaskList({required this.mode, super.key});

  final TaskMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider(mode));
    return tasks.when(
      skipLoadingOnRefresh: false,
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading tasks'),
        ),
      ),
      error: (error, stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, color: theme.colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Tasks could not be loaded. Please try again.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
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
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Text(
                  'No tasks yet. Your plans will appear here.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.page),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => Card(
              child: ListTile(
                key: ValueKey(items[index].id),
                leading: const Icon(Icons.task_alt),
                title: Text(
                  items[index].title,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
