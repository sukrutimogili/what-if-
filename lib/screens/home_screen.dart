import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/category_tile.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/hero_card.dart';
import '../widgets/pill_button.dart';

/// Discover: intro, featured prompt, daily challenge and category shortcuts.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final side = Responsive.sidePadding(width);
        final inner = width - side * 2;
        final compact = width < 700;
        final twoColumns = inner >= 700;

        final featuredSaved = state.isSaved(state.featured.id);
        final dailyDone = state.hasResponseFor(state.daily.id);

        final featuredCard = HeroCard(
          label: 'Featured prompt',
          prompt: state.featured,
          color: AppColors.yellow,
          kind: DecorKind.flower,
          textSize: twoColumns ? 30 : 26,
          onTap: () => openPrompt(context, state.featured),
          actions: [
            PillButton(
              label: 'Write',
              icon: Icons.edit_outlined,
              onPressed: () => openCreate(context, state.featured),
            ),
            RoundIconButton(
              icon: featuredSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              tooltip: featuredSaved ? 'Remove from saved' : 'Save prompt',
              background: AppColors.cream,
              onPressed: () => state.toggleSaved(state.featured.id),
            ),
            RoundIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Show another featured prompt',
              background: AppColors.cream,
              onPressed: state.refreshFeatured,
            ),
          ],
        );

        final dailyCard = HeroCard(
          label: 'Daily challenge · ${formatLongDate(now)}',
          prompt: state.daily,
          color: AppColors.pink,
          kind: DecorKind.burst,
          textSize: twoColumns ? 30 : 26,
          onTap: () => openPrompt(context, state.daily),
          actions: [
            PillButton(
              label: dailyDone ? 'Edit your response' : 'Accept challenge',
              icon: dailyDone ? Icons.edit_outlined : Icons.bolt_rounded,
              onPressed: () => openCreate(
                context,
                state.daily,
                entry: state.entryFor(state.daily.id),
              ),
            ),
            if (dailyDone)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        );

        final categories = state.repo.categories;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 20, side, 0),
                child: Row(
                  children: [
                    if (compact)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecorShape(
                            kind: DecorKind.flower,
                            color: AppColors.yellow,
                            size: 34,
                            child: Text(
                              '?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'What If?',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        formatLongDate(now),
                        style: AppTheme.body(15).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.search_rounded,
                      tooltip: 'Search prompts',
                      onPressed: () => state.goToTab(1),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(
                      icon: Icons.bookmark_border_rounded,
                      tooltip: 'Saved prompts',
                      onPressed: () => state.goToTab(3),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 28, side, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Headline(
                      bold: 'Imagine, Create,',
                      italic: 'Enjoy',
                      size: twoColumns ? 58 : 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ask "what if?" and see where your mind wanders.',
                      style: AppTheme.body(16),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        QuickAction(
                          label: 'Surprise me',
                          icon: Icons.auto_awesome,
                          dark: true,
                          onTap: () => state.goToTab(2),
                        ),
                        QuickAction(
                          label: 'Create',
                          icon: Icons.add_rounded,
                          onTap: () => openCreate(context, state.daily),
                        ),
                        QuickAction(
                          label: 'Saved ${state.savedIds.length}',
                          icon: Icons.bookmark_border_rounded,
                          onTap: () => state.goToTab(3),
                        ),
                        QuickAction(
                          label: 'Journey ${state.entries.length}',
                          icon: Icons.auto_stories_outlined,
                          onTap: () => state.goToTab(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 28, side, 0),
                child: twoColumns
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: featuredCard),
                            const SizedBox(width: 24),
                            Expanded(child: dailyCard),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          featuredCard,
                          const SizedBox(height: 18),
                          dailyCard,
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 36, side, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text('Explore by mood', style: AppTheme.display(26)),
                    ),
                    TextButton(
                      onPressed: () => state.goToTab(1),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            if (compact)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: side),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => SizedBox(
                      width: 260,
                      child: CategoryTile(category: categories[i]),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: side),
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
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}
