# Phase 1 Campus dashboard

The Campus home now shows upcoming classes, deadlines and course cards, with
quick actions for the full schedule, deadlines, existing task list and resources.
Development uses a fixed fictional week (11–15 November 2026) with three courses,
three classes and three deadlines. Dates do not pretend to follow the device clock.

## Run and demonstrate

From TheCode, run:

```sh
flutter run -d chrome --dart-define-from-file=config/development.json
```

Complete onboarding, choose Campus, and enter the demo workspace. No Firebase
project, network calls or credentials are needed.

- Select **Class schedule** or **View all classes** to see all three classes.
- Select **Deadlines** or **View all deadlines** to see all three deadlines.
- Select an event or course card to open the matching course, instructor,
  location, classes and deadlines.
- Select **Campus tasks** for the existing task list.
- Select **Resources** for the illustrated, explicitly unavailable file shelf.
- Use **Campus dashboard** to return, or switch modes with the bottom bar.
  Switching back retains the Campus route; reselecting Campus returns home.

| Route | Route name | Purpose |
| --- | --- | --- |
| /campus | campus | Dashboard |
| /campus/classes | campus-classes | Full sample schedule |
| /campus/deadlines | campus-deadlines | Full sample deadline list |
| /campus/courses | campus-courses | Course collection |
| /campus/courses/:courseId | campus-course | Filtered course detail; unknown IDs have an empty state |
| /campus/tasks | campus-tasks | Existing task repository UI |
| /campus/resources | campus-resources | File shelf placeholder |

All routes stay inside the guarded Campus branch. Known nested routes are
allowlisted for sign-in return URLs and saved launch restoration. Preferences
never grant authentication. Production composition supplies empty Campus data
and keeps the existing authentication boundary.

## Data, states and reuse

CampusCourse, CampusEvent and CampusData are immutable models in
lib/features/campus/domain/campus_data.dart. campusSourceProvider supplies an
asynchronous source; campusDataProvider exposes loading/data/error states and
disposes its cache when the feature is no longer watched. Override the source
with a pending future, an error or an empty CampusData to exercise every state.
Retry explicitly reloads the source; backend exception text is never displayed.

CampusTile and CampusIllustration reuse Material color roles, spacing and radius
tokens. The dashboard uses two columns at 760 content pixels and three course
columns at 900; large text falls back to one column. All content scrolls, with no
fixed card heights or truncated text. Links use native button/InkWell keyboard
and semantics behavior; illustrations are decorative.

Files, uploads, editing, calendar connections and scheduled reminders are
placeholders, not simulated successful operations. The mock source is separate
from the existing task repository.

## Verification and screen evidence

Widget tests cover navigation from quick actions and cards, filtered course
content, unknown course IDs, signed-out deep links, mode switching, retry and
empty states. All Campus pages are tested in light/dark themes at 320 × 568 with
3× text and 1280 × 900 with standard text. Existing task and router regression
tests remain in the suite.

These are offline Flutter widget renders, not browser/device screenshots.
Mobile images use a tall viewport to show more scrollable content.

- [Mobile dashboard](screenshots/campus-dashboard-mobile.png)
- [Desktop dashboard](screenshots/campus-dashboard-desktop.png)
- [Dark dashboard](screenshots/campus-dashboard-dark.png)
- [Course detail](screenshots/campus-course.png)
- [Resources placeholder](screenshots/campus-empty.png)
- [Loading illustration](screenshots/campus-loading.png)

```sh
flutter analyze
flutter test
flutter test tool/capture_screenshots.dart --dart-define=CAMPUS_SCREENSHOTS=true --dart-define=SCREENSHOT_FONT=<flutter-sdk>/bin/cache/artifacts/material_fonts/roboto-regular.ttf
```
