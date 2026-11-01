import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'decor.dart';

/// Large coloured card for the featured prompt and the daily challenge.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.label,
    required this.prompt,
    required this.color,
    required this.kind,
    required this.actions,
    required this.onTap,
    this.textSize = 26,
  });

  final String label;
  final WhatIfPrompt prompt;
  final Color color;
  final DecorKind kind;
  final List<Widget> actions;
  final VoidCallback onTap;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(36),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -36,
              child: DecorShape(
                kind: kind,
                color: Colors.white.withValues(alpha: 0.35),
                size: 150,
                angle: 0.3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TagChip(label: label),
                  const SizedBox(height: 18),
                  Text(prompt.text, style: AppTheme.display(textSize)),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: actions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
