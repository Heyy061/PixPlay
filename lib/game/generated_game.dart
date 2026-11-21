import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/game/visible_sence.dart';

import 'dart:math';

import 'game_obj.dart';
import 'player.dart';

import '../models/game_spec.dart';

class GeneratedGame extends FlameGame with HasCollisionDetection {
  final GameSpec gameSpec;
  final VoidCallback? onGameWon;
  final VoidCallback? onGameOver;

  late Player player;
  late TextComponent timerText;
  late TextComponent scoreText;
  late TextComponent healthText;
  late TextComponent objectiveText;

  final Random _random = Random();

  // ------------------------------------------------------------
  // WORLD / CAMERA
  // ------------------------------------------------------------

  late Vector2 worldSize;

  double cameraX = 0;
  double cameraY = 0;

  // The world is larger than the visible landscape screen.
  static const double worldWidthMultiplier = 3.0;
  static const double worldHeightMultiplier = 2.5;

  // Fixed logical resolution keeps the game from changing scale
  // unpredictably when the device rotates into landscape.
  static const double logicalWidth = 1280;
  static const double logicalHeight = 720;

  // ------------------------------------------------------------
  // GAME STATE
  // ------------------------------------------------------------

  int score = 0;
  int health = 3;
  int maxHealth = 3;

  bool gameWon = false;
  bool gameOver = false;

  double remainingTime = 0;

  int collectedCount = 0;
  int totalCollectibles = 0;

  GeneratedGame({
    required this.gameSpec,
    this.onGameWon,
    this.onGameOver,
  });

  // ============================================================
  // SCORE
  // ============================================================

  void addScore(int points) {
    if (gameWon || gameOver) return;

    score += points;
    scoreText.text = 'Score: $score';
  }

  // ============================================================
  // WIN CONDITION
  // ============================================================

  void checkWinCondition() {
    if (gameWon || gameOver) return;

    final type = gameSpec.winCondition.type.toLowerCase();

    if (type.contains('collect')) {
      if (totalCollectibles > 0 &&
          collectedCount >= totalCollectibles) {
        gameWon = true;
        onGameWon?.call();
      }
      return;
    }

    if (type.contains('goal') ||
        type.contains('reach') ||
        type.contains('destination') ||
        type.contains('portal')) {
      return;
    }

    if (type.contains('survive')) {
      if (gameSpec.rules.timeLimit != null &&
          remainingTime <= 0) {
        gameWon = true;
        onGameWon?.call();
      }
    }
  }

  // ============================================================
  // LOSE CONDITION
  // ============================================================

  void triggerLoseCondition(String reason) {
    if (gameWon || gameOver) return;

    final type = gameSpec.loseCondition.type.toLowerCase();

    if (reason == 'enemy') {
      if (type.contains('enemy') ||
          type.contains('hit') ||
          type.contains('collision') ||
          type.contains('death')) {
        gameOver = true;
        onGameOver?.call();
        return;
      }
    }

    if (reason == 'time') {
      if (type.contains('time') ||
          type.contains('timer') ||
          type.contains('timeout')) {
        gameOver = true;
        onGameOver?.call();
        return;
      }
    }
  }

  void takeDamage(int damage) {
    if (gameWon || gameOver) return;

    health -= damage;

    if (health < 0) {
      health = 0;
    }

    healthText.text = _getHealthText();

    final loseType = gameSpec.loseCondition.type.toLowerCase();

    if (loseType.contains('health') ||
        loseType.contains('life') ||
        loseType.contains('damage')) {
      if (health <= 0) {
        gameOver = true;
        onGameOver?.call();
      }
    }
  }

