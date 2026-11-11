import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_error_banner.dart';
import '../../core/widgets/app_loader.dart';
import 'navigation_controller.dart';

/// The guarded startup state; public introduction pages are separate routes.
class AccessScreen extends StatelessWidget {
  const AccessScreen({required this.navigation, super.key});
  final NavigationController navigation;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: navigation,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: navigation.startupFailed
                ? AppErrorBanner(
                    message: 'Tarteeb could not start. Please try again.',
                    actionLabel: 'Retry',
                    onAction: navigation.retryStartup,
                  )
                : const AppLoader(label: 'Starting Tarteeb'),
          ),
        ),
      ),
    ),
  );
}
