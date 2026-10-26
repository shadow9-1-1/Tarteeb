import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source imports respect the documented dependency directions', () {
    final violations = <String>[];
    final directives = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');
    final root = Directory.current.uri;
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = root.resolve(file.path.replaceAll('\\', '/'));
      final path = source.path;
      for (final match in directives.allMatches(file.readAsStringSync())) {
        final import = match.group(1)!;
        final target = import.startsWith('package:tarteeb/')
            ? root
                  .resolve('lib/${import.substring('package:tarteeb/'.length)}')
                  .path
            : source.resolve(import).path;
        final external =
            import.startsWith('package:') &&
            !import.startsWith('package:tarteeb/');
        void reject(bool condition) {
          if (condition) violations.add('${file.path} -> $import');
        }

        if (path.contains('/domain/')) {
          reject(
            external ||
                (!import.startsWith('dart:') && !target.contains('/domain/')),
          );
        }
        if (path.contains('/core/')) {
          reject(target.contains('/features/') || target.contains('/app/'));
        }
        if (path.contains('/features/')) reject(target.contains('/app/'));
        if (path.contains('/features/shared/')) {
          reject(
            target.contains('/features/campus/') ||
                target.contains('/features/personal/'),
          );
        }
        if (path.contains('/features/campus/')) {
          reject(target.contains('/features/personal/'));
        }
        if (path.contains('/features/personal/')) {
          reject(target.contains('/features/campus/'));
        }
        if (path.contains('/presentation/') || path.contains('/application/')) {
          reject(
            target.contains('/data/') ||
                import.contains('firebase') ||
                import.contains('cloud_firestore'),
          );
        }
        if (path.contains('/application/')) {
          reject(
            target.contains('/presentation/') ||
                import.startsWith('package:flutter/'),
          );
        }
        if (path.contains('/data/')) {
          reject(
            target.contains('/presentation/') ||
                target.contains('/application/'),
          );
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
