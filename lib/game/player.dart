import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/game/character_render.dart';

import 'game_obj.dart';

class Player extends PositionComponent
    with KeyboardHandler, DragCallbacks, CollisionCallbacks {
  Player({
    required Vector2 position,
    required this.gameSize,
    required this.onHitEnemy,
    required this.onReachedGoal,
    required this.movementType,
    required this.playerType,
    required this.playerVisual,
  }) : super(
          position: position,
          size: Vector2(70, 100),
          anchor: Anchor.center,
        );

  final Vector2 gameSize;

  final VoidCallback onHitEnemy;
  final VoidCallback onReachedGoal;

  final String movementType;
  final String playerType;
  final String playerVisual;

  final Set<LogicalKeyboardKey> keysPressed = {};

  bool _enemyCooldown = false;

  Vector2 previousPosition = Vector2.zero();
  Vector2 joystickDirection = Vector2.zero();

  void setJoystickDirection(Vector2 direction) {
    joystickDirection = direction;
  }

  // =============================== ONLOAD ===============================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }

  // =============================== RENDER ===============================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    CharacterRenderer.drawPlayer(
      canvas: canvas,
      size: Size(size.x, size.y),
      visual: playerVisual,
      playerType: playerType,
    );
  }

  // =============================== DRAG / TOUCH ===============================

  @override
  void onDragUpdate(DragUpdateEvent event) {
    previousPosition = position.clone();

    position += event.localDelta;

    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    position.x = position.x.clamp(
      halfWidth,
      gameSize.x - halfWidth,
    );

    position.y = position.y.clamp(
      halfHeight,
      gameSize.y - halfHeight,
    );
  }

  // =============================== COLLISION ===============================

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (other is! GameObject) return;

    final type = other.objectType.toLowerCase();

    // ================= COLLECTIBLE =================

    if (type.contains('collect') ||
        type.contains('item') ||
        type.contains('coin') ||
        type.contains('key') ||
        type.contains('cherry') ||
        type.contains('rune') ||
        type.contains('gem') ||
        type.contains('fruit')) {
      print('COLLECTED: ${other.objectName}');

      other.onCollected?.call();
      other.removeFromParent();

      return;
    }

    // ================= ENEMY =================

    if (type.contains('enemy')) {
      if (_enemyCooldown) return;

      print('PLAYER HIT ENEMY');

      _enemyCooldown = true;

      onHitEnemy();

      Future.delayed(
        const Duration(milliseconds: 800),
        () {
          _enemyCooldown = false;
        },
      );

      return;
    }

    // ================= OBSTACLE =================

    if (type.contains('obstacle')) {
      print('PLAYER HIT OBSTACLE');

      position = previousPosition;

      return;
    }

    // ================= GOAL =================

    if (type.contains('goal') ||
        type.contains('portal') ||
        type.contains('destination')) {
      print('PLAYER REACHED GOAL');

      onReachedGoal();

      return;
    }
  }

  // =============================== KEYBOARD ===============================

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final movement = movementType.toLowerCase();

    if (!movement.contains('keyboard')) {
      return false;
    }

    this.keysPressed
      ..clear()
      ..addAll(keysPressed);

    return true;
  }

  // =============================== UPDATE ===============================

  @override
  void update(double dt) {
    super.update(dt);

    previousPosition = position.clone();

    const speed = 250.0;

    // ================= JOYSTICK =================

    if (joystickDirection.length > 0) {
      position += joystickDirection * speed * dt;
    }

    // ================= KEYBOARD =================

    final movement = movementType.toLowerCase();

    if (movement.contains('keyboard')) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        position.y -= speed * dt;
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        position.y += speed * dt;
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        position.x -= speed * dt;
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        position.x += speed * dt;
      }
    }

    // ================= SCREEN BOUNDS =================

    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    position.x = position.x.clamp(
      halfWidth,
      gameSize.x - halfWidth,
    );

    position.y = position.y.clamp(
      halfHeight,
      gameSize.y - halfHeight,
    );
  }
}