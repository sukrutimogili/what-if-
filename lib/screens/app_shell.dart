import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/decor.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'journey_screen.dart';
import 'saved_screen.dart';
import 'surprise_screen.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<_NavItem> _items = [
  _NavItem('Discover', Icons.home_outlined, Icons.home_rounded),
  _NavItem('Explore', Icons.explore_outlined, Icons.explore),
  _NavItem('Surprise', Icons.auto_awesome_outlined, Icons.auto_awesome),
  _NavItem('Saved', Icons.bookmark_border_rounded, Icons.bookmark_rounded),
  _NavItem('Journey', Icons.auto_stories_outlined, Icons.auto_stories),
];

/// Adaptive navigation:
///  * phones: floating dark pill at the bottom with a centred Surprise button
///  * tablets: slim dark sidebar with icons
///  * laptops/desktops: wide dark sidebar with labels
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final body = IndexedStack(
      index: state.tabIndex,
      children: const [
        HomeScreen(),
        ExploreScreen(),
        SurpriseScreen(),
        SavedScreen(),
        JourneyScreen(),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Responsive.of(constraints.maxWidth);

        if (size == ScreenSize.compact) {
          return Scaffold(
            body: SafeArea(bottom: false, child: body),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PillNavBar(
                index: state.tabIndex,
                onSelect: state.goToTab,
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SideBar(
                  extended: size == ScreenSize.expanded,
                  index: state.tabIndex,
                  onSelect: state.goToTab,
                  onWrite: () => openCreate(context, state.daily),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Phone: bottom pill -----------------------------------------------------

class _PillNavBar extends StatelessWidget {
  const _PillNavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: i == 2
                  ? _CenterButton(
                      selected: index == i,
                      onTap: () => onSelect(i),
                    )
                  : _BarItem(
                      item: _items[i],
                      selected: index == i,
                      onTap: () => onSelect(i),
                    ),
            ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Center(
          child: Icon(
            selected ? item.selectedIcon : item.icon,
            size: 27,
            color: selected
                ? AppColors.yellow
                : AppColors.cream.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: 'Surprise me',
        child: Material(
          color: selected ? AppColors.yellow : AppColors.cream,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.auto_awesome, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Tablet / laptop: sidebar -------------------------------------------------

class _SideBar extends StatelessWidget {
  const _SideBar({
    required this.extended,
    required this.index,
    required this.onSelect,
    required this.onWrite,
  });

  final bool extended;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 232 : 88,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(36),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        children: [
          _Brand(extended: extended),
          const SizedBox(height: 26),
          for (var i = 0; i < _items.length; i++)
            _SideItem(
              item: _items[i],
              extended: extended,
              selected: index == i,
              onTap: () => onSelect(i),
            ),
          const SizedBox(height: 14),
          Divider(color: AppColors.cream.withValues(alpha: 0.18)),
          const SizedBox(height: 10),
          _SideItem(
            item: const _NavItem(
              'Write',
              Icons.edit_outlined,
              Icons.edit_outlined,
            ),
            extended: extended,
            selected: false,
            accent: AppColors.pink,
            onTap: onWrite,
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final mark = DecorShape(
      kind: DecorKind.flower,
      color: AppColors.yellow,
      size: 40,
      child: Text(
        '?',
        style: AppTheme.display(18),
      ),
    );
    if (!extended) return Center(child: mark);
    return Row(
      children: [
        const SizedBox(width: 6),
        mark,
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'What If?',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              color: AppColors.cream,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.item,
    required this.extended,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final _NavItem item;
  final bool extended;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final highlight = accent ?? AppColors.yellow;
    final background = selected
        ? highlight
        : accent != null
            ? accent!.withValues(alpha: 0.18)
            : Colors.transparent;
    final foreground = selected
        ? AppColors.ink
        : accent != null
            ? accent!
            : AppColors.cream;

    final tile = Material(
      color: background,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment:
                extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: foreground,
                size: 24,
              ),
              if (extended) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: extended ? tile : Tooltip(message: item.label, child: tile),
    );
  }
}
