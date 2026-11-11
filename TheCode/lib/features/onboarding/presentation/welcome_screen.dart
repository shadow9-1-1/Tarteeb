import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_frame.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onStart,
    required this.onRegister,
    required this.onSignIn,
    super.key,
  });
  final VoidCallback onStart;
  final VoidCallback onRegister;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return OnboardingFrame(
      title: 'Welcome to Tarteeb',
      subtitle: 'A calmer place for everything you want to do.',
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Less juggling.\nMore living.',
                style: theme.textTheme.displaySmall!.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'From your next study session to a little time for yourself. '
                'Find the space that fits your day.',
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final label in ['Campus life', 'Personal goals'])
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(label, style: theme.textTheme.labelLarge),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Get started',
          icon: Icons.arrow_forward,
          onPressed: onStart,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Explore both spaces before choosing. No account needed for previews.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Create account',
          variant: AppButtonVariant.secondary,
          onPressed: onRegister,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Sign in',
          variant: AppButtonVariant.text,
          onPressed: onSignIn,
        ),
      ],
    );
  }
}
