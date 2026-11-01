import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/journey_entry_card.dart';

/// My Journey: every prompt the user has answered, newest first.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final entries = state.entries;
    final words = entries.fold<int>(0, (sum, e) => sum + wordCount(e.response));

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
                padding: EdgeInsets.fromLTRB(side, 28, side, 20),
                child: Headline(
                  bold: 'My Journey',
                  italic: 'what you have imagined',
                  size: big ? 52 : 38,
                ),
              ),
            ),
            if (state.journalError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(side, 0, side, 20),
                  child: MessageBanner(
                    message: '${state.journalError!}\n\nOn Linux desktop this '
                        'usually means SQLite is missing: run '
                        '"sudo apt install libsqlite3-dev" and restart.',
                  ),
                ),
              ),
            if (entries.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(side, 0, side, 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          value: '${entries.length}',
                          label: entries.length == 1 ? 'Response' : 'Responses',
                          color: AppColors.yellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          value: '${state.savedIds.length}',
                          label: 'Saved',
                          color: AppColors.pink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          value: '$words',
                          label: words == 1 ? 'Word' : 'Words',
                          color: AppColors.periwinkle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.auto_stories_outlined,
                  color: AppColors.periwinkle,
                  title: 'Your journey starts here',
                  message: 'Answer a prompt and your writing will be kept '
                      'here, on this device.',
                  actionLabel: 'Take today\'s challenge',
                  onAction: state.journalError != null
                      ? null
                      : () => openCreate(context, state.daily),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 32),
                sliver: RowGridSliver(
                  count: entries.length,
                  columns: columns,
                  itemBuilder: (context, i) =>
                      JourneyEntryCard(entry: entries[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTheme.display(30)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
