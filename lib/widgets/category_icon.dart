import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Line icon for a prompt category, drawn from `assets/icons/`.
///
/// Replaces the emoji that used to be read from the JSON file so every icon
/// shares the same 24px grid, rounded 1.8 stroke and ink colour.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.categoryId,
    this.size = 22,
    this.color = AppColors.ink,
  });

  /// Category id, or null for the generic sparkle.
  final String? categoryId;
  final double size;
  final Color color;

  static const Set<String> _known = {
    'alternate_realities',
    'beautifully_absurd',
    'science_fiction',
    'human_psychology',
    'storytelling',
  };

  static String assetFor(String? categoryId) {
    final id = _known.contains(categoryId) ? categoryId : 'default';
    return 'assets/icons/category_$id.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetFor(categoryId),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
