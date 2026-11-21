import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

/// Generic procedural scene renderer.
/// It converts the environment information produced by the AI into
/// a layered 2D game world without requiring a separate game class per genre.
class VisualScene extends PositionComponent {
  VisualScene({
    required this.worldSize,
    required this.environment,
    required this.mood,
    required this.palette,
    required this.random,
  }) : super(position: Vector2.zero(), size: worldSize, priority: -100);

  final Vector2 worldSize;
  final String environment;
  final String mood;
  final String palette;
  final Random random;

  double _time = 0;
  late Random _renderRandom;
  late final List<_Particle> _particles = List.generate(
    70,
    (_) => _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      speed: 8 + random.nextDouble() * 22,
      size: 1 + random.nextDouble() * 3,
      phase: random.nextDouble() * pi * 2,
      drift: -0.5 + random.nextDouble(),
    ),
  );

  String get _kind {
    final value = '${environment.toLowerCase()} ${mood.toLowerCase()}';
    if (_has(value, [
      'city',
      'urban',
      'street',
      'town',
      'cobble',
      'cobblestone',
      'building',
      'road',
      'avenue',
      'downtown',
    ])) {
      return 'city';
    }
    if (_has(value, [
      'mountain',
      'forest',
      'jungle',
      'nature',
      'trail',
      'hill',
      'pine',
      'valley',
      'trek',
      'hiking',
      'misty',
      'meadow',
      'camp',
      'rocky',
    ])) {
      return 'mountain';
    }
    if (_has(value, ['desert', 'sand', 'dune'])) return 'desert';
    if (_has(value, ['snow', 'ice', 'winter', 'arctic', 'frozen']))
      return 'snow';
    if (_has(value, ['ocean', 'sea', 'underwater', 'water'])) return 'ocean';
    if (_has(value, ['space', 'galaxy', 'cosmic', 'star'])) return 'space';
    if (_has(value, ['dungeon', 'cave', 'castle', 'ruins'])) return 'dungeon';
    if (_has(value, ['volcano', 'lava', 'fire'])) return 'volcano';
    return 'nature';
  }

  bool _has(String value, List<String> words) => words.any(value.contains);

  @override
  void update(double dt) {
    _time += dt;

    for (final p in _particles) {
      p.y += p.speed * dt / worldSize.y;
      p.x += sin(_time * 0.35 + p.phase) * p.drift * dt / worldSize.x;
      if (p.y > 1.05) {
        p.y = -0.05;
        p.x = random.nextDouble();
      }
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderRandom = Random(1337);
    final w = worldSize.x;
    final h = worldSize.y;

    switch (_kind) {
      case 'city':
        _drawCity(canvas, w, h);
        break;
      case 'mountain':
        _drawMountain(canvas, w, h);
        break;
      case 'desert':
        _drawDesert(canvas, w, h);
        break;
      case 'snow':
        _drawSnow(canvas, w, h);
        break;
      case 'ocean':
        _drawOcean(canvas, w, h);
        break;
      case 'space':
        _drawSpace(canvas, w, h);
        break;
      case 'dungeon':
        _drawDungeon(canvas, w, h);
        break;
      case 'volcano':
        _drawVolcano(canvas, w, h);
        break;
      default:
        _drawNature(canvas, w, h);
    }

    _drawParticles(canvas, w, h);
    _drawAtmosphere(canvas, w, h);
  }

  void _fill(Canvas canvas, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, worldSize.x, worldSize.y),
      Paint()..color = color,
    );
  }

  void _drawCity(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFFBFD4E5));

    // Distant skyline.
    for (int i = 0; i < 18; i++) {
      final bw = 70.0 + _renderRandom.nextDouble() * 90;
      final bh = 180.0 + _renderRandom.nextDouble() * 330;
      final x = i * (w / 16) - 30;
      final y = h * 0.35 - bh;
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF6D7884),
          const Color(0xFF39434D),
          i % 3 / 3,
        )!;
      canvas.drawRect(Rect.fromLTWH(x, y, bw, bh), paint);
      _drawWindows(canvas, x, y, bw, bh, 0.18);
    }

    // Side buildings create the street canyon from the reference image.
    final streetTop = h * 0.25;
    final road = Path()
      ..moveTo(w * 0.39, streetTop)
      ..lineTo(w * 0.61, streetTop)
      ..lineTo(w * 0.86, h)
      ..lineTo(w * 0.14, h)
      ..close();

    canvas.drawPath(road, Paint()..color = const Color(0xFF4B4F52));

    final sidewalk = Paint()..color = const Color(0xFF85898B);
    canvas.drawRect(
      Rect.fromLTWH(0, streetTop, w * 0.14, h - streetTop),
      sidewalk,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.86, streetTop, w * 0.14, h - streetTop),
      sidewalk,
    );

    // Perspective cobblestone strips.
    final stone = Paint()
      ..color = const Color(0xFF777A7C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double y = streetTop + 25; y < h; y += 38) {
      final t = (y - streetTop) / (h - streetTop);
      final left = w * (0.39 - 0.25 * t);
      final right = w * (0.61 + 0.25 * t);
      canvas.drawLine(Offset(left, y), Offset(right, y), stone);
    }

    _drawBuildingRows(canvas, w, h, true);
    _drawStreetLights(canvas, w, h);
  }

  void _drawBuildingRows(Canvas canvas, double w, double h, bool urban) {
    final leftPaint = Paint()..color = const Color(0xFF786E68);
    final rightPaint = Paint()..color = const Color(0xFF916D5A);

    for (int i = 0; i < 8; i++) {
      final y = h * 0.20 + i * 105.0;
      final bh = 150.0 + (i % 3) * 35;
      canvas.drawRect(Rect.fromLTWH(0, y, w * 0.20, bh), leftPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.80, y, w * 0.20, bh), rightPaint);
      _drawWindows(canvas, 10, y + 18, w * 0.17, bh - 20, 0.55);
      _drawWindows(canvas, w * 0.82, y + 18, w * 0.16, bh - 20, 0.60);
    }
  }

  void _drawWindows(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double alpha,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFD9E9EA).withValues(alpha: alpha);
    for (double yy = y + 15; yy < y + h - 10; yy += 42) {
      for (double xx = x + 10; xx < x + w - 8; xx += 30) {
        canvas.drawRect(Rect.fromLTWH(xx, yy, 13, 20), paint);
      }
    }
  }

  void _drawStreetLights(Canvas canvas, double w, double h) {
    final pole = Paint()
      ..color = const Color(0xFF27292B)
      ..strokeWidth = 5;
    final lamp = Paint()..color = const Color(0xFFFFE6A3);
    for (int i = 0; i < 8; i++) {
      final y = h * 0.34 + i * 130;
      final xLeft = w * (0.27 - i * 0.012);
      final xRight = w * (0.73 + i * 0.012);
      canvas.drawLine(Offset(xLeft, y), Offset(xLeft, y + 75), pole);
      canvas.drawCircle(Offset(xLeft, y), 8, lamp);
      canvas.drawLine(Offset(xRight, y), Offset(xRight, y + 75), pole);
      canvas.drawCircle(Offset(xRight, y), 8, lamp);
    }
  }

  void _drawMountain(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF9CBBC8));

    _mountainLayer(canvas, w, h, h * 0.28, const Color(0xFF627D83), 0.0);
    _mountainLayer(canvas, w, h, h * 0.36, const Color(0xFF4E6864), 1.2);

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.42, w, h * 0.58),
      Paint()..color = const Color(0xFF4B7749),
    );

    // Large grassy valley floor.
    final grass = Paint()..color = const Color(0xFF527F4C);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.43, w, h * 0.57), grass);

    // Winding hiking trail with a darker edge for depth.
    final trail = Path()
      ..moveTo(w * 0.53, h)
      ..cubicTo(w * 0.62, h * 0.88, w * 0.37, h * 0.77, w * 0.49, h * 0.64)
      ..cubicTo(w * 0.62, h * 0.52, w * 0.45, h * 0.45, w * 0.52, h * 0.39);
    canvas.drawPath(
      trail,
      Paint()
        ..color = const Color(0xFF806C4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 58,
    );
    canvas.drawPath(
      trail,
      Paint()
        ..color = const Color(0xFFC4A879)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 44,
    );

    // Pine forest frames the playable valley instead of filling the whole scene.
    for (int i = 0; i < 42; i++) {
      final side = i.isEven ? -1.0 : 1.0;
      final depth = _renderRandom.nextDouble();
      final x = side < 0
          ? w * (0.03 + depth * 0.30)
          : w * (0.70 + depth * 0.27);
      final y = h * (0.48 + depth * 0.42);
      _drawPine(canvas, x, y, 0.55 + depth * 0.75);
    }

    // A few mid-valley trees add depth without hiding the trail.
    for (int i = 0; i < 12; i++) {
      final x = w * (0.18 + _renderRandom.nextDouble() * 0.64);
      final y = h * (0.48 + _renderRandom.nextDouble() * 0.35);
      if ((x / w - 0.5).abs() > 0.13) {
        _drawPine(canvas, x, y, 0.45 + _renderRandom.nextDouble() * 0.45);
      }
    }

    // Foreground rocks.
    for (int i = 0; i < 16; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = h * 0.72 + _renderRandom.nextDouble() * h * 0.28;
      final r = 12 + _renderRandom.nextDouble() * 28;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: r * 1.8, height: r),
        Paint()..color = const Color(0xFF6F6D61),
      );
    }
  }

  void _mountainLayer(
    Canvas canvas,
    double w,
    double h,
    double base,
    Color color,
    double phase,
  ) {
    final path = Path()..moveTo(0, base);
    for (int i = 0; i <= 10; i++) {
      final x = w * i / 10;
      final peak = base - (70 + 100 * (0.5 + 0.5 * sin(i * 1.8 + phase)));
      path.lineTo(x, peak);
    }
    path.lineTo(w, h * 0.55);
    path.lineTo(0, h * 0.55);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawTree(Canvas canvas, double x, double y, double scale) {
    final trunk = Paint()..color = const Color(0xFF5A3E2C);
    final leaf = Paint()..color = const Color(0xFF245A35);
    canvas.drawRect(
      Rect.fromLTWH(x - 5 * scale, y - 65 * scale, 10 * scale, 65 * scale),
      trunk,
    );
    canvas.drawCircle(Offset(x, y - 72 * scale), 32 * scale, leaf);
    canvas.drawCircle(Offset(x - 20 * scale, y - 55 * scale), 24 * scale, leaf);
    canvas.drawCircle(Offset(x + 20 * scale, y - 55 * scale), 24 * scale, leaf);
  }

  void _drawDesert(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFFE4B86B));
    _dune(canvas, w, h * 0.44, const Color(0xFFD39A4E), 0.0);
    _dune(canvas, w, h * 0.57, const Color(0xFFC58943), 1.7);
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.56, w, h * 0.44),
      Paint()..color = const Color(0xFFD49A4C),
    );

    for (int i = 0; i < 15; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = h * 0.62 + _renderRandom.nextDouble() * h * 0.35;
      _drawCactus(canvas, x, y, 0.7 + _renderRandom.nextDouble() * 0.7);
    }
  }

  void _dune(Canvas canvas, double w, double y, Color color, double phase) {
    final path = Path()..moveTo(0, y);
    for (int i = 0; i <= 12; i++) {
      final x = w * i / 12;
      path.lineTo(x, y + sin(i * 0.8 + phase) * 45);
    }
    path.lineTo(w, worldSize.y);
    path.lineTo(0, worldSize.y);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawPine(Canvas canvas, double x, double y, double s) {
    final trunk = Paint()..color = const Color(0xFF5A3E2C);
    final green = Paint()..color = const Color(0xFF315A44);

    canvas.drawRect(Rect.fromLTWH(x - 4 * s, y - 58 * s, 8 * s, 58 * s), trunk);

    for (int i = 0; i < 3; i++) {
      final yy = y - (18 + i * 20) * s;
      final width = (20 + i * 9) * s;
      final path = Path()
        ..moveTo(x, yy - 35 * s)
        ..lineTo(x - width, yy + 18 * s)
        ..lineTo(x + width, yy + 18 * s)
        ..close();
      canvas.drawPath(path, green);
    }
  }

  void _drawCactus(Canvas canvas, double x, double y, double s) {
    final p = Paint()..color = const Color(0xFF47733E);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 7 * s, y - 70 * s, 14 * s, 70 * s),
        Radius.circular(7 * s),
      ),
      p,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 28 * s, y - 52 * s, 21 * s, 10 * s),
        Radius.circular(5 * s),
      ),
      p,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 7 * s, y - 40 * s, 21 * s, 10 * s),
        Radius.circular(5 * s),
      ),
      p,
    );
  }

  void _drawSnow(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFFB9D6E5));
    _mountainLayer(canvas, w, h, h * 0.35, const Color(0xFF7794A3), 0.6);
    _mountainLayer(canvas, w, h, h * 0.44, const Color(0xFF93AEB9), 2.2);
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.42, w, h * 0.58),
      Paint()..color = const Color(0xFFE8F3F5),
    );
    for (int i = 0; i < 25; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = h * 0.55 + _renderRandom.nextDouble() * h * 0.4;
      _drawPine(canvas, x, y, 0.6 + _renderRandom.nextDouble() * 0.8);
    }
  }

  void _drawOcean(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF155B78));
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.48, w, h * 0.52),
      Paint()..color = const Color(0xFF0D435A),
    );
    for (int i = 0; i < 30; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = h * 0.15 + _renderRandom.nextDouble() * h * 0.75;
      final r = 12 + _renderRandom.nextDouble() * 24;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x, y), radius: r),
        0,
        pi,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawSpace(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF070A1D));
    final nebula = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF5B3BA5).withValues(alpha: 0.32),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.55, h * 0.35),
              radius: w * 0.65,
            ),
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), nebula);
    for (int i = 0; i < 100; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = _renderRandom.nextDouble() * h;
      final r = 0.8 + _renderRandom.nextDouble() * 2;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.45 + _renderRandom.nextDouble() * 0.5,
          ),
      );
    }
  }

  void _drawDungeon(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF24262D));
    final tile = Paint()..color = const Color(0xFF343841);
    final grout = Paint()
      ..color = const Color(0xFF181A1F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double y = 0; y < h; y += 70) {
      for (double x = 0; x < w; x += 70) {
        canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 66, 66), tile);
        canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 66, 66), grout);
      }
    }
  }

  void _drawVolcano(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF351E1C));
    _mountainLayer(canvas, w, h, h * 0.5, const Color(0xFF211C20), 0.0);
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.58, w, h * 0.42),
      Paint()..color = const Color(0xFF241C1A),
    );
    for (int i = 0; i < 18; i++) {
      final x = _renderRandom.nextDouble() * w;
      final y = h * 0.55 + _renderRandom.nextDouble() * h * 0.4;
      canvas.drawCircle(
        Offset(x, y),
        3 + _renderRandom.nextDouble() * 5,
        Paint()..color = const Color(0xFFFF6A24),
      );
    }
  }

  void _drawNature(Canvas canvas, double w, double h) {
    _fill(canvas, const Color(0xFF91B8C1));
    _mountainLayer(canvas, w, h, h * 0.36, const Color(0xFF55706B), 0.0);
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.43, w, h * 0.57),
      Paint()..color = const Color(0xFF3E7547),
    );
    for (int i = 0; i < 25; i++) {
      _drawTree(
        canvas,
        _renderRandom.nextDouble() * w,
        h * 0.55 + _renderRandom.nextDouble() * h * 0.4,
        0.6 + _renderRandom.nextDouble() * 0.8,
      );
    }
  }

  void _drawParticles(Canvas canvas, double w, double h) {
    for (final p in _particles) {
      final pulse = 0.55 + 0.45 * sin(_time * 2 + p.phase);
      Color color;
      switch (_kind) {
        case 'snow':
          color = Colors.white.withValues(alpha: 0.7 * pulse);
          break;
        case 'city':
          color = const Color(0xFFE9D89A).withValues(alpha: 0.15 * pulse);
          break;
        case 'mountain':
          color = const Color(0xFFE6F0B2).withValues(alpha: 0.24 * pulse);
          break;
        case 'volcano':
          color = const Color(0xFFFF9C35).withValues(alpha: 0.65 * pulse);
          break;
        default:
          color = Colors.white.withValues(alpha: 0.12 * pulse);
      }
      canvas.drawCircle(
        Offset(p.x * w, p.y * h),
        p.size,
        Paint()..color = color,
      );
    }
  }

  void _drawAtmosphere(Canvas canvas, double w, double h) {
    final m = mood.toLowerCase();
    if (_has(m, ['fog', 'mist', 'mysterious', 'dreamy'])) {
      final fog = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.15, w, h * 0.7));
      canvas.drawRect(Rect.fromLTWH(0, h * 0.15, w, h * 0.7), fog);
    }
    if (_has(m, ['night', 'dark', 'horror'])) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );
    }
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
    required this.drift,
  });
  double x;
  double y;
  final double speed;
  final double size;
  final double phase;
  final double drift;
}
