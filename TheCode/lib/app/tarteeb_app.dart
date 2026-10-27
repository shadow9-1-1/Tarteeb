import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class TarteebApp extends StatelessWidget {
  const TarteebApp({
    this.workspaceLabel = 'Demo workspace · Sample data only',
    this.themeMode = ThemeMode.system,
    super.key,
  });

  final String workspaceLabel;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarteeb',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: HomeScreen(workspaceLabel: workspaceLabel),
  );
}
