import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_banner.dart';
import '../../core/widgets/app_loader.dart';
import 'navigation_controller.dart';

enum AccessStep { launch, onboarding, signIn }

class AccessScreen extends StatelessWidget {
  const AccessScreen({
    required this.step,
    required this.navigation,
    required this.demoAccessEnabled,
    super.key,
  });
  final AccessStep step;
  final NavigationController navigation;
  final bool demoAccessEnabled;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: navigation,
    builder: (context, _) {
      final theme = Theme.of(context);
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (step == AccessStep.launch)
                    if (navigation.startupFailed)
                      AppErrorBanner(
                        message: 'Tarteeb could not start. Please try again.',
                        actionLabel: 'Retry',
                        onAction: navigation.retryStartup,
                      )
                    else
                      const AppLoader(label: 'Starting Tarteeb')
                  else ...[
                    Semantics(
                      header: true,
                      child: Text(
                        step == AccessStep.onboarding
                            ? 'Welcome to Tarteeb'
                            : 'Sign in to Tarteeb',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      step == AccessStep.onboarding
                          ? 'Organize your Campus and Personal plans in two separate spaces.'
                          : demoAccessEnabled
                          ? 'Explore a demo workspace with fictional sample data. No account is created.'
                          : navigation.auth.canSignIn
                          ? 'Sign in to continue to your workspace.'
                          : 'Account sign-in is not connected in this build.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (navigation.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppErrorBanner(message: navigation.errorMessage!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: step == AccessStep.onboarding
                          ? 'Get started'
                          : demoAccessEnabled
                          ? 'Enter demo workspace'
                          : 'Sign in',
                      loadingLabel: step == AccessStep.onboarding
                          ? 'Saving setup'
                          : 'Signing in',
                      isLoading: navigation.busy,
                      onPressed: step == AccessStep.onboarding
                          ? navigation.completeOnboarding
                          : navigation.auth.canSignIn
                          ? navigation.signIn
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
