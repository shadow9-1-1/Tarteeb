// Offline widget renders, not device/browser screenshots or golden assertions.
// flutter test tool/capture_screenshots.dart \
//   --dart-define=SCREENSHOT_FONT=<flutter-sdk>/bin/cache/artifacts/material_fonts/roboto-regular.ttf
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/app/demo_tasks.dart';
import 'package:tarteeb/app/tarteeb_app.dart';
import 'package:tarteeb/features/shared/tasks/application/task_providers.dart';
import 'package:tarteeb/features/shared/tasks/data/in_memory_task_repository.dart';
import 'package:tarteeb/features/shared/tasks/domain/task.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_mode.dart';
import 'package:tarteeb/features/shared/tasks/domain/task_repository.dart';

class _PendingRepository implements TaskRepository {
  final result = Completer<List<Task>>();

  @override
  Future<List<Task>> fetchTasks(TaskMode mode) => result.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const fontPath = String.fromEnvironment('SCREENSHOT_FONT');
    if (fontPath.isEmpty) {
      throw ArgumentError(
        'Pass SCREENSHOT_FONT pointing to a local Roboto TTF.',
      );
    }
    final font = FontLoader('Roboto')
      ..addFont(
        File(fontPath)
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)),
      );
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('capture architecture starter states offline', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();

    Future<void> mount(TaskRepository repository) => tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ProviderScope(
          key: ObjectKey(repository),
          overrides: [taskRepositoryProvider.overrideWithValue(repository)],
          child: const TarteebApp(),
        ),
      ),
    );

    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          final file = File('docs/screenshots/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        } finally {
          image.dispose();
        }
      });
    }

    await mount(InMemoryTaskRepository(demoTasks));
    await tester.pumpAndSettle();
    await capture('campus');
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await capture('personal-empty');

    final pending = _PendingRepository();
    await mount(pending);
    await tester.pump(const Duration(milliseconds: 200));
    await capture('loading');
    pending.result.completeError(
      StateError('Synthetic failure for UI evidence'),
    );
    await tester.pumpAndSettle();
    await capture('error');
  });
}
