import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({required this.label, this.value, super.key})
    : assert(value == null || (value >= 0 && value <= 1));

  final String label;

  /// Null is indeterminate; otherwise a fraction between zero and one.
  final double? value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: value == null ? null : '${(value! * 100).round()}%',
    liveRegion: true,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: value),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}
