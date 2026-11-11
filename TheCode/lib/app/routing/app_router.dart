import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../features/campus/presentation/campus_screen.dart';
import '../../features/personal/presentation/personal_screen.dart';
import '../home_screen.dart';
import 'access_screen.dart';
import 'app_routes.dart';
import 'navigation_controller.dart';

String? navigationRedirect(NavigationController navigation, Uri uri) {
  final requested =
      AppRoutes.destination(uri.toString()) ??
      AppRoutes.destination(uri.queryParameters['from']);
  String gate(String path) => Uri(
    path: path,
    queryParameters: requested == null ? null : {'from': requested},
  ).toString();
  if (!navigation.ready) {
    return uri.path == AppRoutes.launchPath ? null : gate(AppRoutes.launchPath);
  }
  if (!navigation.onboarded) {
    return uri.path == AppRoutes.onboardingPath
        ? null
        : gate(AppRoutes.onboardingPath);
  }
  if (!navigation.auth.isAuthenticated) {
    return uri.path == AppRoutes.signInPath ? null : gate(AppRoutes.signInPath);
  }
  if ([
    '/',
    AppRoutes.launchPath,
    AppRoutes.onboardingPath,
    AppRoutes.signInPath,
  ].contains(uri.path)) {
    return requested ?? navigation.lastLocation;
  }
  return null;
}

GoRouter createAppRouter({
  required NavigationController navigation,
  required String workspaceLabel,
  required bool demoAccessEnabled,
  String? initialLocation,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: navigation,
  restorationScopeId: 'router',
  redirect: (context, state) => navigationRedirect(navigation, state.uri),
  routes: [
    GoRoute(path: '/', redirect: (context, state) => AppRoutes.launchPath),
    for (final (name, path, step) in [
      (AppRoutes.launch, AppRoutes.launchPath, AccessStep.launch),
      (AppRoutes.onboarding, AppRoutes.onboardingPath, AccessStep.onboarding),
      (AppRoutes.signIn, AppRoutes.signInPath, AccessStep.signIn),
    ])
      GoRoute(
        name: name,
        path: path,
        builder: (context, state) => AccessScreen(
          step: step,
          navigation: navigation,
          demoAccessEnabled: demoAccessEnabled,
        ),
      ),
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'modeShell',
      pageBuilder: (context, state, shell) => MaterialPage<void>(
        key: state.pageKey,
        restorationId: 'modeShellPage',
        child: HomeScreen(shell: shell, navigation: navigation),
      ),
      branches: [
        StatefulShellBranch(
          restorationScopeId: 'campusNavigator',
          routes: [
            GoRoute(
              name: AppRoutes.campus,
              path: AppRoutes.campusPath,
              builder: (context, state) => ModeWorkspace(
                workspaceLabel: workspaceLabel,
                mode: 'campus',
                child: const CampusScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'personalNavigator',
          routes: [
            GoRoute(
              name: AppRoutes.personal,
              path: AppRoutes.personalPath,
              builder: (context, state) => ModeWorkspace(
                workspaceLabel: workspaceLabel,
                mode: 'personal',
                child: const PersonalScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: AppEmptyState(
            title: 'Page not found',
            message: 'This link is not available.',
            actionLabel: 'Go to home',
            onAction: () => context.go('/'),
          ),
        ),
      ),
    ),
  ),
);
