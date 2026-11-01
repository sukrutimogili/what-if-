import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'decor.dart';
import 'pill_button.dart';

/// Bold headline followed by a light italic line, like
/// "Activities / just for your taste" in the reference.
class Headline extends StatelessWidget {
  const Headline({
    super.key,
    required this.bold,
    this.italic,
    this.size = 40,
  });

  final String bold;
  final String? italic;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: bold, style: AppTheme.display(size)),
          if (italic != null)
            TextSpan(text: '\n$italic', style: AppTheme.displayItalic(size)),
        ],
      ),
    );
  }
}

/// Circular icon button (search, back, bookmark...).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.background = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Small pill shortcut ("Surprise me", "Saved 3"...).
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.cream : AppColors.ink;
    return Material(
      color: dark ? AppColors.ink : Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable pill used for category filters.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? AppColors.cream : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state with a flower illustration.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.yellow,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecorShape(
                kind: DecorKind.flower,
                color: color,
                size: 130,
                child: Icon(icon, size: 48, color: AppColors.ink),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.display(26),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.body(16),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                PillButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline warning, used when the journal database is unavailable.
class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    this.color = AppColors.coral,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTheme.body(14))),
        ],
      ),
    );
  }
}

/// Small ink-coloured label on cards.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cream,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Lays [count] items out in [columns] equal-width columns inside a sliver.
/// Rows share a height, so cards with different text lengths stay aligned.
class RowGridSliver extends StatelessWidget {
  const RowGridSliver({
    super.key,
    required this.count,
    required this.columns,
    required this.itemBuilder,
    this.gap = 16,
  });

  final int count;
  final int columns;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = (count / columns).ceil();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, row) {
          final children = <Widget>[];
          for (var col = 0; col < columns; col++) {
            final index = row * columns + col;
            if (col > 0) children.add(SizedBox(width: gap));
            children.add(
              Expanded(
                child: index < count
                    ? itemBuilder(context, index)
                    : const SizedBox.shrink(),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          );
        },
        childCount: rows,
      ),
    );
  }
}
