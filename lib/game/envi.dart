import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LiveEnvironment extends Component {
  LiveEnvironment({
    required this.gameSize,
    required this.theme,
    required this.background,
    required this.mood,
    required this.style,
  });

  final Vector2 gameSize;

  final String theme;
  final String background;
  final String mood;
  final String style;

  final Random _random = Random();

  double _time = 0;

  final List<_AmbientParticle> _particles = [];

  String get _environment {
    return '$theme $background $style $mood'.toLowerCase();
  }

  bool get _isForest {
    return _environment.contains('forest') ||
        _environment.contains('jungle') ||
        _environment.contains('nature') ||
        _environment.contains('pine');
  }

  bool get _isCity {
    return _environment.contains('city') ||
        _environment.contains('urban') ||
        _environment.contains('street');
  }

  bool get _isDesert {
    return _environment.contains('desert') ||
        _environment.contains('sand');
  }

  bool get _isSnow {
    return _environment.contains('snow') ||
        _environment.contains('ice') ||
        _environment.contains('winter') ||
        _environment.contains('frozen');
  }

  bool get _isSpace {
    return _environment.contains('space') ||
        _environment.contains('galaxy') ||
        _environment.contains('cosmic');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _createParticles();
  }

  void _createParticles() {
    _particles.clear();

    final count = _isSpace
        ? 70
        : _isSnow
            ? 45
            : _isForest
                ? 25
                : 18;

    for (int i = 0; i < count; i++) {
      _particles.add(
        _AmbientParticle(
          position: Offset(
            _random.nextDouble() * gameSize.x,
            90 + _random.nextDouble() * gameSize.y,
          ),
          speed: 5 + _random.nextDouble() * 15,
          size: 1 + _random.nextDouble() * 3,
          phase: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _time += dt;

    for (final particle in _particles) {
      if (_isSnow) {
        particle.position = Offset(
          particle.position.dx +
              sin(_time + particle.phase) * dt * 12,
          particle.position.dy + particle.speed * dt,
        );

        if (particle.position.dy > gameSize.y) {
          particle.position = Offset(
            _random.nextDouble() * gameSize.x,
            70,
          );
        }
      } else if (_isForest) {
        particle.position = Offset(
          particle.position.dx -
              particle.speed * dt * 0.15,
          particle.position.dy +
              sin(_time + particle.phase) * dt * 2,
        );

        if (particle.position.dx < -10) {
          particle.position = Offset(
            gameSize.x + 10,
            particle.position.dy,
          );
        }
      } else if (_isSpace) {
        particle.position = Offset(
          particle.position.dx -
              particle.speed * dt * 0.1,
          particle.position.dy,
        );

        if (particle.position.dx < 0) {
          particle.position = Offset(
            gameSize.x,
            particle.position.dy,
          );
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_isSpace) {
      _renderSpace(canvas);
    } else if (_isCity) {
      _renderCity(canvas);
    } else if (_isDesert) {
      _renderDesert(canvas);
    } else if (_isSnow) {
      _renderSnow(canvas);
    } else if (_isForest) {
      _renderForest(canvas);
    } else {
      _renderDefault(canvas);
    }

    _renderParticles(canvas);
  }

  // ============================================================
  // FOREST
  // ============================================================

  void _renderForest(Canvas canvas) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF78C8E8),
          Color(0xFFB7E3D0),
          Color(0xFF5C9A62),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      sky,
    );

    _drawClouds(canvas);

    // Distant mountains
    final mountainPaint = Paint()
      ..color = const Color(0xFF668C78);

    final mountains = Path();

    mountains.moveTo(0, gameSize.y * 0.35);

    for (double x = 0; x <= gameSize.x; x += 100) {
      final height =
          40 + sin(x * 0.018) * 30;

      mountains.lineTo(
        x,
        gameSize.y * 0.35 - height,
      );
    }

    mountains.lineTo(
      gameSize.x,
      gameSize.y * 0.55,
    );

    mountains.lineTo(
      0,
      gameSize.y * 0.55,
    );

    mountains.close();

    canvas.drawPath(
      mountains,
      mountainPaint,
    );

    // Distant trees
    for (int i = 0; i < 11; i++) {
      final x =
          (i * 83.0 + 30) % gameSize.x;

      final y =
          gameSize.y * 0.48 +
          sin(_time * 0.15 + i) * 2;

      _drawTree(
        canvas,
        Offset(x, y),
        0.65,
        const Color(0xFF376F46),
        const Color(0xFF5B4632),
      );
    }

    // Ground
    final groundPaint = Paint()
      ..color = const Color(0xFF315D38);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        gameSize.y * 0.65,
        gameSize.x,
        gameSize.y * 0.35,
      ),
      groundPaint,
    );

    // Foreground trees
    for (int i = 0; i < 7; i++) {
      final x =
          (i * 145.0 - 30) % gameSize.x;

      final y =
          gameSize.y * 0.68;

      _drawTree(
        canvas,
        Offset(x, y),
        1.0,
        const Color(0xFF24552F),
        const Color(0xFF4A3525),
      );
    }

    _drawGrass(canvas);
  }

  // ============================================================
  // CITY
  // ============================================================

  void _renderCity(Canvas canvas) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF72B6D8),
          Color(0xFFE3A879),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      sky,
    );

    // Distant skyline
    for (int i = 0; i < 9; i++) {
      final width = 55.0 + (i % 3) * 20;
      final height = 100.0 + (i % 4) * 35;

      final x =
          (i * 85.0) % gameSize.x;

      final paint = Paint()
        ..color = const Color(0xFF526070);

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          gameSize.y * 0.58 - height,
          width,
          height,
        ),
        paint,
      );

      _drawWindows(
        canvas,
        x,
        gameSize.y * 0.58 - height,
        width,
        height,
      );
    }

    // Ground
    final roadPaint = Paint()
      ..color = const Color(0xFF343940);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        gameSize.y * 0.58,
        gameSize.x,
        gameSize.y * 0.42,
      ),
      roadPaint,
    );

    // Road markings
    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3;

    final offset =
        (_time * 35) % 70;

    for (
      double x = -70 + offset;
      x < gameSize.x;
      x += 70
    ) {
      canvas.drawLine(
        Offset(x, gameSize.y * 0.72),
        Offset(
          x + 35,
          gameSize.y * 0.72,
        ),
        linePaint,
      );
    }

    // Street lights
    for (int i = 0; i < 5; i++) {
      final x =
          (i * 150.0 + 50) % gameSize.x;

      _drawStreetLight(
        canvas,
        Offset(x, gameSize.y * 0.58),
      );
    }
  }

  // ============================================================
  // DESERT
  // ============================================================

  void _renderDesert(Canvas canvas) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF69BFE8),
          Color(0xFFFFD18A),
          Color(0xFFE8A04B),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      sky,
    );

    _drawClouds(canvas);

    // Dunes
    final dunePaint = Paint()
      ..color = const Color(0xFFD9953D);

    final dunes = Path();

    dunes.moveTo(
      0,
      gameSize.y * 0.60,
    );

    for (
      double x = 0;
      x <= gameSize.x;
      x += 80
    ) {
      dunes.quadraticBezierTo(
        x + 40,
        gameSize.y * 0.52 +
            sin(x * 0.02) * 20,
        x + 80,
        gameSize.y * 0.60,
      );
    }

    dunes.lineTo(
      gameSize.x,
      gameSize.y,
    );

    dunes.lineTo(
      0,
      gameSize.y,
    );

    dunes.close();

    canvas.drawPath(
      dunes,
      dunePaint,
    );

    // Cactus
    for (int i = 0; i < 5; i++) {
      final x =
          (i * 150.0 + 50) % gameSize.x;

      _drawCactus(
        canvas,
        Offset(
          x,
          gameSize.y * 0.67,
        ),
      );
    }
  }

  // ============================================================
  // SNOW
  // ============================================================

  void _renderSnow(Canvas canvas) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6F9FC1),
          Color(0xFFDCECF3),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      sky,
    );

    // Mountains
    final mountainPaint = Paint()
      ..color = const Color(0xFF7898AC);

    final mountain = Path();

    mountain.moveTo(0, gameSize.y * 0.60);

    for (
      double x = 0;
      x <= gameSize.x;
      x += 100
    ) {
      mountain.lineTo(
        x,
        gameSize.y * 0.35 -
            sin(x * 0.025) * 50,
      );
    }

    mountain.lineTo(
      gameSize.x,
      gameSize.y,
    );

    mountain.lineTo(
      0,
      gameSize.y,
    );

    mountain.close();

    canvas.drawPath(
      mountain,
      mountainPaint,
    );

    // Snow ground
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        gameSize.y * 0.62,
        gameSize.x,
        gameSize.y,
      ),
      Paint()..color = const Color(0xFFE8F4F7),
    );

    // Pine trees
    for (int i = 0; i < 8; i++) {
      final x =
          (i * 100.0 + 20) % gameSize.x;

      _drawPineTree(
        canvas,
        Offset(
          x,
          gameSize.y * 0.64,
        ),
      );
    }
  }

  // ============================================================
  // SPACE
  // ============================================================

  void _renderSpace(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      Paint()..color = const Color(0xFF07111F),
    );

    // Large distant planets
    canvas.drawCircle(
      Offset(
        gameSize.x * 0.82,
        gameSize.y * 0.25,
      ),
      65,
      Paint()..color = const Color(0xFF253E68),
    );

    canvas.drawCircle(
      Offset(
        gameSize.x * 0.15,
        gameSize.y * 0.58,
      ),
      35,
      Paint()..color = const Color(0xFF5B385F),
    );
  }

  // ============================================================
  // DEFAULT
  // ============================================================

  void _renderDefault(Canvas canvas) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3C6680),
          Color(0xFF1D3340),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      paint,
    );

    _drawClouds(canvas);
  }

  // ============================================================
  // CLOUDS
  // ============================================================

  void _drawClouds(Canvas canvas) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72);

    for (int i = 0; i < 4; i++) {
      final x =
          ((i * 180.0 + _time * 8) %
                  (gameSize.x + 180)) -
              90;

      final y =
          100.0 + i * 55;

      canvas.drawCircle(
        Offset(x, y),
        22,
        cloudPaint,
      );

      canvas.drawCircle(
        Offset(x + 25, y - 8),
        30,
        cloudPaint,
      );

      canvas.drawCircle(
        Offset(x + 55, y),
        22,
        cloudPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x - 5,
          y,
          65,
          20,
        ),
        cloudPaint,
      );
    }
  }

  // ============================================================
  // TREE
  // ============================================================

  void _drawTree(
    Canvas canvas,
    Offset position,
    double scale,
    Color leaves,
    Color trunk,
  ) {
    final sway =
        sin(_time * 1.2 + position.dx * 0.01) *
            3 *
            scale;

    final trunkPaint = Paint()
      ..color = trunk;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy + 30 * scale,
        ),
        width: 15 * scale,
        height: 70 * scale,
      ),
      trunkPaint,
    );

    final leafPaint = Paint()
      ..color = leaves;

    canvas.drawCircle(
      Offset(
        position.dx + sway,
        position.dy,
      ),
      38 * scale,
      leafPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx - 25 * scale + sway,
        position.dy + 15 * scale,
      ),
      27 * scale,
      leafPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx + 25 * scale + sway,
        position.dy + 15 * scale,
      ),
      27 * scale,
      leafPaint,
    );

    // Highlight
    canvas.drawCircle(
      Offset(
        position.dx - 10 * scale + sway,
        position.dy - 10 * scale,
      ),
      9 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
  }

  // ============================================================
  // GRASS
  // ============================================================

  void _drawGrass(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF74B84C)
      ..strokeWidth = 2;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0) % gameSize.x;
      final y =
          gameSize.y * 0.65 +
              (i % 5) * 7;

      final sway =
          sin(_time * 2 + i) * 4;

      canvas.drawLine(
        Offset(x, y),
        Offset(
          x + sway,
          y - 10,
        ),
        paint,
      );
    }
  }

  // ============================================================
  // CITY WINDOWS
  // ============================================================

  void _drawWindows(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
  ) {
    final windowPaint = Paint()
      ..color = const Color(0xFFFFD76A);

    for (
      double wy = y + 15;
      wy < y + height - 10;
      wy += 25
    ) {
      for (
        double wx = x + 10;
        wx < x + width - 10;
        wx += 20
      ) {
        canvas.drawRect(
          Rect.fromLTWH(
            wx,
            wy,
            7,
            10,
          ),
          windowPaint,
        );
      }
    }
  }

  // ============================================================
  // STREET LIGHT
  // ============================================================

  void _drawStreetLight(
    Canvas canvas,
    Offset position,
  ) {
    final pole = Paint()
      ..color = const Color(0xFF22252A)
      ..strokeWidth = 4;

    canvas.drawLine(
      position,
      Offset(
        position.dx,
        position.dy - 75,
      ),
      pole,
    );

    canvas.drawCircle(
      Offset(
        position.dx,
        position.dy - 78,
      ),
      8,
      Paint()..color = const Color(0xFFFFD76A),
    );
  }

  // ============================================================
  // CACTUS
  // ============================================================

  void _drawCactus(
    Canvas canvas,
    Offset position,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF4C8A48);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: 18,
          height: 65,
        ),
        const Radius.circular(9),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx - 25,
          position.dy - 15,
          15,
          35,
        ),
        const Radius.circular(7),
      ),
      paint,
    );
  }

  // ============================================================
  // PINE TREE
  // ============================================================

  void _drawPineTree(
    Canvas canvas,
    Offset position,
  ) {
    final trunk = Paint()
      ..color = const Color(0xFF654832);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy + 20,
        ),
        width: 12,
        height: 50,
      ),
      trunk,
    );

    final leaves = Paint()
      ..color = const Color(0xFF326B55);

    for (int i = 0; i < 3; i++) {
      final path = Path();

      final top =
          position.dy - 60 + i * 25;

      path.moveTo(
        position.dx,
        top,
      );

      path.lineTo(
        position.dx - 35 - i * 5,
        top + 55,
      );

      path.lineTo(
        position.dx + 35 + i * 5,
        top + 55,
      );

      path.close();

      canvas.drawPath(
        path,
        leaves,
      );
    }
  }

  // ============================================================
  // PARTICLES
  // ============================================================

  void _renderParticles(Canvas canvas) {
    for (final particle in _particles) {
      Color color;

      if (_isSnow) {
        color = Colors.white.withValues(alpha: 0.75);
      } else if (_isForest) {
        color = const Color(0xFFB7E58B)
            .withValues(alpha: 0.55);
      } else if (_isSpace) {
        color = Colors.white.withValues(
          alpha: 0.45 + sin(_time * 2 + particle.phase) * 0.25,
        );
      } else {
        color = Colors.white.withValues(alpha: 0.25);
      }

      canvas.drawCircle(
        particle.position,
        particle.size,
        Paint()..color = color,
      );
    }
  }
}

class _AmbientParticle {
  _AmbientParticle({
    required this.position,
    required this.speed,
    required this.size,
    required this.phase,
  });

  Offset position;
  final double speed;
  final double size;
  final double phase;
}