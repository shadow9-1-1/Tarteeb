# Phase 1: welcome and choosing a space

The introduction has seven routable views using the shared Material 3 theme,
buttons, feedback widgets and spacing tokens. Content is bounded on wider
screens and scrollable on small screens; text is never deliberately truncated.

| View | Route | Working interaction | Rendered example |
| --- | --- | --- | --- |
| Welcome | `/onboarding` | Get started, Create account, Sign in | [Welcome](screenshots/onboarding-welcome.png) |
| Privacy and notifications | `/onboarding/privacy` | Choose your space, Back | [Explanations](screenshots/onboarding-privacy.png) |
| Mode selection | `/onboarding/mode` | Preview Campus or Preview Personal | [Mode choices](screenshots/onboarding-mode-selection.png) |
| Campus dashboard preview | `/preview/campus` | Continue with Campus, compare spaces | [Campus preview](screenshots/onboarding-campus-preview.png) |
| Personal dashboard preview | `/preview/personal` | Continue with Personal, compare spaces | [Personal preview](screenshots/onboarding-personal-preview.png) |
| Sign-in entry | `/sign-in` | Demo entry in development, explore, registration link | [Sign-in](screenshots/onboarding-sign-in.png) |
| Registration entry | `/register` | Explore or switch to sign-in | [Registration](screenshots/onboarding-registration.png) |

## Demonstration

Run `flutter run -d chrome --dart-define-from-file=config/development.json` from
`TheCode/`. On a fresh installation:

1. From **Welcome to Tarteeb**, choose **Get started**.
2. Read **Your plans. Your choice.** It explains local setup preferences, fictional
   preview data, and that notifications are not enabled or requested.
3. Select **Choose your space**, then **Preview Campus**. The Campus preview shows
   lecture review and a study group.
4. Select **Compare the other space**, then **Preview Personal**. The Personal
   preview shows a morning walk and reading. The Back control also returns to
   the mode choices.
5. Select **Continue with Personal**. The selected mode and onboarding completion
   are saved together. A storage failure keeps the preview open with a retryable
   message and does not claim setup is complete.
6. Select **Enter demo workspace** to open the protected **Personal tasks** screen
   with the Personal bottom tab selected. Repeat with Campus to see Campus tasks.

The real Personal demo workspace currently starts empty; the preview is explicitly
fictional and does not add its sample plans to the repository. Campus and Personal
can still be switched using the workspace's existing navigation bar.

For a returning installation, use the direct public preview URLs while signed
out, such as `/#/onboarding` on web. Public paths survive asynchronous startup.
Once an authenticated session has completed setup, public entry URLs redirect to
the workspace as before. Sign out before demonstrating the public flow again.

## Account and permission semantics

The welcome page has separate registration and sign-in entry points. Registration
is a clearly labeled preview: account creation is unavailable, its submit button
is disabled, and no email/password fields collect credentials. The user can still
explore both dashboards or switch to sign-in. Development offers explicit demo
entry; production keeps real account sign-in disabled until an authentication
adapter is connected. These pages do not simulate successful registration.

No notification permission is requested, no reminders are scheduled, and no
toggle implies otherwise. The explanation describes the current preview and
lets users continue without enabling notifications. The privacy copy describes
only the saved setup/mode preferences and sample data, without promising future
backend policies.

## Navigation and accessibility

Feature screens in `features/onboarding/presentation/` receive callbacks and have
no dependency on app routing or task repositories. The router composes them.
Public previews are static fixtures; actual `/campus` and `/personal` routes
remain protected. Visiting a preview never signs a user in or fetches their tasks.

A protected deep link keeps its intended mode through the introduction. Selecting
and confirming a different mode deliberately overrides that initial suggestion.
Confirmation persists the mode; simply comparing previews does not. The saved
mode is restored after the usual session checks on the next launch.

Mode cards expose button semantics, descriptive labels and tap actions, with
native focus/keyboard handling from InkWell. Headings and setup progress have
semantics, Back controls have tooltips, and loading/error states use shared
accessible widgets. All public pages are tested in light and dark themes at 3x
text scaling on a 320 x 568 viewport. Native screen-reader behavior still needs
device verification.

## Verification and evidence

```sh
flutter analyze
flutter test
flutter test tool/capture_screenshots.dart --dart-define=ONBOARDING_SCREENSHOTS=true --dart-define=SCREENSHOT_FONT=<flutter-sdk>/bin/cache/artifacts/material_fonts/roboto-regular.ttf
```

The screenshot command captures all seven screens at 390 x 1040 logical pixels
to document their scrollable content. These are offline widget renders, not
device/browser screenshots. The tests exercise both complete mode-selection
flows, account entry navigation, back/compare behavior, persistence, public
preview isolation, protected production routes, and large text.
