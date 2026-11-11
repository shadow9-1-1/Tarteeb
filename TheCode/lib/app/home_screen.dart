import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_tokens.dart';
import '../core/widgets/app_error_banner.dart';
import 'routing/navigation_controller.dart';

/// Two mode branches keep independent navigation and scroll state.
class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.shell, required this.navigation, super.key});
  final StatefulNavigationShell shell;
  final NavigationController navigation;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: navigation,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Tarteeb'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: navigation.busy ? null : navigation.signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (navigation.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: AppErrorBanner(message: navigation.errorMessage!),
              ),
            Expanded(child: shell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
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
    ),
  );
}

class ModeWorkspace extends StatelessWidget {
  const ModeWorkspace({
    required this.workspaceLabel,
    required this.mode,
    required this.child,
    super.key,
  });
  final String workspaceLabel;
  final String mode;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: PageStorageKey(mode),
    restorationId: '${mode}Scroll',
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
            workspaceLabel,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      child,
    ],
  );
}
