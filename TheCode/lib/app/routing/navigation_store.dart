import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_routes.dart';

class NavigationSnapshot {
  const NavigationSnapshot({
    this.onboarded = false,
    this.location = AppRoutes.campusPath,
  });
  final bool onboarded;
  final String location;
}

abstract interface class NavigationStore {
  Future<NavigationSnapshot> read();
  Future<void> write(NavigationSnapshot snapshot);
}

/// Stores UI preferences only, not authentication claims or credentials.
class PreferencesNavigationStore implements NavigationStore {
  PreferencesNavigationStore({required String namespace})
    : _key = 'tarteeb.$namespace.navigation.v1';
  final String _key;
  final _preferences = SharedPreferencesAsync();

  @override
  Future<NavigationSnapshot> read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return const NavigationSnapshot();
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return const NavigationSnapshot();
      return NavigationSnapshot(
        onboarded: data['onboarded'] == true,
        location:
            AppRoutes.destination(
              data['location'] is String ? data['location'] as String : null,
            ) ??
            AppRoutes.campusPath,
      );
    } on FormatException {
      return const NavigationSnapshot();
    }
  }

  @override
  Future<void> write(NavigationSnapshot snapshot) => _preferences.setString(
    _key,
    jsonEncode({
      'onboarded': snapshot.onboarded,
      'location': snapshot.location,
    }),
  );
}
