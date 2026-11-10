
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameObject extends PositionComponent
    with CollisionCallbacks {
  GameObject({
    required this.objectName,
    required this.objectType,
    required Vector2 position,
    required this.gameSize,
    this.isEnemy = false,
    this.targetPlayer,
    this.enemySpeed = 60,
    this.onCollected,
  }) : super(
          position: position,
          size: objectType.toLowerCase().contains('goal')
              ? Vector2.all(60)
              : Vector2.all(40),
          anchor: Anchor.center,
        );

  final String objectName;
  final String objectType;
  final Vector2 gameSize;

  final bool isEnemy;
  final PositionComponent? targetPlayer;
  final double enemySpeed;

  final VoidCallback? onCollected;

  // =============================== ONLOAD ===============================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(),
    );
  }

  // =============================== OBJECT TYPE ===============================

  String get _type {
    return objectType.toLowerCase();
  }

  // =============================== COLOR ===============================

  Color _getObjectColor() {
    // COLLECTIBLE

    if (_isCollectible()) {
      if (_type.contains('coin')) {
        return Colors.amber;
      }

      if (_type.contains('key')) {
        return Colors.yellowAccent;
      }

      if (_type.contains('gem') ||
          _type.contains('crystal') ||
          _type.contains('rune')) {
        return Colors.cyanAccent;
      }

      if (_type.contains('fruit') ||
          _type.contains('cherry')) {
        return Colors.pinkAccent;
      }

      return Colors.orangeAccent;
    }

    // ENEMY

    if (_type.contains('enemy')) {
      return Colors.redAccent;
    }

    // OBSTACLE

    if (_type.contains('obstacle')) {
      return Colors.grey;
    }

    // GOAL

    if (_type.contains('goal') ||
        _type.contains('portal') ||
        _type.contains('destination')) {
      return Colors.greenAccent;
    }

    return Colors.deepPurpleAccent;
  }

  // =============================== SHAPE ===============================

  bool _isCollectible() {
    return _type.contains('collect') ||
        _type.contains('item') ||
        _type.contains('coin') ||
        _type.contains('key') ||
        _type.contains('cherry') ||
        _type.contains('rune') ||
        _type.contains('gem') ||
        _type.contains('fruit');
  }

  // =============================== RENDER ===============================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final color = _getObjectColor();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // ================= COLLECTIBLE =================

    if (_isCollectible()) {
      _drawCollectible(
        canvas,
        center,
        paint,
      );

      return;
    }

    // ================= ENEMY =================

    if (_type.contains('enemy')) {
      _drawEnemy(
        canvas,
        center,
        paint,
      );

      return;
    }

    // ================= OBSTACLE =================

    if (_type.contains('obstacle')) {
      _drawObstacle(
        canvas,
        center,
        paint,
      );

      return;
    }

    // ================= GOAL =================

    if (_type.contains('goal') ||
        _type.contains('portal') ||
        _type.contains('destination')) {
      _drawGoal(
        canvas,
        center,
        paint,
      );

      return;
    }

    // ================= DEFAULT =================

    canvas.drawCircle(
      center,
      size.x / 2,
      paint,
    );
  }

  // =============================== COLLECTIBLE ===============================

  void _drawCollectible(
    Canvas canvas,
    Offset center,
    Paint paint,
  ) {
    // Diamond-shaped collectible

    final path = Path()
      ..moveTo(
        center.dx,
        4,
      )
      ..lineTo(
        size.x - 4,
        center.dy,
      )
      ..lineTo(
        center.dx,
        size.y - 4,
      )
      ..lineTo(
        4,
        center.dy,
      )
      ..close();

    canvas.drawPath(
      path,
      paint,
    );

    // Inner highlight

    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final smallPath = Path()
      ..moveTo(
        center.dx,
        9,
      )
      ..lineTo(
        center.dx + 7,
        center.dy,
      )
      ..lineTo(
        center.dx,
        center.dy + 5,
      )
      ..lineTo(
        center.dx - 7,
        center.dy,
      )
      ..close();

    canvas.drawPath(
      smallPath,
      highlight,
    );
  }

  // =============================== ENEMY ===============================

  void _drawEnemy(
    Canvas canvas,
    Offset center,
    Paint paint,
  ) {
    // Main body

    canvas.drawCircle(
      center,
      size.x / 2,
      paint,
    );

    // Eyes

    final eyePaint = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      Offset(
        center.dx - 7,
        center.dy - 5,
      ),
      5,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + 7,
        center.dy - 5,
      ),
      5,
      eyePaint,
    );

    // Pupils

    final pupilPaint = Paint()
      ..color = Colors.black;

    canvas.drawCircle(
      Offset(
        center.dx - 7,
        center.dy - 5,
      ),
      2,
      pupilPaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + 7,
        center.dy - 5,
      ),
      2,
      pupilPaint,
    );

    // Mouth

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + 5,
        ),
        width: 18,
        height: 10,
      ),
      0,
      pi,
      false,
      mouthPaint,
    );
  }

  // =============================== OBSTACLE ===============================

  void _drawObstacle(
    Canvas canvas,
    Offset center,
    Paint paint,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.x,
        height: size.y,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      rect,
      paint,
    );

    // Cross lines

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(7, 7),
      Offset(size.x - 7, size.y - 7),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.x - 7, 7),
      Offset(7, size.y - 7),
      linePaint,
    );
  }

  // =============================== GOAL ===============================

  void _drawGoal(
    Canvas canvas,
    Offset center,
    Paint paint,
  ) {
    // Outer ring

    final ringPaint = Paint()
      ..color = colorWithOpacity(
        paint.color,
        0.35,
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      size.x / 2,
      ringPaint,
    );

    // Inner portal

    final innerPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      size.x / 3,
      innerPaint,
    );

    // Center

    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.7);

    canvas.drawCircle(
      center,
      size.x / 7,
      centerPaint,
    );
  }

  Color colorWithOpacity(
    Color color,
    double opacity,
  ) {
    return color.withOpacity(opacity);
  }

  // =============================== ENEMY MOVEMENT ===============================

  @override
  void update(double dt) {
    super.update(dt);

    if (!isEnemy || targetPlayer == null) {
      return;
    }

    final direction =
        targetPlayer!.position - position;

    if (direction.length > 5) {
      direction.normalize();

      position +=
          direction * enemySpeed * dt;
    }

    // Keep enemy inside screen

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
