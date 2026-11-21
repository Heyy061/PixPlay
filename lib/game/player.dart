import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'dart:math';

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
  }) : super(position: position, size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 gameSize;
  final String playerVisual;
  final VoidCallback onHitEnemy;
  final VoidCallback onReachedGoal;
  final String movementType;
  final String playerType;

  final Set<LogicalKeyboardKey> keysPressed = {};
  Vector2 joystickDirection = Vector2.zero();
  Vector2 previousPosition = Vector2.zero();
  bool _enemyCooldown = false;
  double _time = 0;

  void setJoystickDirection(Vector2 direction) {
    joystickDirection = direction;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 24, position: Vector2(32, 34)));
  }

  String get _visual {
    return '${playerVisual.toLowerCase()} ${playerType.toLowerCase()}';
  }

  Color _skin() {
    if (_visual.contains('robot') ||
        _visual.contains('machine') ||
        _visual.contains('android')) {
      return const Color(0xFFB7C6D1);
    }
    if (_visual.contains('alien')) return const Color(0xFF8BE28B);
    return const Color(0xFFFFC6A5);
  }

  Color _shirt() {
    if (_visual.contains('wizard') || _visual.contains('mage'))
      return const Color(0xFF6A3FA0);
    if (_visual.contains('knight') || _visual.contains('warrior'))
      return const Color(0xFF426B9A);
    if (_visual.contains('ninja')) return const Color(0xFF24262C);
    if (_visual.contains('robot') || _visual.contains('machine'))
      return const Color(0xFF526775);
    if (_visual.contains('fire') || _visual.contains('flame'))
      return const Color(0xFFD9572B);
    return const Color(0xFF4F9A62);
  }

  Color _hair() {
    if (_visual.contains('blond') || _visual.contains('yellow'))
      return const Color(0xFFE5B94B);
    if (_visual.contains('white') || _visual.contains('snow'))
      return const Color(0xFFE9E9E9);
    if (_visual.contains('robot') || _visual.contains('machine'))
      return const Color(0xFF33414B);
    return const Color(0xFF2B211D);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bob = sin(_time * 8) * 1.5;
    canvas.save();
    canvas.translate(0, bob);

    CharacterRenderer.drawPlayer(
      canvas: canvas,
      size: Size(size.x, size.y),
      visual: playerVisual,
      playerType: playerType,
    );

    canvas.restore();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    previousPosition = position.clone();
    position += event.localDelta;
    _clampToWorld();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!movementType.toLowerCase().contains('keyboard')) return false;
    this.keysPressed
      ..clear()
      ..addAll(keysPressed);
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    previousPosition = position.clone();
    const speed = 250.0;

    if (joystickDirection.length > 0.01) {
      position += joystickDirection * speed * dt;
    }

    if (movementType.toLowerCase().contains('keyboard')) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW))
        position.y -= speed * dt;
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS))
        position.y += speed * dt;
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA))
        position.x -= speed * dt;
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD))
        position.x += speed * dt;
    }

    _clampToWorld();
  }

  void _clampToWorld() {
    final half = size.x / 2;
    position.x = position.x.clamp(half, gameSize.x - half);
    position.y = position.y.clamp(half, gameSize.y - half);
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
      other.onCollected?.call();
      other.removeFromParent();
      return;
    }

    if (type.contains('enemy')) {
      if (_enemyCooldown) return;
      _enemyCooldown = true;
      onHitEnemy();
      Future.delayed(
        const Duration(milliseconds: 800),
        () => _enemyCooldown = false,
      );
      return;
    }

    if (type.contains('obstacle')) {
      position = previousPosition;
      return;
    }

    if (type.contains('goal')) {
      onReachedGoal();
    }
  }
}
