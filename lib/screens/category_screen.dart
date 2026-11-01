import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/pill_button.dart';
import '../widgets/prompt_tile.dart';

/// All prompts in one category.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final PromptCategory category;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final color = AppTheme.categoryColor(category.id);
    final prompts = state.repo.byCategory(category.id);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final side = Responsive.sidePadding(width);
            final columns = Responsive.columnsFor(width - side * 2);
            final big = width >= 700;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(side, 16, side, 20),
                    child: Material(
                      color: color,
                      borderRadius: BorderRadius.circular(36),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned(
                            right: -40,
                            top: -40,
                            child: DecorShape(
                              kind: decorForCategory(category.id),
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 190,
                              angle: 0.3,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(big ? 32 : 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RoundIconButton(
                                  icon: Icons.arrow_back_rounded,
                                  tooltip: 'Back',
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 38),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: AppTheme.display(big ? 48 : 34),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  category.description,
                                  style: AppTheme.displayItalic(big ? 22 : 18),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    PillButton(
                                      label: 'Surprise me from here',
                                      icon: Icons.auto_awesome,
                                      onPressed: () {
                                        final pick = state.repo.randomPrompt(
                                          categoryId: category.id,
                                        );
                                        if (pick != null) {
                                          openPrompt(context, pick);
                                        }
                                      },
                                    ),
                                    Text(
                                      '${prompts.length} prompts',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (prompts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No prompts here yet',
                      message: 'This category has no prompts in the dataset.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 32),
                    sliver: RowGridSliver(
                      count: prompts.length,
                      columns: columns,
                      itemBuilder: (context, i) =>
                          PromptTile(prompt: prompts[i]),
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
