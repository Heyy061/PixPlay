import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameObject extends PositionComponent with CollisionCallbacks {
  final String objectName;
  final String objectType;
  final VoidCallback? onCollected;
  final Vector2 gameSize;
  final bool isEnemy;
  
 double enemyDirection = 1;
 GameObject({
  required this.objectName,
  required this.objectType,
  required Vector2 position,
  required this.gameSize,
  this.isEnemy = false,
  this.onCollected,
}) : super(
        position: position,
        size: objectType.toLowerCase().contains('goal')
            ? Vector2.all(60)
            : Vector2.all(40),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }
//////////////////////
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = _getColor();

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: objectName.isNotEmpty ? objectName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
//////////////////////////////////
  Color _getColor() {
    final type = objectType.toLowerCase();

    if (type.contains('collect')) {
      return Colors.orange;
    }

    if (type.contains('enemy')) {
      return Colors.red;
    }

    if (type.contains('obstacle')) {
      return Colors.grey;
    }

    if (type.contains('goal')) {
      return Colors.green;
    }

    return Colors.purple;
  }
///////////////////////////////
 
 @override
void update(double dt) {
  super.update(dt);

  if (!isEnemy) return;

  const speed = 80.0;

  position.x += speed * enemyDirection * dt;

  final leftLimit = size.x / 2;
  final rightLimit = gameSize.x - size.x / 2;

  if (position.x >= rightLimit) {
    position.x = rightLimit;
    enemyDirection = -1;
  }

  if (position.x <= leftLimit) {
    position.x = leftLimit;
    enemyDirection = 1;
  }
}
}
