import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'game_obj.dart';
import 'player.dart';
import '../models/game_spec.dart';

class GeneratedGame extends FlameGame with HasCollisionDetection {
  final GameSpec gameSpec;

  late TextComponent scoreText;

  int score = 0;
  bool gameWon = false;
  bool gameOver = false;

  GeneratedGame({required this.gameSpec});

  // =========================
  // SCORE
  // =========================

  void addScore(int points) {
    if (gameWon) return;

    score += points;

    scoreText.text = 'Score: $score';

    print('SCORE UPDATED: $score');

    Future.delayed(Duration.zero, checkWinCondition);
  }

  // =========================
  // WIN CONDITION
  // =========================

  void checkWinCondition() {
    if (gameWon) return;

    final collectibles = children.whereType<GameObject>().where(
      (object) => _isCollectible(object.objectType),
    );

    if (collectibles.isEmpty) {
      gameWon = true;

      showWinMessage();
    }
  }

  // =========================
  // CHECK OBJECT TYPE
  // =========================

  bool _isCollectible(String type) {
    final value = type.toLowerCase();

    return value.contains('collect') ||
        value.contains('item') ||
        value.contains('coin') ||
        value.contains('key') ||
        value.contains('cherry') ||
        value.contains('rune') ||
        value.contains('gem') ||
        value.contains('fruit');
  }

  // =========================
  // WIN MESSAGE
  // =========================

  void showWinMessage() {
    add(
      TextComponent(
        text: 'YOU WIN!',
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  /////////////////////////////////////
  void showGameOverMessage() {
  add(
    TextComponent(
      text: 'GAME OVER',
      position: Vector2(
        size.x / 2,
        size.y / 2,
      ),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

  // =========================
  // GAME LOAD
  // =========================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // =========================
    // BACKGROUND
    // =========================

    add(
      RectangleComponent(
        size: size,
        position: Vector2.zero(),
        paint: Paint()..color = _getBackgroundColor(gameSpec.world.background),
      ),
    );

    // =========================
    // TITLE
    // =========================

    add(
      TextComponent(
        text: gameSpec.title,
        position: Vector2(20, 30),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // =========================
    // SCORE
    // =========================

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 70),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreText);

    // =========================
    // PLAYER
    // =========================

   final player = Player(
  position: Vector2(
    size.x / 2,
    size.y - 120,
  ),
  gameSize: size,
  onHitEnemy: () {
    gameOver = true;
    showGameOverMessage();
  },
);
    add(player);

    // =========================
    // GAME OBJECTS
    // =========================

    for (final objectSpec in gameSpec.objects) {
      print(
        'Generated Object: '
        '${objectSpec.name} | '
        'Type: ${objectSpec.type} | '
        'Count: ${objectSpec.count}',
      );

      for (int i = 0; i < objectSpec.count; i++) {
        final gameObject = GameObject(
          objectName: objectSpec.name,
          objectType: objectSpec.type,
          position: Vector2(
            80 + (i * 70) % (size.x - 100),
            180 + ((i * 100) % (size.y - 250)),
          ),
          onCollected: () {
            print('COLLECTED: ${objectSpec.name}');

            addScore(gameSpec.rules.scorePerItem);
          },
        );

        add(gameObject);
      }
    }
  }

  // =========================
  // BACKGROUND COLOR
  // =========================

  Color _getBackgroundColor(String background) {
    final value = background.toLowerCase();

    if (value.contains('forest')) {
      return Colors.green.shade900;
    }

    if (value.contains('space')) {
      return Colors.black;
    }

    if (value.contains('desert')) {
      return Colors.orange.shade800;
    }

    if (value.contains('ocean') || value.contains('water')) {
      return Colors.blue.shade900;
    }

    if (value.contains('snow') || value.contains('ice')) {
      return Colors.blueGrey.shade200;
    }

    if (value.contains('city')) {
      return Colors.grey.shade900;
    }

    return Colors.blueGrey.shade800;
  }
}
