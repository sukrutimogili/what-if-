import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/prompt_batcher.dart';
import '../utils/responsive.dart';
import '../widgets/batch_controls.dart';
import '../widgets/category_icon.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/pill_button.dart';
import '../widgets/prompt_tile.dart';

/// Prompts in one category, shown 10 at a time in a shuffled order so each
/// visit is a fresh browsing session without repeats.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final PromptCategory category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey _listTop = GlobalKey();
  PromptBatcher? _batcher;

  void _afterBatchChange() {
    setState(() {});
    // The new batch replaces the old one, so bring its top into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _listTop.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final state = AppScope.of(context);
    final color = AppTheme.categoryColor(category.id);
    final prompts = state.repo.byCategory(category.id);
    final batcher = _batcher ??= PromptBatcher(prompts, shuffle: true);
    final batch = batcher.current;

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
                                CategoryIcon(
                                  categoryId: category.id,
                                  size: 40,
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
                  ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        key: _listTop,
                        padding: EdgeInsets.fromLTRB(side, 4, side, 14),
                        child: Text(
                          batcher.total <= batcher.batchSize
                              ? '${batcher.total} prompts'
                              : 'Showing ${batcher.rangeStart}\u2013'
                                  '${batcher.rangeEnd} of ${batcher.total}',
                          style: AppTheme.body(14).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, 0, side, 16),
                      sliver: RowGridSliver(
                        count: batch.length,
                        columns: columns,
                        itemBuilder: (context, i) =>
                            PromptTile(prompt: batch[i]),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, 0, side, 40),
                      sliver: SliverToBoxAdapter(
                        child: BatchControls(
                          batcher: batcher,
                          onNext: () {
                            batcher.next();
                            _afterBatchChange();
                          },
                          onRestart: () {
                            batcher.restart();
                            _afterBatchChange();
                          },
                          finishedMessage:
                              'You have seen all ${batcher.total} prompts '
                              'in ${category.name}.',
                          restartLabel: 'Shuffle and start again',
                        ),
                      ),
                    ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}
