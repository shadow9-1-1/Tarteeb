import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_loader.dart';
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
        child: Center(child: AppLoader(label: 'Loading tasks')),
      ),
      error: (error, stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Center(
            child: AppErrorBanner(
              message: 'Tasks could not be loaded. Please try again.',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(tasksProvider(mode)),
            ),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: AppEmptyState(
                message: 'No tasks yet. Your plans will appear here.',
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
