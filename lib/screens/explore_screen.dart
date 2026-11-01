import 'package:flutter/material.dart';

import '../models/prompt.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
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
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final categories = state.repo.categories;
    final searching = _query.trim().length >= 2;
    final List<WhatIfPrompt> results =
        searching ? state.repo.search(_query) : const <WhatIfPrompt>[];

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
                    onChanged: (value) => setState(() => _query = value),
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
                                setState(() => _query = '');
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
            if (!searching)
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
            else if (results.isEmpty)
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
                  padding: EdgeInsets.fromLTRB(side, 0, side, 14),
                  child: Text(
                    results.length >= 60
                        ? 'Showing the first 60 matches'
                        : '${results.length} '
                            '${results.length == 1 ? 'match' : 'matches'}',
                    style: AppTheme.body(14).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 32),
                sliver: RowGridSliver(
                  count: results.length,
                  columns: columns,
                  itemBuilder: (context, i) => PromptTile(prompt: results[i]),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
