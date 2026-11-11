import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../shared/tasks/domain/task_mode.dart';
import 'onboarding_frame.dart';

/// Public, static fixtures only. Never reads a protected task provider.
class DashboardPreviewScreen extends StatelessWidget {
  const DashboardPreviewScreen({
    required this.mode,
    required this.onContinue,
    required this.onBack,
    this.busy = false,
    this.errorMessage,
    super.key,
  });
  final TaskMode mode;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final bool busy;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final campus = mode == TaskMode.campus;
    final label = campus ? 'Campus' : 'Personal';
    final background = campus
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.tertiaryContainer;
    final foreground = campus
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onTertiaryContainer;
    final plans = campus
        ? [
            (
              '09:00',
              'Review lecture notes',
              'A fresh start for your next class',
            ),
            ('14:00', 'Study group', 'Make progress together'),
          ]
        : [
            ('08:00', 'Morning walk', 'A little movement, a clearer mind'),
            ('20:00', 'Read a chapter', 'Make room for something you enjoy'),
          ];
    return OnboardingFrame(
      title: '$label dashboard preview',
      subtitle: 'Here is what a little more order could look like.',
      step: 3,
      onBack: busy ? null : onBack,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAMPLE DAY',
                style: theme.textTheme.labelLarge!.copyWith(color: foreground),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                campus
                    ? 'Ready for a focused day?'
                    : 'A day with room for you.',
                style: theme.textTheme.headlineSmall!.copyWith(
                  color: foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                campus
                    ? '2 study plans · one step at a time'
                    : '2 personal plans · at your own pace',
                style: theme.textTheme.bodyLarge!.copyWith(color: foreground),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          campus ? 'Your campus focus' : 'Your personal rhythm',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (time, title, description) in plans) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Preview only · These fictional plans are not added to your workspace. '
          'Times are examples, not scheduled reminders.',
          style: theme.textTheme.bodyMedium,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppErrorBanner(message: errorMessage!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Continue with $label',
          loadingLabel: 'Saving your choice',
          isLoading: busy,
          onPressed: onContinue,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Compare the other space',
          variant: AppButtonVariant.text,
          onPressed: busy ? null : onBack,
        ),
      ],
    );
  }
}
