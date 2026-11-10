# Shared input and feedback widgets

Import individual files from `lib/core/widgets/`. These widgets depend only on
Flutter and the shared Material 3 theme/tokens. They work in light and dark
themes, use flexible text layouts, and have no repository or application state.

| Component | Variants and states | Accessibility |
| --- | --- | --- |
| `AppButton` | `primary` (filled), `secondary` (outlined), `text`, `destructive`; optional icon; disabled when callback is null; busy while `isLoading` | Native button role and enabled state; visible label by default, optional `semanticLabel`; `loadingLabel` announced as a live region |
| `AppTextField` | Editable, disabled, read-only, obscured, multiline; validator errors and external `errorText` | Required persistent `label`; native field semantics; wrapping error copy in a live region |
| `AppEmptyState` | Message, optional heading, decorative icon, optional action | Heading marked as a heading; message and action labels exposed; decorative icon excluded |
| `AppLoader` | Indeterminate (`value: null`) or determinate (`0..1`) | Required visible label announced once in a live region; percentage for determinate progress |
| `AppErrorBanner` | Inline error with optional recovery action | Error text announced in a live region; decorative icon excluded; recovery button remains a separate actionable node |
| `AppConfirmationSheet` | Normal or destructive confirmation, disabled confirmation, optional explanatory error | Heading, named confirm/cancel controls, Material modal semantics; scrollable with keyboard and safe-area insets |

## Buttons and asynchronous work

```dart
AppButton(
  label: 'Save plan',
  icon: Icons.save_outlined,
  isLoading: saving,
  loadingLabel: 'Saving plan',
  onPressed: canSave ? savePlan : null,
)
```

The caller owns `saving` and must set it before starting asynchronous work,
then clear it on completion. Loading prevents taps and keyboard activation even
when a callback is supplied. Widgets do not catch callback exceptions or start
requests. Present a failed operation with `AppErrorBanner` or a field error;
`destructive` describes an action's consequence, not a failed request.

Use specific labels such as “Delete plan” and “Retry upload”. Keep any alternate
`semanticLabel` consistent with the visible action. Labels are caller-provided
strings for localization; override the default “Please wait” and “Cancel” when
needed. Standard Material focus, hover, pressed and disabled styling is retained.

## Validated fields

```dart
Form(
  key: formKey, // GlobalKey<FormState> owned by the parent State.
  child: AppTextField(
    label: 'Plan title',
    controller: titleController,
    helperText: 'Choose a name you will recognize.',
    validator: (value) => value == null || value.trim().isEmpty
        ? 'Enter a plan title.'
        : null,
    errorText: titleServerError,
    onChanged: (_) => setState(() => titleServerError = null),
    textInputAction: TextInputAction.done,
  ),
)
```

Call `formKey.currentState!.validate()` before submitting and use `save()` /
`reset()` as with a regular `TextFormField`. Local validation defaults to
`AutovalidateMode.onUserInteraction`; use `disabled` for submission-only feedback.
`errorText` overrides the validator until the parent clears it (usually when
the user edits the field). Do not pass both a controller and `initialValue`.
The caller disposes controllers and focus nodes it supplies. The persistent
label sits above the input so it can wrap at large text sizes; it is attached
to the input's accessibility semantics without being announced twice.

`enabled: false` prevents editing and focus. `readOnly: true` prevents edits but
preserves selection/copy. Use `maxLines: null` or a positive line count for notes;
obscured fields must stay single-line. Errors wrap instead of using ellipsis.
Keep field labels concise; use helper copy for longer instructions.

## Feedback and error semantics

```dart
AppLoader(label: 'Loading plans')
AppLoader(label: 'Uploading attachment', value: 0.6)
AppEmptyState(
  title: 'No plans yet',
  message: 'Create a plan to organize your week.',
  actionLabel: 'Create plan',
  onAction: openCreatePlan,
)
AppErrorBanner(
  message: 'Your changes could not be saved. Please try again.',
  actionLabel: 'Retry',
  onAction: retrySave,
)
```

Omit `actionLabel` to hide an action. Supply a label with a null callback to show
a disabled action; a callback without a label is invalid. An empty result means
a successful request with no data; it must not replace a failed request.
Use field errors for specific input problems and banners for operation-level
failures. Explain the problem and recovery in text, not color alone. Map raw
exceptions to safe messages in presentation/application code; never display
stack traces, credentials or backend diagnostics.

Live regions request announcements from assistive technology; they do not move
focus. Avoid repeatedly replacing identical error messages or sending a second
manual announcement. Native screen-reader announcement timing needs device QA.

Feedback widgets are ordinary box widgets. Place them in a scrolling layout;
in sliver screens wrap them with `SliverToBoxAdapter` or `SliverFillRemaining`
with `hasScrollBody: false`. The Campus and Personal task list demonstrates all
three async states with these components and an actual Retry action.

## Confirmation sheets

```dart
final confirmed = await showAppConfirmationSheet(
  context: context,
  title: 'Delete this plan?',
  message: 'This permanently removes the plan and cannot be undone.',
  confirmLabel: 'Delete plan',
  destructive: true,
);
if (!context.mounted || !confirmed) return;
// Execute the operation here; show progress/errors in the calling screen.
```

Only the explicit confirm button returns `true`. Cancel, system back, tapping
the barrier, and dragging the sheet away return `false`. `confirmEnabled: false`
disables confirmation; `errorMessage` can explain why. Cancellation remains
available. The helper captures these values when opened; for changing state
inside a sheet, compose `AppConfirmationSheet` in your own stateful modal.
The sheet confirms intent and does not perform asynchronous business operations.

## Verification

Run `flutter test test/core/widgets/app_widgets_test.dart` from `TheCode/` for
interactive examples in widget tests: all button variants, loading/disabled
semantics, form validation/save/reset, server errors, labeled feedback, recovery
actions, confirmation outcomes, and both themes at 3x text on a narrow viewport
with a keyboard inset. `flutter test` also covers the real task list's
loading/error/retry flow and large-text scrolling. Run `flutter analyze` for
static checks. Native screen-reader and keyboard behavior remain device QA.
