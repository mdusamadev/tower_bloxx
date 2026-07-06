import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../tower_bloxx_game.dart';

class GroundPlatformComponent extends PositionComponent
    with HasGameReference<TowerBloxxGame> {
  static const double hazardH = 16;
  static const double slabH = 26;
  static const double earthH = 48;
  static const double totalHeight = hazardH + slabH + earthH;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topCenter;
    size = Vector2(game.size.x + 80, totalHeight);
    position = Vector2(game.size.x / 2, game.groundTopY);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final hazardPaint = Paint()..color = const Color(0xFFF5C518);
    final hazardDark = Paint()..color = const Color(0xFF1A1A1A);
    const stripeW = 14.0;

    for (var x = -stripeW; x < w + stripeW; x += stripeW * 2) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeW, 0)
        ..lineTo(x + stripeW - hazardH, hazardH)
        ..lineTo(x - hazardH, hazardH)
        ..close();
      canvas.drawPath(path, (x ~/ stripeW).isEven ? hazardPaint : hazardDark);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, hazardH, w, slabH),
      Paint()..color = const Color(0xFF6B7280),
    );

    final earthRect = Rect.fromLTWH(0, hazardH + slabH, w, earthH);
    canvas.drawRect(earthRect, Paint()..color = const Color(0xFF5C4033));
    final rockPaint = Paint()..color = const Color(0xFF4A3428);
    for (var i = 0; i < 18; i++) {
      final rx = (i * 47.0 + 13) % w;
      final ry = hazardH + slabH + 8 + (i * 19.0) % (earthH - 16);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(rx, ry), width: 10 + i % 5, height: 7),
        rockPaint,
      );
    }
  }
}
