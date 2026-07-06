import 'package:flutter/material.dart';

import '../../game/tower_bloxx_game.dart';
import '../game_ui.dart';
import 'perfect_bonus_overlay.dart';

class ScoreHudOverlay extends StatelessWidget {
  final TowerBloxxGame game;
  const ScoreHudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: GameUi.panelBg,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: GameUi.panelBorder, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x55000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '${game.score}',
                          style: GameUi.lilita(
                            size: 44,
                            shadows: const [
                              Shadow(
                                color: Color(0x55000000),
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PerfectBonusOverlay(trigger: game.bonusTriggerCount),
              ],
            ),
          ),
        );
      },
    );
  }
}
