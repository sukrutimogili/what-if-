import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/navigation.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/pill_button.dart';

/// A single prompt, full screen, with save / write / copy actions.
class PromptDetailScreen extends StatelessWidget {
  const PromptDetailScreen({super.key, required this.prompt});

  final WhatIfPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final category = state.repo.categoryById(prompt.categoryId);
    final color = AppTheme.categoryColor(prompt.categoryId);
    final saved = state.isSaved(prompt.id);
    final entry = state.entryFor(prompt.id);

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final big = constraints.maxWidth >= 700;
            return Stack(
              children: [
                Positioned(
                  right: -60,
                  bottom: -60,
                  child: DecorShape(
                    kind: decorForCategory(prompt.categoryId),
                    color: Colors.white.withValues(alpha: 0.3),
                    size: big ? 360 : 240,
                    angle: 0.4,
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(big ? 32 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 28),
                          TagChip(
                            label: category?.name ?? 'Prompt',
                            categoryId: prompt.categoryId,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            prompt.text,
                            style: AppTheme.display(big ? 46 : 32),
                          ),
                          const SizedBox(height: 30),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              PillButton(
                                label: entry == null
                                    ? 'Write your response'
                                    : 'Edit your response',
                                icon: Icons.edit_outlined,
                                onPressed: () => openCreate(
                                  context,
                                  prompt,
                                  entry: entry,
                                ),
                              ),
                              PillButton(
                                label: saved ? 'Saved' : 'Save',
                                icon: saved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                style: PillStyle.light,
                                onPressed: () => state.toggleSaved(prompt.id),
                              ),
                              PillButton(
                                label: 'Copy',
                                icon: Icons.copy_rounded,
                                style: PillStyle.outline,
                                onPressed: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  await Clipboard.setData(
                                    ClipboardData(text: prompt.text),
                                  );
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Prompt copied'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (entry != null) ...[
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your response · '
                                    '${formatDate(entry.updatedAt)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(entry.response, style: AppTheme.body(16)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
