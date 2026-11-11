import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../features/campus/presentation/campus_screen.dart';
import '../../features/personal/presentation/personal_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/privacy_screen.dart';
import '../../features/onboarding/presentation/mode_selection_screen.dart';
import '../../features/onboarding/presentation/dashboard_preview_screen.dart';
import '../../features/onboarding/presentation/account_entry_screen.dart';
import '../../features/shared/tasks/domain/task_mode.dart';
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
    if (uri.path == AppRoutes.launchPath) return null;
    final next = AppRoutes.publicLocation(uri.toString());
    return Uri(
      path: AppRoutes.launchPath,
      queryParameters: {'from': ?requested, 'next': ?next},
    ).toString();
  }
  if (uri.path == AppRoutes.launchPath) {
    final next = AppRoutes.publicLocation(uri.queryParameters['next']);
    if (next != null) return next;
  }
  if (!navigation.onboarded) {
    return AppRoutes.publicPaths.contains(uri.path)
        ? null
        : gate(AppRoutes.onboardingPath);
  }
  if (!navigation.auth.isAuthenticated) {
    return AppRoutes.publicPaths.contains(uri.path)
        ? null
        : gate(AppRoutes.signInPath);
  }
  if ([
    '/',
    AppRoutes.launchPath,
    AppRoutes.onboardingPath,
    AppRoutes.signInPath,
    ...AppRoutes.publicPaths,
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
    GoRoute(
      name: AppRoutes.launch,
      path: AppRoutes.launchPath,
      builder: (context, state) => AccessScreen(navigation: navigation),
    ),
    GoRoute(
      name: AppRoutes.onboarding,
      path: AppRoutes.onboardingPath,
      builder: (context, state) => WelcomeScreen(
        onStart: () => context.go(
          AppRoutes.entry(
            AppRoutes.privacyPath,
            from: state.uri.queryParameters['from'],
          ),
        ),
        onRegister: () => context.go(
          AppRoutes.entry(
            AppRoutes.registerPath,
            from: state.uri.queryParameters['from'],
          ),
        ),
        onSignIn: () => context.go(
          AppRoutes.entry(
            AppRoutes.signInPath,
            from: state.uri.queryParameters['from'],
          ),
        ),
      ),
    ),
    GoRoute(
      name: AppRoutes.privacy,
      path: AppRoutes.privacyPath,
      builder: (context, state) => PrivacyScreen(
        onBack: () => context.go(
          AppRoutes.entry(
            AppRoutes.onboardingPath,
            from: state.uri.queryParameters['from'],
          ),
        ),
        onContinue: () => context.go(
          AppRoutes.entry(
            AppRoutes.chooseModePath,
            from: state.uri.queryParameters['from'],
          ),
        ),
      ),
    ),
    GoRoute(
      name: AppRoutes.chooseMode,
      path: AppRoutes.chooseModePath,
      builder: (context, state) => ModeSelectionScreen(
        suggestedMode: switch (AppRoutes.destination(
          state.uri.queryParameters['from'],
        )) {
          AppRoutes.campusPath => TaskMode.campus,
          AppRoutes.personalPath => TaskMode.personal,
          _ => null,
        },
        onBack: () => context.go(
          AppRoutes.entry(
            AppRoutes.privacyPath,
            from: state.uri.queryParameters['from'],
          ),
        ),
        onSelect: (mode) => context.go(
          mode == TaskMode.campus
              ? AppRoutes.campusPreviewPath
              : AppRoutes.personalPreviewPath,
        ),
      ),
    ),
    for (final (name, path, mode, destination) in [
      (
        AppRoutes.campusPreview,
        AppRoutes.campusPreviewPath,
        TaskMode.campus,
        AppRoutes.campusPath,
      ),
      (
        AppRoutes.personalPreview,
        AppRoutes.personalPreviewPath,
        TaskMode.personal,
        AppRoutes.personalPath,
      ),
    ])
      GoRoute(
        name: name,
        path: path,
        builder: (context, state) => ListenableBuilder(
          listenable: navigation,
          builder: (context, _) => DashboardPreviewScreen(
            mode: mode,
            busy: navigation.busy,
            errorMessage: navigation.errorMessage,
            onBack: () => context.go(
              AppRoutes.entry(AppRoutes.chooseModePath, from: destination),
            ),
            onContinue: () async {
              await navigation.completeOnboarding(location: destination);
              if (context.mounted &&
                  navigation.onboarded &&
                  navigation.errorMessage == null) {
                context.go(
                  AppRoutes.entry(AppRoutes.signInPath, from: destination),
                );
              }
            },
          ),
        ),
      ),
    for (final (name, path, registration) in [
      (AppRoutes.signIn, AppRoutes.signInPath, false),
      (AppRoutes.register, AppRoutes.registerPath, true),
    ])
      GoRoute(
        name: name,
        path: path,
        builder: (context, state) => ListenableBuilder(
          listenable: navigation,
          builder: (context, _) => AccountEntryScreen(
            registration: registration,
            demo: demoAccessEnabled,
            busy: navigation.busy,
            errorMessage: navigation.errorMessage,
            onBack: () => context.go(
              AppRoutes.entry(
                AppRoutes.onboardingPath,
                from: state.uri.queryParameters['from'],
              ),
            ),
            onExplore: () => context.go(
              AppRoutes.entry(
                AppRoutes.privacyPath,
                from: state.uri.queryParameters['from'],
              ),
            ),
            onAlternate: () => context.go(
              AppRoutes.entry(
                registration ? AppRoutes.signInPath : AppRoutes.registerPath,
                from: state.uri.queryParameters['from'],
              ),
            ),
            onSignIn: !navigation.auth.canSignIn
                ? null
                : () {
                    if (!navigation.onboarded) {
                      context.go(
                        AppRoutes.entry(
                          AppRoutes.privacyPath,
                          from: state.uri.queryParameters['from'],
                        ),
                      );
                    } else {
                      navigation.signIn();
                    }
                  },
          ),
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
