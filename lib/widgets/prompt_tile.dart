import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import 'category_icon.dart';

/// A prompt in a list: category icon badge, text, bookmark toggle and a
/// check mark when the user has already written a response.
class PromptTile extends StatelessWidget {
  const PromptTile({super.key, required this.prompt});

  final WhatIfPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final color = AppTheme.categoryColor(prompt.categoryId);
    final saved = state.isSaved(prompt.id);
    final done = state.hasResponseFor(prompt.id);
    final radius = BorderRadius.circular(26);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => openPrompt(context, prompt),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: CategoryIcon(categoryId: prompt.categoryId, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    prompt.text,
                    style: AppTheme.title(16.5),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: saved ? 'Remove from saved' : 'Save prompt',
                    onPressed: () => state.toggleSaved(prompt.id),
                    icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: AppColors.ink,
                    ),
                  ),
                  if (done)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Tooltip(
                        message: 'You wrote a response to this',
                        child: Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AppColors.sage,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
