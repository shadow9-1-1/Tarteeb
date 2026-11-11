import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_loader.dart';
import '../application/campus_providers.dart';
import '../domain/campus_data.dart';

/// Every section scrolls with the workspace, including at large text sizes.
class CampusScreen extends ConsumerWidget {
  const CampusScreen({this.section, this.courseId, super.key});
  final String? section, courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SliverToBoxAdapter(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (section != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => context.go('/campus'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Campus dashboard'),
                  ),
                ),
              ref
                  .watch(campusDataProvider)
                  .when(
                    skipLoadingOnRefresh: false,
                    loading: () => const Column(
                      children: [
                        CampusIllustration(icon: Icons.school_outlined),
                        AppLoader(label: 'Loading your campus day'),
                      ],
                    ),
                    error: (_, _) => AppErrorBanner(
                      message: 'Campus could not be loaded. Please try again.',
                      actionLabel: 'Retry',
                      onAction: () => ref.invalidate(campusDataProvider),
                    ),
                    data: (data) => _content(context, data),
                  ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context, CampusData data) {
    if (section == 'resources') {
      return const Column(
        children: [
          CampusIllustration(icon: Icons.folder_open_outlined),
          AppEmptyState(
            title: 'Your resource shelf',
            message: 'Course files and shared notes will live here. Uploads are not available in Phase 1.',
          ),
        ],
      );
    }
    if (section == 'course') {
      final matches = data.courses.where((course) => course.id == courseId);
      if (matches.isEmpty) {
        return const AppEmptyState(
          title: 'Course not found',
          message: 'Return to the dashboard to choose a sample course.',
        );
      }
      final course = matches.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading(context, course.title),
          Text('${course.code} · ${course.instructor}\n${course.room}'),
          const SizedBox(height: AppSpacing.lg),
          _events(
            context,
            'Classes',
            data.classes.where((e) => e.courseId == course.id).toList(),
          ),
          _events(
            context,
            'Deadlines',
            data.deadlines.where((e) => e.courseId == course.id).toList(),
          ),
          const AppEmptyState(
            icon: Icons.folder_open_outlined,
            title: 'Course materials',
            message: 'Files and lecture notes are a Phase 1 placeholder.',
          ),
        ],
      );
    }
    if (section == 'classes') {
      return _events(context, 'Class schedule', data.classes);
    }
    if (section == 'deadlines') {
      return _events(context, 'Upcoming deadlines', data.deadlines);
    }
    if (section == 'courses') return _courses(context, data.courses);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(context, 'Your campus day'),
        const Text('Wednesday, 11 November · Sample week'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make room for a focused day.',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${data.classes.length} classes · ${data.deadlines.length} upcoming deadlines · ${data.courses.length} courses',
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final action in [
              ('Class schedule', 'classes', Icons.calendar_today_outlined),
              ('Deadlines', 'deadlines', Icons.flag_outlined),
              ('Campus tasks', 'tasks', Icons.checklist),
              ('Resources', 'resources', Icons.folder_open_outlined),
            ])
              OutlinedButton.icon(
                onPressed: () => context.go('/campus/${action.$2}'),
                icon: Icon(action.$3),
                label: Text(action.$1),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 760 &&
                MediaQuery.textScalerOf(context).scale(16) <= 24;
            final classes = _events(
              context,
              'Upcoming classes',
              data.classes.take(2).toList(),
              link: 'classes',
            );
            final deadlines = _events(
              context,
              'Due next',
              data.deadlines.take(2).toList(),
              link: 'deadlines',
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: classes),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: deadlines),
                    ],
                  )
                : Column(children: [classes, deadlines]);
          },
        ),
        _courses(context, data.courses),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Sample data only. No calendar is connected and no reminders are scheduled.',
        ),
      ],
    );
  }

  Widget _heading(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    ),
  );

  Widget _events(
    BuildContext context,
    String title,
    List<CampusEvent> events, {
    String? link,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(context, title),
      if (events.isEmpty)
        const AppEmptyState(
          icon: Icons.event_available_outlined,
          title: 'A little breathing room',
          message: 'Nothing is scheduled here yet.',
        ),
      for (final event in events)
        CampusTile(
          title: event.title,
          eyebrow: event.when,
          detail: event.detail,
          icon: Icons.event_note_outlined,
          onTap: section == 'course'
              ? null
              : () => context.go('/campus/courses/${event.courseId}'),
        ),
      if (link != null)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => context.go('/campus/$link'),
            child: Text('View all $link'),
          ),
        ),
      const SizedBox(height: AppSpacing.lg),
    ],
  );

  Widget _courses(BuildContext context, List<CampusCourse> courses) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(context, 'Your courses'),
      if (courses.isEmpty)
        const AppEmptyState(
          icon: Icons.school_outlined,
          title: 'A fresh semester',
          message: 'Your courses will appear here when they are available.',
        ),
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            for (final course in courses)
              SizedBox(
                width:
                    constraints.maxWidth >= 900 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 24
                    ? (constraints.maxWidth - 2 * AppSpacing.md) / 3
                    : constraints.maxWidth,
                child: CampusTile(
                  title: course.title,
                  eyebrow: course.code,
                  detail: '${course.instructor}\n${course.room}',
                  icon: Icons.menu_book_outlined,
                  onTap: () => context.go('/campus/courses/${course.id}'),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class CampusTile extends StatelessWidget {
  const CampusTile({
    required this.title,
    required this.eyebrow,
    required this.detail,
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String title, eyebrow, detail;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(eyebrow, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(detail),
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                const Icon(Icons.arrow_forward, semanticLabel: 'Open course'),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class CampusIllustration extends StatelessWidget {
  const CampusIllustration({required this.icon, super.key});
  final IconData icon;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: CircleAvatar(
        radius: 56,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          icon,
          size: 56,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    ),
  );
}
