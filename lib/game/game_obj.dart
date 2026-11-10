import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameObject extends PositionComponent with CollisionCallbacks {
  final String objectName;
  final String objectType;
  final VoidCallback? onCollected;
  final Vector2 gameSize;
  final bool isEnemy;
final PositionComponent? targetPlayer;
  double enemyDirection = 1;
 GameObject({
  required this.objectName,
  required this.objectType,
  required Vector2 position,
  required this.gameSize,
  this.isEnemy = false,
  this.targetPlayer,
  this.onCollected,
}) : super(
  position: position,
  size: objectType.toLowerCase().contains('goal')
      ? Vector2.all(60)
      : Vector2.all(40),
  anchor: Anchor.center,
);
////////////////////////////////////////
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleHitbox());
  }

  //////////////////////
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final type = objectType.toLowerCase();

    Color color;

    if (type.contains('collect') ||
        type.contains('item') ||
        type.contains('coin') ||
        type.contains('key') ||
        type.contains('gem') ||
        type.contains('fruit') ||
        type.contains('cherry') ||
        type.contains('rune')) {
      color = Colors.amber;
    } else if (type.contains('enemy')) {
      color = Colors.red;
    } else if (type.contains('obstacle')) {
      color = Colors.grey;
    } else if (type.contains('goal') ||
        type.contains('portal') ||
        type.contains('destination')) {
      color = Colors.greenAccent;
    } else {
      color = Colors.deepPurpleAccent;
    }

    final paint = Paint()..color = color;

  if (type.contains('enemy')) {
  // Enemy → diamond
  final path = Path();

  path.moveTo(size.x / 2, 0);
  path.lineTo(size.x, size.y / 2);
  path.lineTo(size.x / 2, size.y);
  path.lineTo(0, size.y / 2);
  path.close();

  canvas.drawPath(path, paint);
} else if (type.contains('obstacle')) {
  // Obstacle → square
  canvas.drawRect(
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    ),
    paint,
  );
} else if (type.contains('goal') ||
    type.contains('portal') ||
    type.contains('destination')) {
  // Goal → ring
  canvas.drawCircle(
    Offset(size.x / 2, size.y / 2),
    size.x / 2,
    paint,
    );

  final innerPaint = Paint()
    ..color = Colors.black;

  canvas.drawCircle(
    Offset(size.x / 2, size.y / 2),
    size.x / 3,
    innerPaint,
  );
} else {
  // Collectible / other → circle
  canvas.drawCircle(
    Offset(size.x / 2, size.y / 2),
    size.x / 2,
    paint,
  );
}

    // First letter of the object name
    final letter = objectName.isNotEmpty ? objectName[0].toUpperCase() : '?';

    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
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

  ////////////////////////////////// GET COLOR
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
  ///////////////////////////////UPDATE

 @override
void update(double dt) {
  super.update(dt);

  if (!isEnemy || targetPlayer == null) return;

  const speed = 60.0;

  final direction = targetPlayer!.position - position;

  if (direction.length > 5) {
    direction.normalize();
    position += direction * speed * dt;
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
