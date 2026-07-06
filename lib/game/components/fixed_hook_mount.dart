import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../tower_bloxx_game.dart';

class FixedHookMountComponent extends PositionComponent
    with HasGameReference<TowerBloxxGame> {
  FixedHookMountComponent() : super(anchor: Anchor.topCenter, priority: 3);

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = const Color(0xFF4B5563);
    final highlight = Paint()..color = const Color(0xFF9CA3AF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 5), width: 22, height: 12),
        const Radius.circular(3),
      ),
      body,
    );
    canvas.drawCircle(const Offset(0, 2), 4.5, highlight);
    canvas.drawCircle(const Offset(0, 2), 2, body);
  }
}
