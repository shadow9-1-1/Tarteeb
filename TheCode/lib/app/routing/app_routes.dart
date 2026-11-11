abstract final class AppRoutes {
  static const launch = 'launch';
  static const onboarding = 'onboarding';
  static const signIn = 'signIn';
  static const register = 'register';
  static const privacy = 'privacy';
  static const chooseMode = 'chooseMode';
  static const campusPreview = 'campusPreview';
  static const personalPreview = 'personalPreview';
  static const campus = 'campus';
  static const personal = 'personal';

  static const launchPath = '/launch';
  static const onboardingPath = '/onboarding';
  static const signInPath = '/sign-in';
  static const registerPath = '/register';
  static const privacyPath = '/onboarding/privacy';
  static const chooseModePath = '/onboarding/mode';
  static const campusPreviewPath = '/preview/campus';
  static const personalPreviewPath = '/preview/personal';
  static const campusPath = '/campus';
  static const personalPath = '/personal';

  static const publicPaths = {
    onboardingPath,
    privacyPath,
    chooseModePath,
    campusPreviewPath,
    personalPreviewPath,
    signInPath,
    registerPath,
  };

  static String entry(String path, {String? from}) => Uri(
    path: path,
    queryParameters: destination(from) == null
        ? null
        : {'from': destination(from)!},
  ).toString();

  /// Preserve public entry links during asynchronous startup, without allowing
  /// arbitrary external redirects or recursively nested return locations.
  static String? publicLocation(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        !publicPaths.contains(uri.path)) {
      return null;
    }
    return entry(uri.path, from: uri.queryParameters['from']);
  }

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
