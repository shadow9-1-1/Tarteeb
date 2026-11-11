import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'routing/auth_session.dart';
import 'routing/navigation_controller.dart';
import 'routing/navigation_store.dart';

class TarteebApp extends StatefulWidget {
  const TarteebApp({
    this.workspaceLabel = 'Demo workspace · Sample data only',
    this.themeMode = ThemeMode.system,
    this.demoAccessEnabled = false,
    this.navigation,
    this.initialLocation,
    super.key,
  });
  final String workspaceLabel;
  final ThemeMode themeMode;
  final bool demoAccessEnabled;

  /// Injected controllers are owned and disposed by the caller.
  final NavigationController? navigation;
  final String? initialLocation;

  @override
  State<TarteebApp> createState() => _TarteebAppState();
}

class _TarteebAppState extends State<TarteebApp> {
  late final NavigationController _navigation;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _navigation =
        widget.navigation ??
        NavigationController(
          auth: widget.demoAccessEnabled
              ? DemoAuthSession()
              : SignedOutAuthSession(),
          store: PreferencesNavigationStore(
            namespace: widget.demoAccessEnabled ? 'development' : 'production',
          ),
        );
    _router = createAppRouter(
      navigation: _navigation,
      workspaceLabel: widget.workspaceLabel,
      demoAccessEnabled: widget.demoAccessEnabled,
      initialLocation: widget.initialLocation,
    );
    _router.routerDelegate.addListener(_rememberLocation);
    unawaited(_navigation.initialize());
  }

  void _rememberLocation() {
    unawaited(
      _navigation.remember(
        _router.routerDelegate.currentConfiguration.uri.toString(),
      ),
    );
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_rememberLocation);
    _router.dispose();
    if (widget.navigation == null) {
      _navigation.dispose();
      _navigation.auth.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Tarteeb',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: widget.themeMode,
    restorationScopeId: 'tarteeb',
    routerConfig: _router,
  );
}
