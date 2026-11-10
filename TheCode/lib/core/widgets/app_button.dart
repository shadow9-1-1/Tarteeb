import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

/// The caller owns loading state. Null callbacks and loading prevent activation.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.loadingLabel = 'Please wait',
    this.semanticLabel,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final String loadingLabel;
  final String? semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final callback = isLoading ? null : onPressed;
    final child = Semantics(
      label: isLoading ? loadingLabel : semanticLabel ?? label,
      liveRegion: isLoading,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading || icon != null) ...[
            if (isLoading)
              const SizedBox.square(
                dimension: AppSpacing.lg,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              isLoading ? loadingLabel : label,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    // Minimum sizes allow labels to wrap and grow with text scaling.
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(AppSpacing.xxl, AppSpacing.xxl),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: style.merge(
          FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
        ),
        child: child,
      ),
    };
  }
}
