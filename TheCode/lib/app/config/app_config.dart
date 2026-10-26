enum AppEnvironment { development, production }

/// Public build configuration only. Dart defines are bundled into the app.
class AppConfig {
  const AppConfig(this.environment);

  final AppEnvironment environment;

  factory AppConfig.parse({String environment = '', String? flavor}) {
    final selected = environment.isEmpty
        ? (flavor ?? 'development')
        : environment;
    final resolved = switch (selected) {
      'development' => AppEnvironment.development,
      'production' => AppEnvironment.production,
      _ => throw const FormatException('Unknown APP_ENV or platform flavor.'),
    };
    if (flavor != null && flavor != selected) {
      throw const FormatException('APP_ENV must match the platform flavor.');
    }
    return AppConfig(resolved);
  }

  bool get useDemoData => environment == AppEnvironment.development;

  String get workspaceLabel => useDemoData
      ? 'Demo workspace · Sample data only'
      : 'Preview workspace · Storage not connected';
}
