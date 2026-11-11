# Routing, access and restoration

`app/routing/app_router.dart` builds the app's single GoRouter. `TarteebApp`
owns the router for its widget lifetime and renders `MaterialApp.router`.
`AppRoutes` centralizes route names and paths:

| Name | Path | Purpose |
| --- | --- | --- |
| `launch` | `/launch` | Wait for navigation preferences and authentication restoration |
| `onboarding` | `/onboarding` | Welcome and account entry points |
| `privacy` | `/onboarding/privacy` | Privacy and notification explanations |
| `chooseMode` | `/onboarding/mode` | Campus and Personal choices |
| `campusPreview` | `/preview/campus` | Public fictional Campus dashboard |
| `personalPreview` | `/preview/personal` | Public fictional Personal dashboard |
| `register` | `/register` | Registration entry, with account creation explicitly unavailable |
| `signIn` | `/sign-in` | Session entry; demo access only in development |
| `campus` | `/campus` | Protected Campus task workspace |
| `personal` | `/personal` | Protected Personal task workspace |

`/` resolves to the appropriate launch destination. Use
`context.goNamed(AppRoutes.personal)` instead of scattering path literals.
Unknown routes have a page-not-found view with a safe home action.

## Redirect order

The top-level redirect runs before protected screens build:

1. Until preferences and `AuthSession.restore()` finish, show the launch screen.
2. If onboarding is incomplete, protected requests go to welcome. The public
   introduction, registration, sign-in and static previews remain reachable.
3. If onboarding is complete but the session is unauthenticated, protected
   requests go to sign-in. Public previews remain available without signing in.
4. Once both gates pass, open the requested mode or the saved mode (Campus by
   default). Authenticated users visiting public entry routes return to a mode.

A known requested destination travels through the gates in the `from` query
parameter. Only local `/campus` and `/personal` destinations are accepted;
external URLs, protocol-relative URLs, traversal paths, and unknown paths cannot
be used as return destinations. These routes currently have no query-driven
screen state, so only the canonical mode path is retained. Public entry paths
are preserved across startup with a separately allowlisted `next` value. The
preview's Continue action saves onboarding completion and the chosen mode
together before proceeding to sign-in. See [Phase 1 onboarding](phase-1-onboarding.md).

`NavigationController` listens to the session and supplies GoRouter's
`refreshListenable`. Sign-out or session expiry redirects immediately and removes
both protected branches. Navigating back or submitting a protected URL after
sign-out still goes through the guard. Startup failures show a retry action and
never unlock the workspace. Onboarding write failures keep the user on onboarding
with an actionable message.

## Authentication boundary

There is no live account backend in this project yet. Development offers
**Enter demo workspace**, which opens fictional data without creating an account.
The demo session is in memory and must be entered again on a fresh launch.
Production uses `SignedOutAuthSession`: account sign-in is disabled and protected
routes remain locked. Production never reads a saved demo authentication flag.

To connect real authentication, implement `AuthSession`: restore and validate the
backend session, expose `isAuthenticated`, and notify listeners on sign-in,
sign-out and expiry. Inject it through a `NavigationController` passed to
`createApp(config, navigation: controller)`. The caller owns an injected controller
and session and must dispose both. The app owns its default controller/session.
The sign-in screen is an entry point; credential forms/provider-specific flows
belong to the authentication implementation.

No tokens, credentials or trusted authentication claims are stored in navigation
preferences. Route guards control UI access; future APIs must enforce their own
authentication and data authorization.

## Two mode branches

A `StatefulShellRoute.indexedStack` contains independent Campus and Personal
`StatefulShellBranch` navigators. The bottom bar derives its selection from the
active route, and `goBranch` switches navigators. Each mode renders its existing
feature screen inside `ModeWorkspace`; each retains its scroll position while
switching tabs. Re-selecting the current tab returns to that branch's initial
route. Add future child routes to the corresponding branch rather than creating
another MaterialApp or maintaining a separate selected-tab index.

Visited branches remain mounted while authenticated. Their task providers can
therefore remain active until the shell is removed. Mode-keyed providers keep
responses isolated; logout removes the shell so auto-disposed providers are
released. No extra product tabs are invented for features that are not built yet.

## Relaunch and process restoration

`PreferencesNavigationStore` uses `SharedPreferencesAsync` to store one versioned
JSON snapshot: onboarding completion and the last successfully navigated mode.
Development and production have separate keys. Unknown/corrupt saved routes fall
back to Campus; malformed JSON falls back to a fresh onboarding snapshot. Writes
are serialized so rapid switching cannot let an older write win. Preference
storage is best effort: a mode-write failure shows a warning and navigation keeps
working; the previous saved mode may be restored next launch.

On a fresh launch:

- An explicit supported deep link takes precedence over the saved mode.
- Without a deep link, restore the last mode after the session gates pass.
- A missing/expired session always requires sign-in first, even when a protected
  mode was saved. A valid backend session can proceed immediately after restore.

GoRouter, MaterialApp, the shell page, both navigators and scroll views also have
restoration IDs for Flutter process restoration. This is separate from the
persisted preference used for normal cold launches. On web, the current URL
remains the source for direct links and reloads (Flutter's default hash routing).
Native Universal Links/App Links domain associations are not configured because
this project has no registered link domain yet.

## Verification and references

Run `flutter analyze` and `flutter test` from `TheCode/`. Router tests cover direct
protected links, delayed session restore, onboarding bypass attempts, return URL
validation, sign-out/expiry, independent mode data and scrolling, fresh app
instances reading persisted preferences, Flutter restoration, explicit-link
precedence, startup retry, and production isolation. Existing app and theme tests
continue to exercise both feature screens through the router. Tests inject an
authenticated fake session explicitly; they do not weaken the production guard.

- [GoRouter redirects](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [GoRouter state restoration](https://pub.dev/documentation/go_router/latest/topics/State%20restoration-topic.html)
- [Shared preferences](https://pub.dev/packages/shared_preferences)
