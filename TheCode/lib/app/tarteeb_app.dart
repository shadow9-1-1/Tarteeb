import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class TarteebApp extends StatelessWidget {
  const TarteebApp({
    this.workspaceLabel = 'Demo workspace · Sample data only',
    super.key,
  });

  final String workspaceLabel;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarteeb',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: HomeScreen(workspaceLabel: workspaceLabel),
  );
}
