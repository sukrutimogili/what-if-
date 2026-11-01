import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum PillStyle { dark, light, outline }

/// Rounded "stadium" button used throughout the app (like "Start ->" in the
/// reference design).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PillStyle.dark,
    this.iconAfter = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillStyle style;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (style) {
      PillStyle.dark => AppColors.ink,
      PillStyle.light => Colors.white,
      PillStyle.outline => Colors.transparent,
    };
    final Color foreground =
        style == PillStyle.dark ? AppColors.cream : AppColors.ink;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.15),
        disabledForegroundColor: AppColors.ink.withValues(alpha: 0.4),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: StadiumBorder(
          side: style == PillStyle.outline
              ? const BorderSide(color: AppColors.ink, width: 1.5)
              : BorderSide.none,
        ),
        textStyle: const TextStyle(
          fontFamily: AppTheme.displayFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !iconAfter) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (icon != null && iconAfter) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      ),
    );
  }
}
