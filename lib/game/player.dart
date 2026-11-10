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
    required this.playerType
  });

  final Vector2 gameSize;
  final VoidCallback onHitEnemy;
  final VoidCallback onReachedGoal;
  final String movementType;
  final Set<LogicalKeyboardKey> keysPressed = {};
  final String playerType;

  Vector2 previousPosition = Vector2.zero();

///////////////////////////////ONLOAD
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }
////////////////////////////////RENDER
 @override
void render(Canvas canvas) {
  super.render(canvas);

  final type = playerType.toLowerCase();

  final paint = Paint();

  if (type.contains('robot') ||
      type.contains('machine')) {
    paint.color = Colors.blueGrey;
  } else if (type.contains('wizard') ||
      type.contains('mage')) {
    paint.color = Colors.deepPurple;
  } else if (type.contains('knight') ||
      type.contains('warrior')) {
    paint.color = Colors.blue;
  } else if (type.contains('alien')) {
    paint.color = Colors.greenAccent;
  } else if (type.contains('monster')) {
    paint.color = Colors.redAccent;
  } else {
    paint.color = Colors.blue;
  }

  canvas.drawCircle(
    Offset(size.x / 2, size.y / 2),
    size.x / 2,
    paint,
  );
}

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

      position.x = position.x.clamp(halfWidth, gameSize.x - halfWidth);

      position.y = position.y.clamp(halfHeight, gameSize.y - halfHeight);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is! GameObject) return;

    final type = other.objectType.toLowerCase();

    // COLLECTIBLE
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

    // ENEMY
    if (type.contains('enemy')) {
      print('PLAYER HIT ENEMY');

      onHitEnemy();

      return;
    }

    // OBSTACLE
    if (type.contains('obstacle')) {
      print('PLAYER HIT OBSTACLE');

      position = previousPosition;

      return;
    }

    // GOAL
    if (type.contains('goal')) {
      print('PLAYER REACHED GOAL');

      onReachedGoal();

      return;
    }
  }
////////////////////////////////////KEYBOARD
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final movement = movementType.toLowerCase();

    if (!movement.contains('keyboard')) {
      return false;
    }

    this.keysPressed
      ..clear()
      ..addAll(keysPressed);

    return true;
  }

  /////////////////////////////UPDATE
  @override
void update(double dt) {
  super.update(dt);

  final movement = movementType.toLowerCase();

  if (!movement.contains('keyboard')) {
    return;
  }

  previousPosition = position.clone();

  const speed = 250.0;

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
