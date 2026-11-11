abstract final class AppRoutes {
  static const launch = 'launch';
  static const onboarding = 'onboarding';
  static const signIn = 'signIn';
  static const campus = 'campus';
  static const personal = 'personal';

  static const launchPath = '/launch';
  static const onboardingPath = '/onboarding';
  static const signInPath = '/sign-in';
  static const campusPath = '/campus';
  static const personalPath = '/personal';

  /// Only known, local destinations may be restored or used as a return URL.
  static String? destination(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
    return switch (uri.path) {
      campusPath => campusPath,
      personalPath => personalPath,
      _ => null,
    };
  }
}
