import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../mode.dart';
import '../tower_bloxx_game.dart';

class SwingTrailComponent extends Component
    with HasGameReference<TowerBloxxGame> {
  @override
  void render(Canvas canvas) {
    final g = game;
    if (g.mode != Mode.swinging || g.swingGhosts.isEmpty) return;

    final n = g.swingGhosts.length;
    for (var i = 0; i < n; i++) {
      final ghost = g.swingGhosts[i];
      final t = (i + 1) / (n + 1);
      final alpha = (1 - t) * 0.42;

      canvas.save();
      canvas.translate(ghost.x, ghost.y);
      canvas.rotate(ghost.angle);
      ghost.sprite.render(
        canvas,
        size: Vector2(TowerBloxxGame.floorWidth, TowerBloxxGame.floorHeight),
        anchor: Anchor.topCenter,
        overridePaint: Paint()..color = Color.fromRGBO(255, 255, 255, alpha),
      );
      canvas.restore();
    }
  }
}
