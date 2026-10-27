import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';
import '../features/campus/presentation/campus_screen.dart';
import '../features/personal/presentation/personal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.workspaceLabel, super.key});

  final String workspaceLabel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tarteeb')),
      body: SafeArea(
        child: CustomScrollView(
          key: ValueKey(_selectedIndex),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: Text(
                  widget.workspaceLabel,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            _selectedIndex == 0 ? const CampusScreen() : const PersonalScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Campus',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Personal',
          ),
        ],
      ),
    );
  }
}
