import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Present a safe, actionable message, never a raw exception or stack trace.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(onAction == null || actionLabel != null);

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
