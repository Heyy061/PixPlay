import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'game_obj.dart';
import 'player.dart';
import '../models/game_spec.dart';

class GeneratedGame extends FlameGame with HasCollisionDetection {
  final GameSpec gameSpec;

  late TextComponent timerText;
  late TextComponent scoreText;
  late TextComponent healthText;
  late TextComponent objectiveText;
  final Random _random = Random();
  int score = 0;
  int health = 3;
  int maxHealth = 3;
  bool gameWon = false;
  bool gameOver = false;

  double remainingTime = 0;

  int collectedCount = 0;
  int totalCollectibles = 0;

  GeneratedGame({required this.gameSpec});

  // =========================
  // SCORE
  // =========================

  void addScore(int points) {
    if (gameWon || gameOver) return;

    score += points;

    scoreText.text = 'Score: $score';

    print('SCORE UPDATED: $score');
  }

  // =========================
  // WIN CONDITION
  // =========================

  void checkWinCondition() {
    if (gameWon || gameOver) return;

    final type = gameSpec.winCondition.type.toLowerCase();

    // -------------------------
    // COLLECT ALL
    // -------------------------

    if (type.contains('collect')) {
      if (totalCollectibles > 0 && collectedCount >= totalCollectibles) {
        gameWon = true;

        print('GAME WON - ALL COLLECTIBLES COLLECTED');
      }

      return;
    }

    // -------------------------
    // REACH GOAL
    // -------------------------

    if (type.contains('goal') ||
        type.contains('reach') ||
        type.contains('destination') ||
        type.contains('portal')) {
      // Goal collision handles this.
      return;
    }

    // -------------------------
    // SURVIVE
    // -------------------------

    if (type.contains('survive')) {
      if (gameSpec.rules.timeLimit != null && remainingTime <= 0) {
        gameWon = true;

        print('GAME WON - SURVIVED THE TIME LIMIT');
      }
    }
  }

  // =========================
  // LOSE CONDITION
  // =========================

  void triggerLoseCondition(String reason) {
    if (gameWon || gameOver) return;

    final type = gameSpec.loseCondition.type.toLowerCase();

    // -------------------------
    // ENEMY COLLISION
    // -------------------------

    if (reason == 'enemy') {
      if (type.contains('enemy') ||
          type.contains('hit') ||
          type.contains('collision') ||
          type.contains('death')) {
        gameOver = true;

        print('GAME OVER - LOSE CONDITION: ENEMY');

        return;
      }
    }

    // -------------------------
    // TIME EXPIRED
    // -------------------------

    if (reason == 'time') {
      if (type.contains('time') ||
          type.contains('timer') ||
          type.contains('timeout')) {
        gameOver = true;

        print('GAME OVER - LOSE CONDITION: TIME');

        return;
      }
    }

    print(
      'LOSE CONDITION NOT TRIGGERED: '
      '$reason | $type',
    );
  }

  void takeDamage(int damage) {
    if (gameWon || gameOver) return;

    health -= damage;

    if (health < 0) {
      health = 0;
    }

    print('PLAYER HEALTH: $health / $maxHealth');
    healthText.text = _getHealthText();

    final loseType = gameSpec.loseCondition.type.toLowerCase();

    if (loseType.contains('health') ||
        loseType.contains('life') ||
        loseType.contains('damage')) {
      if (health <= 0) {
        gameOver = true;

        print('GAME OVER - PLAYER LOST ALL HEALTH');
      }
    }
  }

  // =========================
  // OBJECTIVE CHECK
  // =========================

  bool objectiveRequiresCollecting() {
    final type = gameSpec.objective.type.toLowerCase();

    return type.contains('collect') ||
        type.contains('gather') ||
        type.contains('collectible');
  }

  bool objectiveRequiresGoal() {
    final type = gameSpec.objective.type.toLowerCase();

    return type.contains('goal') ||
        type.contains('reach') ||
        type.contains('destination') ||
        type.contains('portal');
  }

