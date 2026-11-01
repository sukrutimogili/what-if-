import 'package:flutter/material.dart';

import '../services/prompt_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DecorShape(
              kind: DecorKind.flower,
              color: AppColors.yellow,
              size: 110,
              child: Text('?', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 24),
            Text('What If?', style: AppTheme.display(32)),
            const SizedBox(height: 20),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the prompt dataset cannot be loaded.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.error_outline,
          color: AppColors.coral,
          title: 'The prompts would not load',
          message: 'Check that ${PromptRepository.assetPath} exists and is '
              'listed under "assets:" in pubspec.yaml, then restart the app.\n\n'
              '$error',
          actionLabel: 'Try again',
          onAction: onRetry,
        ),
      ),
    );
  }
}
