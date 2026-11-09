import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game_obj.dart';

class Player extends PositionComponent with DragCallbacks, CollisionCallbacks {
  Player({
    required Vector2 position,
    required this.gameSize,
    required this.onHitEnemy,
  }) : super(position: position, size: Vector2.all(50), anchor: Anchor.center);

  final Vector2 gameSize;
  final VoidCallback onHitEnemy;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }

  //////////////////////////////////////////
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color.fromARGB(255, 24, 24, 216);

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }

  /////////////////////////////////////////
  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;

    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    position.x = position.x.clamp(halfWidth, gameSize.x - halfWidth);

    position.y = position.y.clamp(halfHeight, gameSize.y - halfHeight);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is! GameObject) return;

    final type = other.objectType.toLowerCase();

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

  if (type.contains('enemy')) {
  print('PLAYER HIT ENEMY');

  onHitEnemy();

  return;
}
  }
}
