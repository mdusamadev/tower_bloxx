import 'package:flutter/material.dart';

import '../../game/tower_bloxx_game.dart';
import '../game_ui.dart';

class GameOverOverlay extends StatelessWidget {
  final TowerBloxxGame game;
  const GameOverOverlay({super.key, required this.game});

  TextStyle _style({
    required double size,
    Color color = Colors.white,
    double height = 1.0,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) =>
      GameUi.lilita(
        size: size,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        shadows: shadows,
      );

  @override
  Widget build(BuildContext context) {
    final score = game.score;

    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            color: GameUi.panelBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GameUi.panelBorder, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                textAlign: TextAlign.center,
                style: _style(
                  size: 40,
                  color: GameUi.titleCoral,
                  shadows: const [
                    Shadow(
                      color: Color(0x80000000),
                      offset: Offset(0, 3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'FINAL SCORE',
                style: _style(
                    size: 14, color: GameUi.labelGray, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                '$score',
                style: _style(
                  size: 88,
                  shadows: const [
                    Shadow(
                      color: Color(0x55000000),
                      offset: Offset(0, 3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'BLOCKS STACKED: $score',
                style: _style(
                    size: 13, color: GameUi.labelGray, letterSpacing: 0.8),
              ),
              const SizedBox(height: 28),
              _PlayAgainButton(
                onTap: game.restart,
                style: _style(size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayAgainButton extends StatelessWidget {
  const _PlayAgainButton({required this.onTap, required this.style});

  final VoidCallback onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: GameUi.btnYellow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameUi.panelBorder, width: 3),
          boxShadow: const [
            BoxShadow(
              color: GameUi.btnYellowDark,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          'PLAY AGAIN',
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: GameUi.panelBorder,
            letterSpacing: 1.0,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
