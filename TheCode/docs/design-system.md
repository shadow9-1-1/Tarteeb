# Material 3 theme and tokens

`lib/core/theme/app_theme.dart` owns `AppTheme.light` and `AppTheme.dark`.
Both derive a complete semantic `ColorScheme` from the Tarteeb teal seed and use
Material 3 typography and component defaults. `TarteebApp` follows system
brightness; its optional `themeMode` supports explicit previews or a future
user preference. The configuration-error app uses the same foundations.

## Color roles

Read colors from `Theme.of(context).colorScheme`. Do not copy generated hex
values into feature widgets or switch colors using brightness checks.

| Purpose | Background | Foreground |
| --- | --- | --- |
| Page | `surface` | `onSurface` |
| Secondary text on a page | `surface` | `onSurfaceVariant` |
| Task card | `surfaceContainerLow` | `onSurface` |
| Primary action | `primary` | `onPrimary` |
| Selected navigation indicator | `secondaryContainer` | `onSecondaryContainer` |
| Navigation bar | `surfaceContainer` | `onSurfaceVariant` |
| Dialog | `surfaceContainerHigh` | `onSurface` |
| Error message container | `errorContainer` | `onErrorContainer` |

Use `primary` for emphasis/icons, `error` for failure indicators, and
`outline`/`outlineVariant` for appropriate borders. Never use a container role as
its own text color. Standard Material components retain their state-aware
hover, focus, pressed and disabled styles.

Tests verify at least 4.5:1 contrast for the documented text pairs and the other
primary, secondary, tertiary, error and inverse pairs in both themes, plus 3:1
for the task and error icons against their actual backgrounds. This verifies
these role combinations; new custom combinations need their own checks.

## Typography

The complete Material 3 type scale comes from `ThemeData(useMaterial3: true)`.
Keep its platform font fallbacks and locale-aware metrics. No downloaded font
is required. Consume named `textTheme` roles instead of creating font sizes.

| Usage | Role | Default size / line height (logical pixels, English) |
| --- | --- | --- |
| Screen heading | `headlineSmall` | 24 / 32 |
| App bar, section title | `titleLarge` | 22 / 28 |
| Task title, empty/error message | `bodyLarge` | 16 / 24 |
| Workspace context, supporting copy | `bodyMedium` | 14 / 20 |
| Button label | `labelLarge` | 14 / 20 |
| Navigation label | `labelMedium` | 12 / 16 |

Display, headline, title, body and label roles in all three sizes remain
available through `textTheme`. Component themes handle standard controls.

## Geometry

`lib/core/theme/app_tokens.dart` defines constants in logical pixels. These
values are shared by both brightness modes; they do not require a
`ThemeExtension` because they do not vary or animate with the theme.

| Token family | Values | Usage |
| --- | --- | --- |
| `AppSpacing` | none 0, xs 4, sm 8, md 16, lg 24, xl 32, xxl 48 | `page = lg`; sm between cards, md within cards, lg page padding |
| `AppRadius` | xs 4, sm 8, md 12, lg 16, xl 28 | xs input border, md cards, xl dialogs; `StadiumBorder` for pill buttons |
| `AppElevation` | level0 0, level1 1, level2 3, level3 6, level4 8, level5 12 | level0 cards/navigation, level1 scrolled app bar, level3 dialogs |

Surface-container colors provide separation for flat cards. Filled buttons
have a 48-pixel minimum size and expandable padding, never a fixed text height.

## Reuse

```dart
import '../../../core/theme/app_tokens.dart'; // Adjust to the file's location.

final theme = Theme.of(context);
return Padding(
  padding: const EdgeInsets.all(AppSpacing.page),
  child: Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text('Your plan', style: theme.textTheme.bodyLarge),
    ),
  ),
);
```

Use `copyWith(color: theme.colorScheme.onSurfaceVariant)` for supporting copy.
Let `Card`, `ListTile`, `FilledButton`, `NavigationBar`, input fields and dialogs
inherit their component themes. Keep reusable foundations in `core/theme` and
feature-specific composition in feature presentation folders.

## Text scaling and scrolling

Campus and Personal are sliver-based screens placed in the home
`CustomScrollView`. Their headings and the shared `TaskList` scroll with the
workspace label, including loading, empty and error states. When embedding
either screen elsewhere, put it in a scroll view's `slivers` list. Task cards
wrap titles without `maxLines` or ellipsis. Navigation remains reachable outside
the scroll view.

Do not disable or cap the app's `TextScaler`, use fixed heights for copy, or
truncate essential text. Flutter's standard Material app bar and navigation
components retain their built-in text scaling limits and semantics behavior.

## Verification

From `TheCode/`, run `flutter analyze` and `flutter test`. Regression coverage:

- Color-role contrast in both themes and live system-brightness changes.
- Both screens with long task titles at 1x, 2x and 3x on a 320 x 568 viewport.
- Both screens at 3x on a short 568 x 320 landscape viewport.
- Loading, error, visible/reachable Retry, and empty states at 3x in both themes.
- Paragraph truncation/height checks, scroll reachability, shared heading styles,
  and the existing bootstrap, mode-switching and repository tests.

Generate offline visual previews with the SDK's Roboto font:

```sh
flutter test tool/capture_screenshots.dart --dart-define=THEME_SCREENSHOTS=true --dart-define=SCREENSHOT_FONT=<flutter-sdk>/bin/cache/artifacts/material_fonts/roboto-regular.ttf
```

Previews: [Campus light](screenshots/theme-campus-light.png),
[Campus dark](screenshots/theme-campus-dark.png),
[Personal dark](screenshots/theme-personal-dark.png), and
[3x text, scrolled to tasks](screenshots/theme-large-text.png).
These are widget renders, not device screenshots. Device-specific font scaling
and screen-reader behavior still need native-device checks.
