import 'package:flutter/material.dart';

/// Palette taken from the reference UI: warm cream, buttery yellow, bubblegum
/// pink, sage green, periwinkle blue and near-black ink.
class AppColors {
  AppColors._();

  static const Color cream = Color(0xFFFBF4E4);
  static const Color ink = Color(0xFF191919);
  static const Color yellow = Color(0xFFF8D96B);
  static const Color pink = Color(0xFFF6B8D8);
  static const Color sage = Color(0xFFA9B97D);
  static const Color periwinkle = Color(0xFFB9C8EE);
  static const Color coral = Color(0xFFF5A58C);
  static const Color magenta = Color(0xFFD9438C);
}

class AppTheme {
  AppTheme._();

  static Color categoryColor(String categoryId) {
    switch (categoryId) {
      case 'alternate_realities':
        return AppColors.periwinkle;
      case 'beautifully_absurd':
        return AppColors.pink;
      case 'science_fiction':
        return AppColors.sage;
      case 'human_psychology':
        return AppColors.yellow;
      case 'storytelling':
        return AppColors.coral;
      default:
        return AppColors.yellow;
    }
  }

  /// Heavy, tightly tracked headline (e.g. "Activities").
  static TextStyle display(double size) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -size * 0.025,
        color: AppColors.ink,
      );

  /// Light italic companion (e.g. "just for your taste").
  static TextStyle displayItalic(double size) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        height: 1.1,
        letterSpacing: -size * 0.02,
        color: AppColors.ink,
      );

  static TextStyle body([double size = 15]) => TextStyle(
        fontSize: size,
        height: 1.4,
        color: AppColors.ink,
      );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.yellow,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.ink,
      onPrimary: AppColors.cream,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: AppColors.cream),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
