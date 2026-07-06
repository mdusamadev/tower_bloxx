import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game/tower_bloxx_game.dart';
import 'ui/overlays/game_over_overlay.dart';
import 'ui/overlays/score_hud_overlay.dart';

class TowerBloxxApp extends StatelessWidget {
  const TowerBloxxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.lilitaOneTextTheme(),
      ),
      home: GameWidget<TowerBloxxGame>(
        game: TowerBloxxGame(),
        overlayBuilderMap: {
          'hud': (context, game) => ScoreHudOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}
