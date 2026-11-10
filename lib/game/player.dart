
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_obj.dart';

class Player extends PositionComponent
    with KeyboardHandler, CollisionCallbacks {
  Player({
    required Vector2 position,
    required this.gameSize,
    required this.onHitEnemy,
    required this.onReachedGoal,
    required this.movementType,
    required this.playerType,
  }) : super(
          position: position,
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  final Vector2 gameSize;

  final VoidCallback onHitEnemy;
  final VoidCallback onReachedGoal;

  final String movementType;
  final String playerType;

  final Set<LogicalKeyboardKey> keysPressed = {};

  bool _enemyCooldown = false;

  Vector2 previousPosition = Vector2.zero();

  // =============================== ONLOAD ===============================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }

  // =============================== PLAYER COLOR ===============================

  Color _getPlayerColor() {
    final type = playerType.toLowerCase();

    if (type.contains('robot') ||
        type.contains('machine') ||
        type.contains('android')) {
      return Colors.blueGrey;
    }

    if (type.contains('wizard') ||
        type.contains('mage') ||
        type.contains('magic')) {
      return Colors.deepPurple;
    }

    if (type.contains('knight') ||
        type.contains('warrior') ||
        type.contains('fighter')) {
      return Colors.blue;
    }

    if (type.contains('alien')) {
      return Colors.greenAccent;
    }

    if (type.contains('monster')) {
      return Colors.redAccent;
    }

    if (type.contains('ninja')) {
      return Colors.black;
    }

    if (type.contains('fire') ||
        type.contains('flame')) {
      return Colors.deepOrange;
    }

    return Colors.blue;
  }

  // =============================== RENDER ===============================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = _getPlayerColor();

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
  }

  // =============================== DRAG / TOUCH ===============================

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final movement = movementType.toLowerCase();

    if (movement.contains('drag') ||
        movement.contains('touch') ||
        movement.contains('joystick')) {
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

    if (type.contains('goal')) {
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

    final movement = movementType.toLowerCase();

    if (!movement.contains('keyboard')) {
      return;
    }

    previousPosition = position.clone();

    const speed = 250.0;

    // UP

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      position.y -= speed * dt;
    }

    // DOWN

    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      position.y += speed * dt;
    }

    // LEFT

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      position.x -= speed * dt;
    }

    // RIGHT

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      position.x += speed * dt;
    }

    // Keep player inside screen

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
