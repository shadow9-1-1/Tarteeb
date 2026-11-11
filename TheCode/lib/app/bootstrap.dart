import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/app_tokens.dart';
import '../features/shared/tasks/application/task_providers.dart';
import '../features/shared/tasks/data/in_memory_task_repository.dart';
import 'config/app_config.dart';
import 'demo_tasks.dart';
import 'routing/navigation_controller.dart';
import 'tarteeb_app.dart';

/// The composition root selects infrastructure. Features only see contracts.
void bootstrap() {
  try {
    final config = AppConfig.parse(
      environment: const String.fromEnvironment('APP_ENV'),
      flavor: appFlavor,
    );
    runApp(createApp(config));
  } on FormatException {
    runApp(const ConfigurationErrorApp());
  }
}

/// Production has no demo fixtures and stays signed out until an authentication
/// adapter is injected. No build silently connects to a Firebase project.
Widget createApp(AppConfig config, {NavigationController? navigation}) =>
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWith(
          (ref) => InMemoryTaskRepository(config.useDemoData ? demoTasks : []),
        ),
      ],
      child: TarteebApp(
        workspaceLabel: config.workspaceLabel,
        demoAccessEnabled: config.useDemoData,
        navigation: navigation,
      ),
    );

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    home: const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.page),
            child: Text(
              'This build is not configured correctly. Please contact the app team.',
            ),
          ),
        ),
      ),
    ),
  );
}
