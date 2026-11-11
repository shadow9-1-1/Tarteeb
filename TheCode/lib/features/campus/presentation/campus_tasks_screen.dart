import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../shared/tasks/domain/task_mode.dart';
import '../../shared/tasks/presentation/task_list.dart';

class CampusTasksScreen extends StatelessWidget {
  const CampusTasksScreen({super.key});

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverToBoxAdapter(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.go('/campus'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Campus dashboard'),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Text(
            'Campus tasks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      const TaskList(mode: TaskMode.campus),
    ],
  );
}
