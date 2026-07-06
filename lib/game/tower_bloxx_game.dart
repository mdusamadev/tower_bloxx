import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart' show TapDownInfo;
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import '../audio/game_audio.dart';
import 'components/fixed_hook_mount.dart';
import 'components/ground_platform.dart';
import 'components/suspended_load.dart';
import 'components/swing_trail.dart';
import 'mode.dart';
import 'models/swing_ghost.dart';

class TowerBloxxGame extends FlameGame with TapDetector, ChangeNotifier {
  static const double floorWidth = 150;
  static const double floorHeight = floorWidth * 600 / 960;

  static const double pivotScreenY = 52;
  static const double swingArmFactor = 0.28;
  static const double groundBottomMargin = 24;
  static const double gravity = 2200;
  static const double perfectTol = 1.0;
  static const int perfectBonusPoints = 5;
  static const double minOverlapRatio = 0.6;
  static const double toppleAngularAccel = 3.2;
  static const double toppleHorizontalDrift = 110;
  static const double swingGravity = 2500;
  static const double loadMass = 14.0;
  static const double inertiaMultiplier = 3.2;
  static const double angleGainPerFloor = 0.16;
  static const double swingSpeedGainPerFloor = 0.04;
  static const double maxSwingSpeedMultiplier = 3.0;
  static const double maxSwingAngleLimit = pi;
  static const double baseAngularVelocity = 0.55;
  static const double swingMargin = 2;
  static const double extraSwingReach = 16;
  static const int swingGhostCount = 4;
  static const double swingGhostInterval = 0.048;

  final List<SpriteComponent> stack = [];
  final List<String> _floorAssets = const [
    'floor-terracotta-brick.png',
    'floor-cream-sandstone.png',
    'floor-modern-glass.png',
  ];

  late final List<Sprite> _floorSprites;
  late final Sprite _clawSprite;

  SpriteComponent? active;
  SuspendedLoadComponent? suspendedLoad;
  Mode mode = Mode.swinging;
  double _vy = 0;
  double _pendulumAngle = 0;
  double _angularVelocity = 0;
  double _toppleAngularVel = 0;
  double _toppleDir = 1;

  double pivotX = 0;
  double pivotY = 0;
  double swingArmLength = 0;
  double startMaxAngle = 0.5;
  double _maxSwingAngle = 0.5;
  double _swingSpeedMultiplier = 1.0;

  final List<SwingGhost> swingGhosts = [];
  double _ghostTimer = 0;

  int score = 0;
  int bonusTriggerCount = 0;
  bool gameOver = false;

  late final GroundPlatformComponent _ground;
  late final FixedHookMountComponent _fixedHook;
  double groundTopY = 0;
  double _stackSlideT = 1;
  static const double _stackSlideDuration = 0.28;

  @override
  Future<void> onLoad() async {
    await GameAudio.preload();
    await GameAudio.startMusic();

    final bg = await loadParallaxComponent(
      [ParallaxImageData('bg-starry-night.png')],
      baseVelocity: Vector2.zero(),
      fill: LayerFill.height,
    );
    camera.backdrop.add(bg);

    _floorSprites = [
      for (final a in _floorAssets) await loadSprite(a),
    ];
    _clawSprite = await loadSprite('crane-claw-with-hook.png');

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);

    _recalcSwingGeometry();
    groundTopY = _computeGroundTopY();

    _ground = GroundPlatformComponent();
    world.add(_ground);
    world.add(SwingTrailComponent());

    suspendedLoad = SuspendedLoadComponent(clawSprite: _clawSprite);
    world.add(suspendedLoad!);

    _fixedHook = FixedHookMountComponent();
    world.add(_fixedHook);

