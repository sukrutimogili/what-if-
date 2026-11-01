import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The playful shapes from the reference design: scalloped flowers, tilted
/// rounded squares and circles.
enum DecorKind { flower, burst, squircle, circle }

DecorKind decorForCategory(String categoryId) {
  switch (categoryId) {
    case 'alternate_realities':
      return DecorKind.circle;
    case 'beautifully_absurd':
      return DecorKind.flower;
    case 'science_fiction':
      return DecorKind.squircle;
    case 'human_psychology':
      return DecorKind.burst;
    case 'storytelling':
      return DecorKind.flower;
    default:
      return DecorKind.flower;
  }
}

class DecorShape extends StatelessWidget {
  const DecorShape({
    super.key,
    required this.kind,
    required this.color,
    this.size = 120,
    this.angle = 0,
    this.child,
  });

  final DecorKind kind;
  final Color color;
  final double size;

  /// Rotation in radians.
  final double angle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget shape = switch (kind) {
      DecorKind.circle => DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      DecorKind.squircle => DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.24),
          ),
        ),
      DecorKind.flower => CustomPaint(
          painter: _ScallopPainter(color: color, lobes: 8, depth: 0.07),
        ),
      DecorKind.burst => CustomPaint(
          painter: _ScallopPainter(color: color, lobes: 14, depth: 0.05),
        ),
    };

    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            shape,
            if (child != null) Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _ScallopPainter extends CustomPainter {
  _ScallopPainter({
    required this.color,
    required this.lobes,
    required this.depth,
  });

  final Color color;
  final int lobes;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * 2 * math.pi;
      final r = radius * (1 - depth) + radius * depth * math.cos(lobes * t);
      final point = Offset(
        center.dx + r * math.cos(t),
        center.dy + r * math.sin(t),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScallopPainter old) {
    return old.color != color || old.lobes != lobes || old.depth != depth;
  }
}
