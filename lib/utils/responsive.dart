import 'dart:math' as math;

enum ScreenSize { compact, medium, expanded }

/// Breakpoints and helpers shared by all screens.
///
/// * compact  (< 700 px)   phones      -> bottom navigation pill
/// * medium   (700-1100)   tablets     -> icon sidebar
/// * expanded (>= 1100)    laptops     -> labelled sidebar, centred content
class Responsive {
  Responsive._();

  static const double maxContentWidth = 1180;

  static ScreenSize of(double width) {
    if (width < 700) return ScreenSize.compact;
    if (width < 1100) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  /// Horizontal padding that keeps content inside [maxContentWidth] and
  /// centred on very wide windows.
  static double sidePadding(double width) {
    final gutter = width < 700
        ? 20.0
        : width < 1100
            ? 28.0
            : 36.0;
    if (width > maxContentWidth + gutter * 2) {
      return (width - maxContentWidth) / 2;
    }
    return gutter;
  }

  /// How many columns of [minTile]-wide cards fit in [innerWidth].
  static int columnsFor(
    double innerWidth, {
    double minTile = 360,
    double gap = 16,
    int maxColumns = 3,
  }) {
    final n = ((innerWidth + gap) / (minTile + gap)).floor();
    return math.max(1, math.min(maxColumns, n));
  }
}
