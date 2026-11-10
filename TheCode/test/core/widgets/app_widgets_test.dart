import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/core/theme/app_theme.dart';
import 'package:tarteeb/core/widgets/app_button.dart';
import 'package:tarteeb/core/widgets/app_confirmation_sheet.dart';
import 'package:tarteeb/core/widgets/app_empty_state.dart';
import 'package:tarteeb/core/widgets/app_error_banner.dart';
import 'package:tarteeb/core/widgets/app_loader.dart';
import 'package:tarteeb/core/widgets/app_text_field.dart';

Widget host(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  home: Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  ),
);

void main() {
  for (final variant in AppButtonVariant.values) {
    testWidgets('${variant.name} action, disabled and busy semantics', (
      tester,
    ) async {
      var calls = 0;
      Widget button({bool disabled = false, bool busy = false}) => host(
        AppButton(
          label: 'Save',
          semanticLabel: 'Save plan',
          variant: variant,
          onPressed: disabled ? null : () => calls++,
          isLoading: busy,
          loadingLabel: 'Saving plan',
          icon: Icons.save_outlined,
        ),
      );
      await tester.pumpWidget(button());
      var data = tester
          .getSemantics(find.bySemanticsLabel('Save plan'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, Tristate.isTrue);
      await tester.tap(find.text('Save'));
      expect(calls, 1);
      await tester.pumpWidget(button(disabled: true));
      data = tester
          .getSemantics(find.bySemanticsLabel('Save plan'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(find.text('Save'));
      expect(calls, 1);
      await tester.pumpWidget(button(busy: true));
      await tester.pump(const Duration(milliseconds: 100));
      data = tester
          .getSemantics(find.bySemanticsLabel('Saving plan'))
          .getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(find.text('Saving plan'));
      expect(calls, 1);
      await tester.pumpWidget(button());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      expect(calls, 2);
    });
  }

  testWidgets(
    'field validates, saves and resets; server errors take precedence',
    (tester) async {
      final form = GlobalKey<FormState>();
      String? serverError;
      String? saved;
      Widget field() => host(
        Form(
          key: form,
          child: AppTextField(
            label: 'Task title',
            initialValue: '',
            helperText: 'Give your plan a name.',
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a title.' : null,
            errorText: serverError,
            onSaved: (value) => saved = value,
          ),
        ),
      );
      await tester.pumpWidget(field());
      expect(find.text('Enter a title.'), findsNothing);
      expect(form.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Enter a title.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Plan tomorrow');
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'Plan tomorrow');
      serverError = 'This name is already in use.';
      await tester.pumpWidget(field());
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isFalse);
      expect(find.text(serverError), findsOneWidget);
      serverError = null;
      await tester.pumpWidget(field());
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    },
  );

  testWidgets('field exposes its label, disabled and read-only state', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      host(AppTextField(label: 'Email', enabled: false, focusNode: focus)),
    );
    final data = tester
        .getSemantics(find.bySemanticsLabel('Email'))
        .getSemanticsData();
    expect(data.flagsCollection.isTextField, isTrue);
    expect(data.flagsCollection.isEnabled, Tristate.isFalse);
    await tester.tap(find.byType(TextFormField));
    expect(focus.hasFocus, isFalse);
    await tester.pumpWidget(
      host(const AppTextField(label: 'Email', readOnly: true)),
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
  });

  testWidgets(
    'loader announces label and progress; errors announce with a retry action',
    (tester) async {
      await tester.pumpWidget(
        host(const AppLoader(label: 'Uploading plan', value: .5)),
      );
      var data = tester
          .getSemantics(find.bySemanticsLabel('Uploading plan'))
          .getSemanticsData();
      expect(data.value, '50%');
      expect(data.flagsCollection.isLiveRegion, isTrue);
      var retries = 0;
      await tester.pumpWidget(
        host(
          AppErrorBanner(
            message: 'Could not save. Try again.',
            actionLabel: 'Retry',
            onAction: () => retries++,
          ),
        ),
      );
      data = tester
          .getSemantics(find.bySemanticsLabel('Could not save. Try again.'))
          .getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(find.bySemanticsLabel('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
      await tester.pumpWidget(
        host(const AppErrorBanner(message: 'Offline', actionLabel: 'Retry')),
      );
      data = tester
          .getSemantics(find.bySemanticsLabel('Retry'))
          .getSemanticsData();
      expect(data.hasAction(SemanticsAction.tap), isFalse);
    },
  );

  testWidgets('empty state exposes heading, message and optional action', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        AppEmptyState(
          title: 'No plans',
          message: 'Create your first plan.',
          actionLabel: 'Create plan',
          onAction: () => calls++,
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('No plans'))
          .flagsCollection
          .isHeader,
      isTrue,
    );
    expect(find.bySemanticsLabel('Create your first plan.'), findsOneWidget);
    await tester.tap(find.text('Create plan'));
    expect(calls, 1);
    await tester.pumpWidget(
      host(
        const AppEmptyState(message: 'No plans', actionLabel: 'Create plan'),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Create plan'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
  });

  testWidgets(
    'confirmation requires explicit consent; cancel, back and barrier return false',
    (tester) async {
      bool? result;
      var enabled = true;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => AppButton(
              label: 'Open sheet',
              onPressed: () async {
                result = await showAppConfirmationSheet(
                  context: context,
                  title: 'Delete plan?',
                  message: 'This action cannot be undone.',
                  confirmLabel: 'Delete plan',
                  destructive: true,
                  confirmEnabled: enabled,
                  errorMessage: enabled
                      ? null
                      : 'Wait for the current save to finish.',
                );
              },
            ),
          ),
        ),
      );
      Future<void> open() async {
        result = null;
        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();
      }

      await open();
      await tester.tap(find.text('Delete plan'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      await open();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      await open();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(result, isFalse);
      await open();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      enabled = false;
      await open();
      await tester.tap(find.text('Delete plan'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('Wait for the current save to finish.'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      '${dark ? 'dark' : 'light'} widgets wrap at 3x; sheet scrolls above keyboard',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          host(
            Column(
              children: [
                AppButton(
                  label: 'Save all changes to your plan',
                  onPressed: () {},
                ),
                const AppTextField(
                  label: 'Title',
                  errorText:
                      'Enter a descriptive title before saving this plan.',
                ),
                const AppLoader(label: 'Loading your saved plans', value: .5),
                const AppEmptyState(
                  title: 'No plans',
                  message: 'Start by creating a plan for this week.',
                ),
                AppErrorBanner(
                  message: 'Your changes could not be saved. Please try again.',
                  actionLabel: 'Try saving again',
                  onAction: () {},
                ),
              ],
            ),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final paragraph in tester.renderObjectList<RenderParagraph>(
          find.byType(RichText),
        )) {
          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: paragraph.text.toPlainText(),
          );
        }
        await tester.pumpWidget(
          host(
            Builder(
              builder: (context) => AppButton(
                label: 'Open',
                onPressed: () => showAppConfirmationSheet(
                  context: context,
                  title: 'Remove this plan?',
                  message: 'Removing this plan permanently deletes its saved details.',
                  confirmLabel: 'Remove this plan permanently',
                ),
              ),
            ),
            dark: dark,
          ),
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 160);
        addTearDown(tester.view.resetViewInsets);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Cancel').hitTestable(), findsOneWidget);
        expect(
          tester.getRect(find.text('Cancel')).bottom,
          lessThanOrEqualTo(408),
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(AppConfirmationSheet), findsNothing);
      },
    );
  }
}
