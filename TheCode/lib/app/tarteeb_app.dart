import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class TarteebApp extends StatelessWidget {
  const TarteebApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarteeb',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const HomeScreen(),
  );
}
