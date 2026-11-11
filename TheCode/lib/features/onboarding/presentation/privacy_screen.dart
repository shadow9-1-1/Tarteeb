import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_frame.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({
    required this.onContinue,
    required this.onBack,
    super.key,
  });
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => OnboardingFrame(
    title: 'Your plans. Your choice.',
    subtitle: 'A little clarity before you begin.',
    step: 1,
    onBack: onBack,
    children: [
      const IntroductionCard(
        icon: Icons.shield_outlined,
        title: 'Know what stays on this device',
        message:
            'We save your setup progress and preferred space on this device. '
            'The previews contain fictional plans. Exploring them does not create an account or upload your plans.',
      ),
      const SizedBox(height: AppSpacing.md),
      const IntroductionCard(
        icon: Icons.notifications_none_rounded,
        title: 'Reminders can wait',
        message:
            'Notifications are not enabled in this preview, and we will not ask for permission now. '
            'When reminders are available, you can decide whether to turn them on.',
      ),
      const SizedBox(height: AppSpacing.lg),
      AppButton(
        label: 'Choose your space',
        icon: Icons.arrow_forward,
        onPressed: onContinue,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Continue without enabling notifications.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}
