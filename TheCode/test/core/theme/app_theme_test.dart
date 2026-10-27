import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarteeb/core/theme/app_theme.dart';

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    test('${theme.brightness.name} text roles meet 4.5:1 contrast', () {
      final c = theme.colorScheme;
      final pairs = <String, (Color, Color)>{
        'primary': (c.onPrimary, c.primary),
        'primary container': (c.onPrimaryContainer, c.primaryContainer),
        'secondary': (c.onSecondary, c.secondary),
        'secondary container': (c.onSecondaryContainer, c.secondaryContainer),
        'tertiary': (c.onTertiary, c.tertiary),
        'tertiary container': (c.onTertiaryContainer, c.tertiaryContainer),
        'error': (c.onError, c.error),
        'error container': (c.onErrorContainer, c.errorContainer),
        'surface': (c.onSurface, c.surface),
        'workspace label': (c.onSurfaceVariant, c.surface),
        'task card': (c.onSurface, c.surfaceContainerLow),
        'navigation label': (c.onSurfaceVariant, c.surfaceContainer),
        'dialog': (c.onSurface, c.surfaceContainerHigh),
        'inverse surface': (c.onInverseSurface, c.inverseSurface),
      };
      for (final entry in pairs.entries) {
        expect(
          contrast(entry.value.$1, entry.value.$2),
          greaterThanOrEqualTo(4.5),
          reason: entry.key,
        );
      }
      expect(
        contrast(c.primary, c.surfaceContainerLow),
        greaterThanOrEqualTo(3),
      );
      expect(contrast(c.error, c.surface), greaterThanOrEqualTo(3));
    });
  }
}
