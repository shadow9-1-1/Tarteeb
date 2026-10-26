import 'package:flutter/material.dart';

import '../../shared/tasks/domain/task_mode.dart';
import '../../shared/tasks/presentation/task_list.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text('Campus tasks', style: TextStyle(fontSize: 24)),
      ),
      Expanded(child: TaskList(mode: TaskMode.campus)),
    ],
  );
}
