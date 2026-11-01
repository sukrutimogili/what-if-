import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/prompt_batcher.dart';
import 'pill_button.dart';

/// Footer under a batch of prompts: "Show 10 more" while prompts remain, and
/// a restart option once the whole list has been seen.
class BatchControls extends StatelessWidget {
  const BatchControls({
    super.key,
    required this.batcher,
    required this.onNext,
    required this.onRestart,
    required this.finishedMessage,
    required this.restartLabel,
    this.restartIcon = Icons.shuffle_rounded,
  });

  final PromptBatcher batcher;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final String finishedMessage;
  final String restartLabel;
  final IconData restartIcon;

  @override
  Widget build(BuildContext context) {
    if (batcher.hasMore) {
      return Center(
        child: PillButton(
          label: 'Show ${batcher.nextBatchSize} more',
          icon: Icons.arrow_downward_rounded,
          iconAfter: true,
          onPressed: onNext,
        ),
      );
    }

    if (!batcher.isFinished) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          finishedMessage,
          textAlign: TextAlign.center,
          style: AppTheme.body(14).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        PillButton(
          label: restartLabel,
          icon: restartIcon,
          style: PillStyle.outline,
          onPressed: onRestart,
        ),
      ],
    );
  }
}
