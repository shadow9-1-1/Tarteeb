import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import 'onboarding_frame.dart';

class AccountEntryScreen extends StatelessWidget {
  const AccountEntryScreen({
    required this.registration,
    required this.demo,
    required this.onExplore,
    required this.onAlternate,
    required this.onBack,
    this.onSignIn,
    this.busy = false,
    this.errorMessage,
    super.key,
  });
  final bool registration;
  final bool demo;
  final VoidCallback onExplore;
  final VoidCallback onAlternate;
  final VoidCallback onBack;
  final VoidCallback? onSignIn;
  final bool busy;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => OnboardingFrame(
    title: registration
        ? 'Your next chapter starts here'
        : 'Sign in to Tarteeb',
    subtitle: registration
        ? 'A place for your campus life and personal goals.'
        : 'A little order. A little more breathing room.',
    onBack: busy ? null : onBack,
    children: [
      IntroductionCard(
        icon: registration ? Icons.person_add_alt : Icons.login,
        title: registration
            ? 'Create an account'
            : demo
            ? 'Try the demo workspace'
            : 'Your account',
        message: registration
            ? 'Account creation is not available in this preview. You can explore both spaces without sharing an email or password.'
            : demo
            ? 'Enter a demo workspace with fictional sample data. No account is created.'
            : onSignIn == null
            ? 'Account sign-in is not connected in this build. You can still explore the sample dashboards.'
            : 'Continue to sign in to your workspace.',
      ),
      if (errorMessage != null) ...[
        const SizedBox(height: AppSpacing.md),
        AppErrorBanner(message: errorMessage!),
      ],
      const SizedBox(height: AppSpacing.lg),
      if (registration)
        const AppButton(label: 'Create account', onPressed: null)
      else
        AppButton(
          label: demo ? 'Enter demo workspace' : 'Sign in',
          loadingLabel: 'Signing in',
          isLoading: busy,
          onPressed: onSignIn,
        ),
      const SizedBox(height: AppSpacing.sm),
      AppButton(
        label: 'Explore the spaces',
        variant: AppButtonVariant.secondary,
        onPressed: busy ? null : onExplore,
      ),
      const SizedBox(height: AppSpacing.sm),
      AppButton(
        label: registration
            ? 'Already have an account? Sign in'
            : 'New here? Create account',
        variant: AppButtonVariant.text,
        onPressed: busy ? null : onAlternate,
      ),
    ],
  );
}
