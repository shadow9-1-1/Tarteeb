import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// A scrollable, bounded layout shared by the public introduction screens.
class OnboardingFrame extends StatelessWidget {
  const OnboardingFrame({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    this.step,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback? onBack;
  final int? step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (onBack != null) ...[
                          IconButton(
                            tooltip: 'Back',
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.done_all_rounded,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Tarteeb',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (step != null) ...[
                      Text(
                        'Step $step of 3',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: step! / 3,
                        semanticsLabel: 'Setup progress, step $step of 3',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IntroductionCard extends StatelessWidget {
  const IntroductionCard({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
