import 'package:flutter/material.dart';

import '../../game/tower_bloxx_game.dart';
import '../game_ui.dart';

class PerfectBonusOverlay extends StatefulWidget {
  final int trigger;
  const PerfectBonusOverlay({super.key, required this.trigger});

  @override
  State<PerfectBonusOverlay> createState() => _PerfectBonusOverlayState();
}

class _PerfectBonusOverlayState extends State<PerfectBonusOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.35, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
    ]).animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(_controller);
    _rise = Tween<double>(begin: 0, end: -72)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_controller);
  }

  @override
  void didUpdateWidget(PerfectBonusOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.value == 0) return const SizedBox.shrink();

        return Center(
          child: Transform.translate(
            offset: Offset(0, _rise.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PERFECT!',
                      style: GameUi.lilita(
                        size: 28,
                        color: GameUi.titleCoral,
                        letterSpacing: 1.2,
                        shadows: const [
                          Shadow(
                            color: Color(0xAA000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${TowerBloxxGame.perfectBonusPoints}',
                      style: GameUi.lilita(
                        size: 64,
                        color: GameUi.btnYellow,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF1A1A1A),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                          Shadow(
                            color: Color(0x99000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
