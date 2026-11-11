import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../shared/tasks/domain/task_mode.dart';
import 'onboarding_frame.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({
    required this.onSelect,
    required this.onBack,
    this.suggestedMode,
    super.key,
  });
  final ValueChanged<TaskMode> onSelect;
  final VoidCallback onBack;
  final TaskMode? suggestedMode;

  @override
  Widget build(BuildContext context) => OnboardingFrame(
    title: 'Choose your starting space',
    subtitle: 'Two sides of your life. One place to bring them together.',
    step: 2,
    onBack: onBack,
    children: [
      for (final mode in TaskMode.values) ...[
        _ModeCard(
          mode: mode,
          suggested: mode == suggestedMode,
          onTap: () => onSelect(mode),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
      Text(
        'This is just your starting point. You can switch between Campus and Personal later.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.onTap,
    required this.suggested,
  });
  final TaskMode mode;
  final VoidCallback onTap;
  final bool suggested;

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
    return Semantics(
      button: true,
      label: 'Preview $label',
      onTap: onTap,
      hint: campus
          ? 'For classes, study sessions and deadlines'
          : 'For routines, goals and everyday plans',
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  campus ? Icons.school_outlined : Icons.spa_outlined,
                  color: foreground,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  label,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  campus
                      ? 'Make space for learning.'
                      : 'Make time for yourself.',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  campus
                      ? 'Bring study sessions, coursework and campus priorities into focus.'
                      : 'Give your routines, personal goals and everyday plans a little more structure.',
                  style: theme.textTheme.bodyLarge!.copyWith(color: foreground),
                ),
                if (suggested) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your linked space',
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Preview $label',
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: foreground,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 18, color: foreground),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
