import 'package:flame/components.dart';

import '../tower_bloxx_game.dart';

/// Local attachment layout — origin is the fixed top pivot / chain start.
abstract final class SuspendedLoadLayout {
  static const double clawW = 110;
  static const double clawH = clawW * 1291 / 598;

  /// Claw top-center → building top-center (claw grip point).
  static const double buildingGripY = 80.2;

  /// Keeps prior floor reach when tuning [TowerBloxxGame.swingArmLength].
  static const double floorTopInsetFromArmEnd = 16;
}

class SuspendedLoadComponent extends PositionComponent
    with HasGameReference<TowerBloxxGame> {
  SuspendedLoadComponent({required this.clawSprite})
      : super(anchor: Anchor.topCenter, priority: 1);

  final Sprite clawSprite;
  late final SpriteComponent claw;

  @override
  Future<void> onLoad() async {
    claw = SpriteComponent(
      sprite: clawSprite,
      size: Vector2(SuspendedLoadLayout.clawW, SuspendedLoadLayout.clawH),
      anchor: Anchor.topCenter,
      priority: 1,
    );
    add(claw);
  }

  /// Position claw + building from the fixed pivot (rope length unchanged).
  void syncChildOffsets(double floorTopY) {
    claw.position = Vector2.zero();
    for (final child in children) {
      if (child is SpriteComponent && child != claw) {
        child.position = Vector2(0, floorTopY);
      }
    }
  }

  void attachBuilding(SpriteComponent building) {
    building
      ..anchor = Anchor.topCenter
      ..priority = 2;
    add(building);
    syncChildOffsets(game.floorTopDist);
  }
}