  // =========================
  // COLLECTIBLE CHECK
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
  // UPDATE
  // =========================

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver || gameWon) return;

    // =========================
    // TIMER
    // =========================

    if (gameSpec.rules.timeLimit != null && remainingTime > 0) {
      remainingTime -= dt;

      if (remainingTime <= 0) {
        remainingTime = 0;

        final winType = gameSpec.winCondition.type.toLowerCase();

        // -------------------------
        // SURVIVE WIN CONDITION
        // -------------------------

        if (winType.contains('survive')) {
          gameWon = true;

          print('GAME WON - SURVIVED TIME LIMIT');
        }
        // -------------------------
        // NORMAL TIME LOSE
        // -------------------------
        else {
          triggerLoseCondition('time');
        }
      }

      timerText.text = 'Time: ${remainingTime.ceil()}';
    }
  }

  // =========================
  // GAME LOAD
  // =========================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // =========================
    // TIMER INITIALIZATION
    // =========================

    if (gameSpec.rules.timeLimit != null) {
      remainingTime = gameSpec.rules.timeLimit!.toDouble();
    }

    // =========================
    // DEBUG INFORMATION
    // =========================

    print(
      'OBJECTIVE: '
      '${gameSpec.objective.type} | '
      '${gameSpec.objective.description}',
    );

    print(
      'WIN CONDITION: '
      '${gameSpec.winCondition.type}',
    );

    print(
      'LOSE CONDITION: '
      '${gameSpec.loseCondition.type}',
    );

    // =========================
    // BACKGROUND
    // =========================

    add(
      RectangleComponent(
        size: size,
        position: Vector2.zero(),
        paint: Paint()
          ..color = _getWorldColor(
            gameSpec.world.background,
            gameSpec.world.theme,
            gameSpec.world.lighting,
          ),
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
      text: 'Score: $score',
      position: Vector2(20, 75),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreText);
    healthText = TextComponent(
      text: _getHealthText(),
      position: Vector2(20, 145),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(healthText);
    objectiveText = TextComponent(
      text: _getObjectiveText(),
      position: Vector2(20, 180),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(objectiveText);

    // =========================
    // TIMER
    // =========================

    timerText = TextComponent(
      text: gameSpec.rules.timeLimit != null
          ? 'Time: ${remainingTime.ceil()}'
          : '',
      position: Vector2(20, 110),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(timerText);

    // =========================
    // TOTAL COLLECTIBLES
    // =========================

    totalCollectibles = gameSpec.objects
        .where((object) => _isCollectible(object.type))
        .fold(0, (total, object) => total + object.count);

    print(
      'TOTAL COLLECTIBLES: '
      '$totalCollectibles',
    );

    // =========================
    // PLAYER
    // =========================

    final player = Player(
      position: Vector2(size.x / 2, size.y - 120),
      gameSize: size,
      movementType: gameSpec.player.movement,
      playerType: gameSpec.player.type,
      // -------------------------
      // ENEMY HIT
      // -------------------------
      onHitEnemy: () {
        final loseType = gameSpec.loseCondition.type.toLowerCase();

        if (loseType.contains('health') ||
            loseType.contains('life') ||
            loseType.contains('damage')) {
          takeDamage(1);
        } else {
          triggerLoseCondition('enemy');
        }
      },

      // -------------------------
      // GOAL REACHED
      // -------------------------
      onReachedGoal: () {
        if (gameWon || gameOver) return;

        if (objectiveRequiresGoal()) {
          gameWon = true;

          print('GAME WON - GOAL REACHED');
        } else {
          print(
            'GOAL REACHED, '
            'BUT THIS IS NOT THE CURRENT OBJECTIVE',
          );
        }
      },
    );

    add(player);

    // GAME OBJECTS
    // =========================
    final List<Vector2> spawnedPositions = [];

    for (final objectSpec in gameSpec.objects) {
      print(
        'Generated Object: '
        '${objectSpec.name} | '
        'Type: ${objectSpec.type} | '
        'Count: ${objectSpec.count}',
      );

      for (int i = 0; i < objectSpec.count; i++) {
        // Generate a safe position BEFORE creating the object.
        final objectPosition = _getRandomPosition(spawnedPositions);

        // Remember this position so the next object
        // doesn't spawn too close to it.
        spawnedPositions.add(objectPosition);

        final gameObject = GameObject(
          objectName: objectSpec.name,
          objectType: objectSpec.type,
          position: objectPosition,
          gameSize: size,

          isEnemy: objectSpec.type.toLowerCase().contains('enemy'),

          targetPlayer: objectSpec.type.toLowerCase().contains('enemy')
              ? player
              : null,

          onCollected: () {
            if (gameWon || gameOver) {
              return;
            }

            collectedCount++;
            objectiveText.text = _getObjectiveText();

            addScore(gameSpec.rules.scorePerItem);

            print(
              'Collected: '
              '${objectSpec.name} '
              '+${gameSpec.rules.scorePerItem}',
            );

            print(
              'Progress: '
              '$collectedCount / '
              '$totalCollectibles',
            );

            if (objectiveRequiresCollecting()) {
              checkWinCondition();
            }
          },
        );

        add(gameObject);
      }
    }
  }

  // =========================
  // BACKGROUND COLOR
  // =========================

  Color _getWorldColor(String background, String theme, String lighting) {
    final value = '$background $theme $lighting'.toLowerCase();

    if (value.contains('forest') ||
        value.contains('jungle') ||
        value.contains('nature')) {
      if (value.contains('dark') ||
          value.contains('night') ||
          value.contains('dim')) {
        return Colors.green.shade900;
      }

      return Colors.green.shade900;
    }

    if (value.contains('space') ||
        value.contains('galaxy') ||
        value.contains('cosmic')) {
      return Colors.black;
    }

    if (value.contains('desert') || value.contains('sand')) {
      return Colors.orange.shade800;
    }

    if (value.contains('ocean') ||
        value.contains('underwater') ||
        value.contains('water')) {
      return Colors.blue.shade900;
    }

    if (value.contains('snow') ||
        value.contains('ice') ||
        value.contains('frozen')) {
      return Colors.blueGrey.shade200;
    }

    if (value.contains('city') ||
        value.contains('urban') ||
        value.contains('street')) {
      return Colors.grey.shade900;
    }

    if (value.contains('dark') ||
        value.contains('horror') ||
        value.contains('ominous')) {
      return Colors.grey.shade900;
    }

    if (value.contains('bright') ||
        value.contains('cheerful') ||
        value.contains('happy')) {
      return Colors.lightBlue.shade400;
    }

    return Colors.blueGrey.shade800;
  }

  //////////////////////////////////////////RANDOM
  Vector2 _getRandomPosition(List<Vector2> existingPositions) {
    final minX = 60.0;
    final maxX = size.x - 60.0;

    final minY = 180.0;
    final maxY = size.y - 80.0;

    for (int attempt = 0; attempt < 30; attempt++) {
      final position = Vector2(
        minX + _random.nextDouble() * (maxX - minX),
        minY + _random.nextDouble() * (maxY - minY),
      );

      // Keep objects away from the player's starting position.
      final playerStart = Vector2(size.x / 2, size.y - 120);

      if (position.distanceTo(playerStart) < 100) {
        continue;
      }

      // Keep objects away from each other.
      bool tooClose = false;

      for (final existing in existingPositions) {
        if (position.distanceTo(existing) < 70) {
          tooClose = true;
          break;
        }
      }

      if (!tooClose) {
        return position;
      }
    }

    // Fallback if a valid position wasn't found.
    return Vector2(size.x / 2, size.y / 2);
  }

  ///////////////////////////
  String _getHealthText() {
    return 'Health: ${'❤️ ' * health}';
  }

  /////////////////////////////////
  String _getObjectiveText() {
    final type = gameSpec.objective.type.toLowerCase();

    if (type.contains('collect') ||
        type.contains('gather') ||
        type.contains('collectible')) {
      return 'Collect: $collectedCount / $totalCollectibles';
    }

    if (type.contains('goal') ||
        type.contains('reach') ||
        type.contains('destination') ||
        type.contains('portal')) {
      return 'Reach the goal';
    }

    if (type.contains('survive')) {
      return 'Survive until the timer ends';
    }

    return gameSpec.objective.description;
  }
}
