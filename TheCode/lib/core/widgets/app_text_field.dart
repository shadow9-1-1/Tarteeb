import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// A Form-compatible input. [errorText] is a caller-owned server error and
/// takes precedence over [validator] until the caller clears it.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.validator,
    this.errorText,
    this.helperText,
    this.hintText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.focusNode,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.key,
  }) : assert(controller == null || initialValue == null),
       assert(!obscureText || maxLines == 1);

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final String? helperText;
  final String? hintText;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FocusNode? focusNode;
  final int? maxLines;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ),
      const SizedBox(height: AppSpacing.sm),
      Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          forceErrorText: errorText,
          // A widget rather than a single-line error string preserves long messages.
          errorBuilder: (context, message) => Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helper: helperText == null ? null : Text(helperText!),
          ),
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          focusNode: focusNode,
          maxLines: maxLines,
          autovalidateMode: autovalidateMode,
        ),
      ),
    ],
  );
}
