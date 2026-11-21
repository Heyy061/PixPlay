import 'package:flutter/material.dart';

class EnemyRenderer {
  static void drawEnemy({
    required Canvas canvas,
    required Size size,
    required String visual,
    required String objectType,
  }) {
    final text = '$visual $objectType'.toLowerCase();

    final cx = size.width / 2;
    final cy = size.height / 2;

    Color bodyColor = const Color(0xFFE85D5D);
    Color darkColor = const Color(0xFF7D2525);
    Color eyeColor = Colors.white;

    // ================= TYPE =================

    if (text.contains('robot') ||
        text.contains('machine') ||
        text.contains('android')) {
      bodyColor = const Color(0xFF607D8B);
      darkColor = const Color(0xFF263238);
    } else if (text.contains('monster') ||
        text.contains('creature')) {
      bodyColor = const Color(0xFF7B4FA3);
      darkColor = const Color(0xFF3D2257);
    } else if (text.contains('ghost') ||
        text.contains('spirit')) {
      bodyColor = const Color(0xFFE8F4F8);
      darkColor = const Color(0xFF7D9BA8);
    } else if (text.contains('alien')) {
      bodyColor = const Color(0xFF55B879);
      darkColor = const Color(0xFF23633D);
    } else if (text.contains('fire') ||
        text.contains('flame')) {
      bodyColor = const Color(0xFFE85B32);
      darkColor = const Color(0xFF8D2515);
    } else if (text.contains('shadow') ||
        text.contains('dark')) {
      bodyColor = const Color(0xFF292832);
      darkColor = const Color(0xFF101014);
    }

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = bodyColor;

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = darkColor;

    // ================= BODY =================

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.12),
        width: size.width * 0.62,
        height: size.height * 0.55,
      ),
      Radius.circular(size.width * 0.20),
    );

    canvas.drawRRect(bodyRect, fill);
    canvas.drawRRect(bodyRect, outline);

    // ================= HEAD =================

    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.10),
      size.width * 0.34,
      fill,
    );

    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.10),
      size.width * 0.34,
      outline,
    );

    // ================= EYES =================

    final eyeY = cy - size.height * 0.13;
    final eyeOffset = size.width * 0.13;

    final eyePaint = Paint()..color = eyeColor;

    canvas.drawCircle(
      Offset(cx - eyeOffset, eyeY),
      size.width * 0.105,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(cx + eyeOffset, eyeY),
      size.width * 0.105,
      eyePaint,
    );

    final pupilPaint = Paint()..color = Colors.black;

    canvas.drawCircle(
      Offset(cx - eyeOffset, eyeY),
      size.width * 0.045,
      pupilPaint,
    );

    canvas.drawCircle(
      Offset(cx + eyeOffset, eyeY),
      size.width * 0.045,
      pupilPaint,
    );

    // Eye highlights
    final highlight = Paint()..color = Colors.white;

    canvas.drawCircle(
      Offset(
        cx - eyeOffset - size.width * 0.015,
        eyeY - size.width * 0.015,
      ),
      size.width * 0.018,
      highlight,
    );

    canvas.drawCircle(
      Offset(
        cx + eyeOffset - size.width * 0.015,
        eyeY - size.width * 0.015,
      ),
      size.width * 0.018,
      highlight,
    );

    // ================= MOUTH =================

    final mouthPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final mouth = Path();

    mouth.moveTo(
      cx - size.width * 0.13,
      cy + size.height * 0.03,
    );

    mouth.quadraticBezierTo(
      cx,
      cy + size.height * 0.14,
      cx + size.width * 0.13,
      cy + size.height * 0.03,
    );

    canvas.drawPath(mouth, mouthPaint);

    // ================= SPECIAL DETAILS =================

    if (text.contains('robot') ||
        text.contains('machine') ||
        text.contains('android')) {
      _drawRobot(canvas, cx, cy, size, darkColor);
    }

    if (text.contains('monster') ||
        text.contains('creature')) {
      _drawMonster(canvas, cx, cy, size, darkColor);
    }

    if (text.contains('ghost') ||
        text.contains('spirit')) {
      _drawGhost(canvas, cx, cy, size);
    }

    if (text.contains('fire') ||
        text.contains('flame')) {
      _drawFire(canvas, cx, cy, size);
    }
  }

  // ================= ROBOT =================

  static void _drawRobot(
    Canvas canvas,
    double cx,
    double cy,
    Size size,
    Color color,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.10),
      size.width * 0.035,
      paint,
    );

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(cx, cy - size.height * 0.42),
      Offset(cx, cy - size.height * 0.52),
      linePaint,
    );

    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.54),
      size.width * 0.035,
      paint,
    );
  }

  // ================= MONSTER =================

  static void _drawMonster(
    Canvas canvas,
    double cx,
    double cy,
    Size size,
    Color color,
  ) {
    final hornPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final leftHorn = Path();

    leftHorn.moveTo(
      cx - size.width * 0.25,
      cy - size.height * 0.35,
    );

    leftHorn.lineTo(
      cx - size.width * 0.42,
      cy - size.height * 0.58,
    );

    leftHorn.lineTo(
      cx - size.width * 0.10,
      cy - size.height * 0.42,
    );

    leftHorn.close();

    canvas.drawPath(leftHorn, hornPaint);

    final rightHorn = Path();

    rightHorn.moveTo(
      cx + size.width * 0.25,
      cy - size.height * 0.35,
    );

    rightHorn.lineTo(
      cx + size.width * 0.42,
      cy - size.height * 0.58,
    );

    rightHorn.lineTo(
      cx + size.width * 0.10,
      cy - size.height * 0.42,
    );

    rightHorn.close();

    canvas.drawPath(rightHorn, hornPaint);
  }

  // ================= GHOST =================

  static void _drawGhost(
    Canvas canvas,
    double cx,
    double cy,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFB9EAF4)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(
      cx - size.width * 0.25,
      cy + size.height * 0.22,
    );

    path.lineTo(
      cx - size.width * 0.25,
      cy + size.height * 0.43,
    );

    path.lineTo(
      cx - size.width * 0.10,
      cy + size.height * 0.32,
    );

    path.lineTo(
      cx,
      cy + size.height * 0.43,
    );

    path.lineTo(
      cx + size.width * 0.10,
      cy + size.height * 0.32,
    );

    path.lineTo(
      cx + size.width * 0.25,
      cy + size.height * 0.43,
    );

    path.lineTo(
      cx + size.width * 0.25,
      cy + size.height * 0.22,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  // ================= FIRE =================

  static void _drawFire(
    Canvas canvas,
    double cx,
    double cy,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFFFB52E)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(
      cx,
      cy - size.height * 0.52,
    );

    path.quadraticBezierTo(
      cx - size.width * 0.22,
      cy - size.height * 0.30,
      cx - size.width * 0.10,
      cy - size.height * 0.15,
    );

    path.quadraticBezierTo(
      cx,
      cy - size.height * 0.27,
      cx + size.width * 0.15,
      cy - size.height * 0.12,
    );

    path.quadraticBezierTo(
      cx + size.width * 0.24,
      cy - size.height * 0.32,
      cx,
      cy - size.height * 0.52,
    );

    path.close();

    canvas.drawPath(path, paint);
  }
}