import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../shared/tasks/domain/task_mode.dart';
import '../../shared/tasks/presentation/task_list.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Text(
            'Personal tasks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      const TaskList(mode: TaskMode.personal),
    ],
  );
}
