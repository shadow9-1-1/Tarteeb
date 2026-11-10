import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_button.dart';
import 'app_error_banner.dart';

/// Returns true only for explicit confirmation; back, barrier and drag return
/// false. Perform the operation after awaiting this result, not in the sheet.
Future<bool> showAppConfirmationSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool confirmEnabled = true,
  String? errorMessage,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AppConfirmationSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        errorMessage: errorMessage,
        onConfirm: confirmEnabled
            ? () => Navigator.of(context).pop(true)
            : null,
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ) ??
    false;

class AppConfirmationSheet extends StatelessWidget {
  const AppConfirmationSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.errorMessage,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;
  final bool destructive;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: theme.textTheme.bodyLarge),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppErrorBanner(message: errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: confirmLabel,
                onPressed: onConfirm,
                variant: destructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: cancelLabel,
                onPressed: onCancel,
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
