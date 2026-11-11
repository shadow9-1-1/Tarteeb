import 'package:flutter/foundation.dart';

import 'app_routes.dart';
import 'auth_session.dart';
import 'navigation_store.dart';

class NavigationController extends ChangeNotifier {
  NavigationController({required this.auth, required this.store}) {
    auth.addListener(_changed);
  }
  final AuthSession auth;
  final NavigationStore store;
  bool ready = false;
  bool startupFailed = false;
  bool busy = false;
  String? errorMessage;
  NavigationSnapshot _snapshot = const NavigationSnapshot();
  bool _disposed = false;
  Future<void>? _initialization;
  Future<void> _writes = Future.value();

  bool get onboarded => _snapshot.onboarded;
  String get lastLocation => _snapshot.location;

  Future<void> initialize() => _initialization ??= _initialize();
  Future<void> _initialize() async {
    try {
      final snapshot = await store.read();
      await auth.restore();
      if (_disposed) return;
      _snapshot = NavigationSnapshot(
        onboarded: snapshot.onboarded,
        location:
            AppRoutes.destination(snapshot.location) ?? AppRoutes.campusPath,
      );
      ready = true;
    } catch (_) {
      startupFailed = true;
    }
    _changed();
  }

  Future<void> retryStartup() {
    startupFailed = false;
    _initialization = null;
    _changed();
    return initialize();
  }

  Future<void> completeOnboarding({String? location}) => _perform(() async {
    final next = NavigationSnapshot(
      onboarded: true,
      location: AppRoutes.destination(location) ?? lastLocation,
    );
    await _save(next);
    _snapshot = next;
  }, 'Your setup could not be saved. Please try again.');

  Future<void> signIn() =>
      _perform(auth.signIn, 'Sign-in failed. Please try again.');
  Future<void> signOut() =>
      _perform(auth.signOut, 'Sign-out failed. Please try again.');

  Future<void> _perform(Future<void> Function() action, String failure) async {
    if (busy || _disposed) return;
    busy = true;
    errorMessage = null;
    _changed();
    try {
      await action();
    } catch (_) {
      errorMessage = failure;
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> _save(NavigationSnapshot snapshot) {
    // Serialize writes so rapid tab switching cannot restore an older tab.
    final write = _writes.then((_) => store.write(snapshot));
    _writes = write.catchError((Object _) {});
    return write;
  }

  Future<void> remember(String location) async {
    final safe = AppRoutes.destination(location);
    if (!ready ||
        !auth.isAuthenticated ||
        safe == null ||
        safe == lastLocation) {
      return;
    }
    _snapshot = NavigationSnapshot(onboarded: onboarded, location: safe);
    try {
      await _save(_snapshot);
    } catch (_) {
      errorMessage = 'Your last screen could not be saved for the next launch.';
      _changed();
    }
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    auth.removeListener(_changed);
    super.dispose();
  }
}
