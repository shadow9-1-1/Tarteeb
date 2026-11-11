import 'package:flutter/foundation.dart';

/// An authentication adapter must restore/validate its own session and notify
/// on login, logout and expiry. Navigation preferences never grant access.
abstract class AuthSession extends ChangeNotifier {
  bool get isAuthenticated;
  bool get canSignIn;
  Future<void> restore();
  Future<void> signIn();
  Future<void> signOut();
}

/// Development-only, explicitly entered demo. No credentials or saved tokens.
class DemoAuthSession extends AuthSession {
  bool _authenticated = false;
  @override
  bool get isAuthenticated => _authenticated;
  @override
  bool get canSignIn => true;
  @override
  Future<void> restore() async {}
  @override
  Future<void> signIn() async {
    _authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
    notifyListeners();
  }
}

/// Fail closed until production authentication is connected at bootstrap.
class SignedOutAuthSession extends AuthSession {
  @override
  bool get isAuthenticated => false;
  @override
  bool get canSignIn => false;
  @override
  Future<void> restore() async {}
  @override
  Future<void> signIn() async => throw StateError('Authentication unavailable');
  @override
  Future<void> signOut() async {}
}
