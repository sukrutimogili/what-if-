import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/prompt_tile.dart';

/// Bookmarked prompts, most recently saved first.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final saved = state.savedIds
        .map(state.repo.promptById)
        .whereType<WhatIfPrompt>()
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final side = Responsive.sidePadding(width);
        final columns = Responsive.columnsFor(width - side * 2);
        final big = width >= 700;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 28, side, 22),
                child: Headline(
                  bold: 'Saved',
                  italic: saved.isEmpty
                      ? 'your favourites live here'
                      : '${saved.length} '
                          '${saved.length == 1 ? 'prompt' : 'prompts'} '
                          'you love',
                  size: big ? 52 : 38,
                ),
              ),
            ),
            if (saved.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  color: AppColors.pink,
                  title: 'Nothing saved yet',
                  message: 'Tap the bookmark on any prompt and it will wait '
                      'for you here.',
                  actionLabel: 'Find something to love',
                  onAction: () => state.goToTab(2),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 32),
                sliver: RowGridSliver(
                  count: saved.length,
                  columns: columns,
                  itemBuilder: (context, i) => PromptTile(prompt: saved[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