  // ============================================================
  // OBJECTIVE HELPERS
  // ============================================================

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

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver || gameWon) return;

    // -------------------------
    // TIMER
    // -------------------------

    if (gameSpec.rules.timeLimit != null &&
        remainingTime > 0) {
      remainingTime -= dt;

      if (remainingTime <= 0) {
        remainingTime = 0;

        final winType =
            gameSpec.winCondition.type.toLowerCase();

        if (winType.contains('survive')) {
          gameWon = true;
          onGameWon?.call();
        } else {
          triggerLoseCondition('time');
        }
      }

      timerText.text =
          'Time: ${remainingTime.ceil()}';
    }

    // -------------------------
    // CAMERA
    // -------------------------

    if (isLoaded) {
      _updateCamera(dt);
    }
  }

  // ============================================================
  // GAME LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ----------------------------------------------------------
    // IMPORTANT:
    // Use a fixed 16:9 logical landscape resolution.
    //
    // The physical phone/tablet screen can have a different
    // pixel size, but Flame will fit this logical game area into
    // the available landscape space instead of stretching the
    // world based on the first frame's size.
    // ----------------------------------------------------------

    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(
        logicalWidth,
        logicalHeight,
      ),
    );

    worldSize = Vector2(
      logicalWidth * worldWidthMultiplier,
      logicalHeight * worldHeightMultiplier,
    );

    camera.viewfinder.anchor = Anchor.center;

    // ----------------------------------------------------------
    // BACKGROUND / VISUAL SCENE
    // ----------------------------------------------------------

    add(
      VisualScene(
        worldSize: worldSize,
        environment:
            '${gameSpec.environmentStyle} '
            '${gameSpec.world.background} '
            '${gameSpec.world.theme}',
        mood: gameSpec.mood,
        palette: gameSpec.colorPalette,
        random: _random,
      ),
    );

    // ----------------------------------------------------------
    // HUD
    //
    // HUD is added to the viewport, NOT the world.
    // Therefore it stays fixed on the screen while the camera
    // moves through the larger game world.
    // ----------------------------------------------------------

    final titleText = TextComponent(
      text: gameSpec.title,
      position: Vector2(24, 22),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    camera.viewport.add(titleText);

    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(24, 65),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    camera.viewport.add(scoreText);

    healthText = TextComponent(
      text: _getHealthText(),
      position: Vector2(24, 105),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    camera.viewport.add(healthText);

    timerText = TextComponent(
      text: gameSpec.rules.timeLimit != null
          ? 'Time: ${remainingTime.ceil()}'
          : '',
      position: Vector2(24, 145),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    camera.viewport.add(timerText);

    objectiveText = TextComponent(
      text: _getObjectiveText(),
      position: Vector2(24, 185),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    camera.viewport.add(objectiveText);

    // ----------------------------------------------------------
    // PLAYER / OBJECTS
    // ----------------------------------------------------------

    maxHealth = _getMaxHealth();
    health = maxHealth;

    if (gameSpec.rules.timeLimit != null) {
      remainingTime = _getTimeLimit();
      timerText.text =
          'Time: ${remainingTime.ceil()}';
    }

    totalCollectibles = gameSpec.objects
        .where((object) => _isCollectible(object.type))
        .fold(
          0,
          (total, object) =>
              total + _getSpawnCount(object),
        );

    // Spawn player in the center of the world.
    player = Player(
      position: Vector2(
        worldSize.x / 2,
        worldSize.y / 2,
      ),
      gameSize: worldSize,
      movementType: gameSpec.player.movement,
      playerType: gameSpec.player.type,
      playerVisual: gameSpec.playerVisual,

      onHitEnemy: () {
        final loseType =
            gameSpec.loseCondition.type.toLowerCase();

        if (loseType.contains('health') ||
            loseType.contains('life') ||
            loseType.contains('damage')) {
          takeDamage(1);
        } else {
          triggerLoseCondition('enemy');
        }
      },

      onReachedGoal: () {
        if (gameWon || gameOver) return;

        if (objectiveRequiresGoal()) {
          gameWon = true;
          onGameWon?.call();
        }
      },
    );

    add(player);

    // ----------------------------------------------------------
    // OBJECT SPAWNING
    // ----------------------------------------------------------

    final List<Vector2> spawnedPositions = [];

    for (final objectSpec in gameSpec.objects) {
      final spawnCount =
          _getSpawnCount(objectSpec);

      for (int i = 0; i < spawnCount; i++) {
        final isEnemy = objectSpec.type
            .toLowerCase()
            .contains('enemy');

        final objectPosition = isEnemy
            ? _getEnemySpawnPosition(
                spawnedPositions,
              )
            : _getRandomPosition(
                spawnedPositions,
              );

        spawnedPositions.add(
          objectPosition,
        );

        final gameObject = GameObject(
          objectName: objectSpec.name,
          objectType: objectSpec.type,
          position: objectPosition,
          gameSize: worldSize,
          isEnemy: isEnemy,
          targetPlayer:
              isEnemy ? player : null,
          enemyVisual: gameSpec.enemyVisual,
          collectibleVisual: gameSpec.collectibleVisual,
          enemySpeed:
              _getEnemySpeed() *
                  _getEnemyChaseStrength(),
          onCollected: () {
            if (gameWon || gameOver) return;

            collectedCount++;

            objectiveText.text =
                _getObjectiveText();

            final scorePerItem =
                gameSpec.rules.scorePerItem
                    .clamp(1, 10000);

            addScore(scorePerItem);

            if (objectiveRequiresCollecting()) {
              checkWinCondition();
            }
          },
        );

        add(gameObject);
      }
    }

    // ----------------------------------------------------------
    // INITIAL CAMERA POSITION
    // ----------------------------------------------------------

    cameraX = player.position.x;
    cameraY = player.position.y;

    _clampCamera();

    camera.viewfinder.position = Vector2(
      cameraX,
      cameraY,
    );
  }

  // ============================================================
  // CAMERA
  // ============================================================

  void _updateCamera(double dt) {
    if (!isLoaded) return;

    final targetX = player.position.x;
    final targetY = player.position.y;

    const smooth = 7.0;

    cameraX +=
        (targetX - cameraX) *
        min(1.0, smooth * dt);

    cameraY +=
        (targetY - cameraY) *
        min(1.0, smooth * dt);

    _clampCamera();

    camera.viewfinder.position =
        Vector2(cameraX, cameraY);
  }

  void _clampCamera() {
    final viewportWidth =
        logicalWidth;

    final viewportHeight =
        logicalHeight;

    final halfW =
        viewportWidth / 2;

    final halfH =
        viewportHeight / 2;

    // Horizontal camera bounds.
    if (worldSize.x <= viewportWidth) {
      cameraX = worldSize.x / 2;
    } else {
      cameraX = cameraX.clamp(
        halfW,
        worldSize.x - halfW,
      );
    }

    // Vertical camera bounds.
    if (worldSize.y <= viewportHeight) {
      cameraY = worldSize.y / 2;
    } else {
      cameraY = cameraY.clamp(
        halfH,
        worldSize.y - halfH,
      );
    }
  }

  // ============================================================
  // RANDOM WORLD POSITION
  // ============================================================

  Vector2 _getRandomPosition(
    List<Vector2> existingPositions,
  ) {
    const marginX = 90.0;
    const topMargin = 220.0;
    const bottomMargin = 100.0;

    final playerStart = Vector2(
      worldSize.x / 2,
      worldSize.y / 2,
    );

    for (int attempt = 0;
        attempt < 50;
        attempt++) {
      final position = Vector2(
        marginX +
            _random.nextDouble() *
                (worldSize.x -
                    marginX * 2),
        topMargin +
            _random.nextDouble() *
                (worldSize.y -
                    topMargin -
                    bottomMargin),
      );

      if (position.distanceTo(playerStart) <
          140) {
        continue;
      }

      bool tooClose = false;

      for (final existing
          in existingPositions) {
        if (position.distanceTo(existing) <
            90) {
          tooClose = true;
          break;
        }
      }

      if (!tooClose) {
        return position;
      }
    }

    return Vector2(
      worldSize.x / 2 +
          180 +
          _random.nextDouble() *
              max(100, worldSize.x / 4),
      worldSize.y / 2,
    );
  }

  Vector2 _getEnemySpawnPosition(
    List<Vector2> existingPositions,
  ) {
    final playerStart = Vector2(
      worldSize.x / 2,
      worldSize.y / 2,
    );

    final difficulty =
        gameSpec.difficulty.toLowerCase();

    double minimumDistance = 420;

    if (difficulty.contains('easy')) {
      minimumDistance = 520;
    } else if (difficulty.contains('hard')) {
      minimumDistance = 300;
    } else if (difficulty.contains('extreme')) {
      minimumDistance = 220;
    }

    for (int attempt = 0;
        attempt < 80;
        attempt++) {
      final position = Vector2(
        100 +
            _random.nextDouble() *
                (worldSize.x - 200),
        230 +
            _random.nextDouble() *
                (worldSize.y - 330),
      );

      if (position.distanceTo(playerStart) <
          minimumDistance) {
        continue;
      }

      bool tooClose = false;

      for (final existing
          in existingPositions) {
        if (position.distanceTo(existing) <
            100) {
          tooClose = true;
          break;
        }
      }

      if (!tooClose) {
        return position;
      }
    }

    // Safe fallback.
    return Vector2(
      worldSize.x - 180,
      worldSize.y - 180,
    );
  }

  // ============================================================
  // TEXT
  // ============================================================

  String _getHealthText() {
    return 'Health: ${'❤️ ' * health}';
  }

  String _getObjectiveText() {
    final type =
        gameSpec.objective.type.toLowerCase();

    if (type.contains('collect') ||
        type.contains('gather') ||
        type.contains('collectible')) {
      return 'Collect: '
          '$collectedCount / '
          '$totalCollectibles';
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

  // ============================================================
  // GAME BALANCE
  // ============================================================

  double _getEnemySpeed() {
    final difficulty =
        gameSpec.difficulty.toLowerCase();

    double speed;

    if (difficulty.contains('easy')) {
      speed = 40;
    } else if (difficulty.contains('hard')) {
      speed = 100;
    } else if (difficulty.contains('extreme')) {
      speed = 140;
    } else {
      speed = 60;
    }

    return speed.clamp(20, 200);
  }

  int _getMaxHealth() {
    final difficulty =
        gameSpec.difficulty.toLowerCase();

    int health;

    if (difficulty.contains('easy')) {
      health = 5;
    } else if (difficulty.contains('hard')) {
      health = 2;
    } else if (difficulty.contains('extreme')) {
      health = 1;
    } else {
      health = 3;
    }

    return health.clamp(1, 10);
  }

  double _getTimeLimit() {
    final difficulty =
        gameSpec.difficulty.toLowerCase();

    final generatedLimit =
        gameSpec.rules.timeLimit;

    if (generatedLimit == null) {
      return 0;
    }

    final baseTime =
        generatedLimit.clamp(10, 600)
            .toDouble();

    if (difficulty.contains('easy')) {
      return baseTime * 1.25;
    }

    if (difficulty.contains('hard')) {
      return baseTime * 0.8;
    }

    if (difficulty.contains('extreme')) {
      return baseTime * 0.6;
    }

    return baseTime;
  }

  int _getSpawnCount(
    GameObjectSpec objectSpec,
  ) {
    final difficulty =
        gameSpec.difficulty.toLowerCase();

    final baseCount =
        objectSpec.count.clamp(1, 20);

    if (difficulty.contains('easy')) {
      return max(
        1,
        (baseCount * 0.7).round(),
      );
    }

    if (difficulty.contains('hard')) {
      return min(
        20,
        (baseCount * 1.3).ceil(),
      );
    }

    if (difficulty.contains('extreme')) {
      return min(
        20,
        (baseCount * 1.6).ceil(),
      );
    }

    return baseCount;
  }

  double _getEnemyChaseStrength() {
    final difficulty =
        gameSpec.difficulty.toLowerCase();

    double strength;

    if (difficulty.contains('easy')) {
      strength = 0.6;
    } else if (difficulty.contains('hard')) {
      strength = 1.2;
    } else if (difficulty.contains('extreme')) {
      strength = 1.5;
    } else {
      strength = 1.0;
    }

    return strength.clamp(0.5, 2.0);
  }

  // ============================================================
  // JOYSTICK
  // ============================================================

  void setJoystickDirection(
    Offset direction,
  ) {
    if (!isLoaded) return;

    player.setJoystickDirection(
      Vector2(
        direction.dx,
        direction.dy,
      ),
    );
  }
}
