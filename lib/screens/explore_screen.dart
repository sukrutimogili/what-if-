import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/prompt_batcher.dart';
import '../utils/responsive.dart';
import '../widgets/batch_controls.dart';
import '../widgets/category_tile.dart';
import '../widgets/common.dart';
import '../widgets/prompt_tile.dart';

/// Explore: browse by category or search all prompts.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _listTop = GlobalKey();
  String _query = '';

  /// Search matches dealt out 10 at a time; null while not searching.
  PromptBatcher? _batcher;

  void _setQuery(String value) {
    final repo = AppScope.of(context).repo;
    setState(() {
      _query = value;
      _batcher = value.trim().length >= 2
          ? PromptBatcher(repo.search(value))
          : null;
    });
  }

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _summary(PromptBatcher b) {
    final matches = b.total >= 60
        ? 'the first 60 matches'
        : '${b.total} ${b.total == 1 ? 'match' : 'matches'}';
    if (b.total <= b.batchSize) return matches;
    return 'Showing ${b.rangeStart}\u2013${b.rangeEnd} of $matches';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final categories = state.repo.categories;
    final batcher = _batcher;
    final List<WhatIfPrompt> results =
        batcher?.current ?? const <WhatIfPrompt>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final side = Responsive.sidePadding(width);
        final columns = Responsive.columnsFor(width - side * 2);
        final big = width >= 700;

        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 28, side, 0),
                child: Headline(
                  bold: 'Explore',
                  italic: 'just for your curiosity',
                  size: big ? 52 : 38,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 22, side, 22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TextField(
                    controller: _controller,
                    onChanged: _setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search ${state.repo.prompts.length} prompts',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _controller.clear();
                                _setQuery('');
                              },
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (batcher == null)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => CategoryTile(category: categories[i]),
                    childCount: categories.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 196,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                ),
              )
            else if (batcher.total == 0)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  color: AppColors.periwinkle,
                  title: 'Nothing matches that',
                  message: 'Try a shorter or different word, like "moon", '
                      '"robot" or "tea".',
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  key: _listTop,
                  padding: EdgeInsets.fromLTRB(side, 0, side, 14),
                  child: Text(
                    _summary(batcher),
                    style: AppTheme.body(14).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 16),
                sliver: RowGridSliver(
                  count: results.length,
                  columns: columns,
                  itemBuilder: (context, i) => PromptTile(prompt: results[i]),
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
                    finishedMessage: 'That is every match for this search.',
                    restartLabel: 'Back to the first 10',
                    restartIcon: Icons.replay_rounded,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