    _startGame();
  }

  double _computeGroundTopY() {
    const platformH = GroundPlatformComponent.totalHeight;
    return size.y / 2 + size.y / 2 - groundBottomMargin - platformH;
  }

  void _beginStackSlide() {
    _stackSlideT = 0;
  }

  void _updateStackSlide(double dt) {
    if (_stackSlideT >= 1) return;

    final prev = _stackSlideT;
    _stackSlideT = min(1, _stackSlideT + dt / _stackSlideDuration);
    final delta = (_stackSlideT - prev) * floorHeight;
    for (final block in stack) {
      block.position.y += delta;
    }
  }

  double get chainLength => _chainLength;

  double get _chainLength => _floorTopDist - SuspendedLoadLayout.buildingGripY;

  double get floorTopDist => _floorTopDist;

  double get _floorTopDist =>
      swingArmLength - SuspendedLoadLayout.floorTopInsetFromArmEnd;

  double get _floorBottomDist => _floorTopDist + floorHeight;

  double get _pendulumComDist {
    const clawMass = 1.0;
    const floorMass = 9.0;
    final clawMid = _chainLength + SuspendedLoadLayout.buildingGripY * 0.55;
    final floorMid = _floorTopDist + floorHeight * 0.5;
    return (clawMid * clawMass + floorMid * floorMass) / (clawMass + floorMass);
  }

  void _recalcSwingGeometry() {
    swingArmLength = size.y * swingArmFactor;

    final halfReach =
        size.x / 2 - floorWidth / 2 - swingMargin + extraSwingReach;

    const targetAngle = 0.88;
    final minBottomDist = halfReach / sin(targetAngle);
    if (_floorBottomDist < minBottomDist) {
      swingArmLength = minBottomDist -
          floorHeight +
          SuspendedLoadLayout.floorTopInsetFromArmEnd;
    }

    startMaxAngle = asin(min(1.0, halfReach / _floorBottomDist));
  }

  Vector2 _floorLocalToWorld(SpriteComponent floor, double lx, double ly) {
    final sinA = sin(floor.angle);
    final cosA = cos(floor.angle);
    return Vector2(
      floor.position.x + lx * cosA + ly * sinA,
      floor.position.y - lx * sinA + ly * cosA,
    );
  }

  (double left, double right) _floorHorizontalSpan(SpriteComponent floor) {
    final w = floor.size.x;
    final h = floor.size.y;
    final corners = [
      _floorLocalToWorld(floor, -w / 2, 0),
      _floorLocalToWorld(floor, w / 2, 0),
      _floorLocalToWorld(floor, w / 2, h),
      _floorLocalToWorld(floor, -w / 2, h),
    ];
    var left = corners.first.x;
    var right = corners.first.x;
    for (final c in corners.skip(1)) {
      left = min(left, c.x);
      right = max(right, c.x);
    }
    return (left, right);
  }

  double _floorLowestY(SpriteComponent floor) {
    final w = floor.size.x;
    final h = floor.size.y;
    return [
      _floorLocalToWorld(floor, -w / 2, 0),
      _floorLocalToWorld(floor, w / 2, 0),
      _floorLocalToWorld(floor, w / 2, h),
      _floorLocalToWorld(floor, -w / 2, h),
    ].map((p) => p.y).reduce(max);
  }

  SpriteComponent _makeFloor(int level) {
    return SpriteComponent(
      sprite: _floorSprites[level % _floorSprites.length],
      size: Vector2(floorWidth, floorHeight),
      anchor: Anchor.topCenter,
    );
  }

  void _startGame() {
    groundTopY = _computeGroundTopY();
    _ground.position = Vector2(size.x / 2, groundTopY);
    _stackSlideT = 1;
    _initPendulum();
    _spawnFloor();
  }

  ({double left, double right, double top, double centerX}) _supportSurface() {
    if (stack.isNotEmpty) {
      final below = stack.last;
      return (
        left: below.position.x - below.size.x / 2,
        right: below.position.x + below.size.x / 2,
        top: below.position.y,
        centerX: below.position.x,
      );
    }
    return (
      left: size.x / 2 - floorWidth / 2,
      right: size.x / 2 + floorWidth / 2,
      top: groundTopY,
      centerX: size.x / 2,
    );
  }

  void _spawnFloor() {
    final floor = _makeFloor(stack.length);
    active = floor;
    mode = Mode.swinging;
    _vy = 0;
    suspendedLoad!.claw.opacity = 1;
    suspendedLoad!.attachBuilding(floor);
    _updateSwingingLayout(_pendulumAngle);
  }

  void _initPendulum() {
    swingGhosts.clear();
    _ghostTimer = 0;
    _swingSpeedMultiplier = 1.0;
    _maxSwingAngle = startMaxAngle;
    _pendulumAngle = -_maxSwingAngle;
    _angularVelocity = baseAngularVelocity;
  }

  void _reflectAtSwingLimits() {
    if (_pendulumAngle > _maxSwingAngle) {
      _pendulumAngle = _maxSwingAngle;
      if (_angularVelocity > 0) _angularVelocity = -_angularVelocity;
    } else if (_pendulumAngle < -_maxSwingAngle) {
      _pendulumAngle = -_maxSwingAngle;
      if (_angularVelocity < 0) _angularVelocity = -_angularVelocity;
    }
  }

  void _updatePendulumPhysics(double dt) {
    final step = dt * _swingSpeedMultiplier;
    final ropeLength = _pendulumComDist;
    final inertia = loadMass * ropeLength * ropeLength * inertiaMultiplier;

    final torque =
        -(loadMass * swingGravity * ropeLength) * sin(_pendulumAngle);
    final angularAccel = torque / inertia;

    _angularVelocity += angularAccel * step;
    _pendulumAngle += _angularVelocity * step;

    _reflectAtSwingLimits();
  }

  void _detachActiveFloor() {
    final floor = active!;
    final pos = floor.absolutePosition;
    final ang = floor.absoluteAngle;
    floor.removeFromParent();
    world.add(floor);
    floor.position = pos;
    floor.angle = ang;
  }

  void _updateSwingGhosts(double dt) {
    if (mode != Mode.swinging || active == null) {
      swingGhosts.clear();
      return;
    }
    _ghostTimer += dt;
    if (_ghostTimer < swingGhostInterval) return;
    _ghostTimer = 0;

    final f = active!;
    final pos = f.absolutePosition;
    swingGhosts.insert(
      0,
      SwingGhost(pos.x, pos.y, f.absoluteAngle, f.sprite!),
    );
    while (swingGhosts.length > swingGhostCount) {
      swingGhosts.removeLast();
    }
  }

  void _updateSwingingLayout(double angle) {
    suspendedLoad?.position = Vector2(pivotX, pivotY);
    suspendedLoad?.angle = angle;
    suspendedLoad?.syncChildOffsets(_floorTopDist);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameOver) return;
    if (mode == Mode.swinging && active != null) {
      _detachActiveFloor();
      mode = Mode.falling;
      _vy = 0;
      GameAudio.drop();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    pivotX = size.x / 2;
    pivotY = pivotScreenY;
    _fixedHook.position = Vector2(pivotX, pivotY);

    _updateStackSlide(dt);

    final floor = active;
    if (floor != null) {
      if (mode == Mode.swinging) {
        _updatePendulumPhysics(dt);
        _updateSwingingLayout(_pendulumAngle);
        _updateSwingGhosts(dt);
      } else if (mode == Mode.falling) {
        swingGhosts.clear();
        _vy += gravity * dt;
        floor.position.y += _vy * dt;
        final support = _supportSurface();
        if (_floorLowestY(floor) >= support.top) {
          floor.position.y -= _floorLowestY(floor) - support.top;
          _land();
        }
      } else if (mode == Mode.toppling) {
        _toppleAngularVel += _toppleDir * toppleAngularAccel * dt;
        floor.angle += _toppleAngularVel * dt;
        _vy += gravity * dt;
        floor.position.y += _vy * dt;
        floor.position.x += _toppleDir * toppleHorizontalDrift * dt;

        final offScreen = floor.position.y > size.y + floorHeight ||
            floor.position.x < -floorWidth ||
            floor.position.x > size.x + floorWidth;
        if (offScreen) {
          _endGame();
        }
      }
    }
  }

  void _land() {
    final floor = active!;
    final support = _supportSurface();

    final (aLeft, aRight) = _floorHorizontalSpan(floor);
    final overlap = min(aRight, support.right) - max(aLeft, support.left);
    if (overlap < floor.size.x * minOverlapRatio) {
      _startTopple(floor, support.left, support.right, support.centerX);
      return;
    }

    floor.angle = 0;
    floor.position = Vector2(floor.position.x, support.top - floorHeight);

    final offset = (floor.position.x - support.centerX).abs();
    final isPerfect = offset < perfectTol;
    score += 1;
    GameAudio.land();
    if (isPerfect) {
      score += perfectBonusPoints;
      bonusTriggerCount++;
      GameAudio.perfect();
    }
    notifyListeners();

    stack.add(floor);
    active = null;

    _swingSpeedMultiplier = min(
      _swingSpeedMultiplier + swingSpeedGainPerFloor,
      maxSwingSpeedMultiplier,
    );
    _maxSwingAngle = min(
      _maxSwingAngle + angleGainPerFloor,
      maxSwingAngleLimit,
    );
    _angularVelocity *= 1 + swingSpeedGainPerFloor;
    if (stack.length > 1) {
      _beginStackSlide();
    }

    _spawnFloor();
  }

  void _startTopple(
    SpriteComponent floor,
    double supportLeft,
    double supportRight,
    double supportCenter,
  ) {
    mode = Mode.toppling;
    _vy = 40;
    GameAudio.gameOver();
    _toppleDir =
        _overhangDirection(floor, supportLeft, supportRight, supportCenter);
    floor.angle = _toppleDir * 0.12;
    _toppleAngularVel = _toppleDir * 1.4;
  }

  double _overhangDirection(
    SpriteComponent floor,
    double supportLeft,
    double supportRight,
    double supportCenter,
  ) {
    final (aLeft, aRight) = _floorHorizontalSpan(floor);
    final leftHang = max(0.0, supportLeft - aLeft);
    final rightHang = max(0.0, aRight - supportRight);
    if (rightHang == leftHang) {
      return floor.position.x >= supportCenter ? 1 : -1;
    }
    return rightHang > leftHang ? 1 : -1;
  }

  void _endGame() {
    gameOver = true;
    overlays.add('gameOver');
  }

  void restart() {
    for (final child in suspendedLoad!.children.toList()) {
      if (child is SpriteComponent && child != suspendedLoad!.claw) {
        child.removeFromParent();
      }
    }
    world.removeWhere(
      (c) => c is SpriteComponent && c.parent != suspendedLoad,
    );
    stack.clear();
    active = null;
    mode = Mode.swinging;
    score = 0;
    bonusTriggerCount = 0;
    gameOver = false;
    notifyListeners();
    _recalcSwingGeometry();
    camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    _stackSlideT = 1;
    overlays.remove('gameOver');
    _startGame();
  }
}
