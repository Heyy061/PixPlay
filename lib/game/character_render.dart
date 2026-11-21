import 'package:flutter/material.dart';

class CharacterRenderer {
  static void drawPlayer({
    required Canvas canvas,
    required Size size,
    required String visual,
    required String playerType,
  }) {
    final text = '$visual $playerType'.toLowerCase();

    final cx = size.width / 2;
    final headRadius = size.width * 0.31;
    final headCenterY = size.height * 0.30;

    Color skin = const Color(0xFFF2B58F);
    Color hair = const Color(0xFF3A2418);
    Color shirt = const Color(0xFF4E8B55);
    Color pants = const Color(0xFF27364A);
    Color shoes = const Color(0xFF33251E);

    // ---- Character type / AI visual interpretation ----

    if (text.contains('wizard') ||
        text.contains('mage') ||
        text.contains('magic')) {
      hair = const Color(0xFF21152F);
      shirt = const Color(0xFF6845A5);
      pants = const Color(0xFF30204D);
      shoes = const Color(0xFF19131F);
    } else if (text.contains('knight') ||
        text.contains('warrior') ||
        text.contains('armor')) {
      skin = const Color(0xFFE7AA82);
      hair = const Color(0xFF2A2522);
      shirt = const Color(0xFF66727C);
      pants = const Color(0xFF30343A);
      shoes = const Color(0xFF17191B);
    } else if (text.contains('robot') ||
        text.contains('machine') ||
        text.contains('android')) {
      skin = const Color(0xFFB8C3C8);
      hair = const Color(0xFF65737A);
      shirt = const Color(0xFF3C6675);
      pants = const Color(0xFF27363B);
      shoes = const Color(0xFF151B1E);
    } else if (text.contains('ninja')) {
      skin = const Color(0xFFE2A47C);
      hair = Colors.black;
      shirt = const Color(0xFF18191D);
      pants = const Color(0xFF111216);
      shoes = Colors.black;
    } else if (text.contains('alien')) {
      skin = const Color(0xFF75D69A);
      hair = const Color(0xFF163B2A);
      shirt = const Color(0xFF315E9A);
      pants = const Color(0xFF243149);
      shoes = const Color(0xFF18202A);
    } else if (text.contains('fire') ||
        text.contains('flame')) {
      skin = const Color(0xFFF1A06B);
      hair = const Color(0xFF7B2419);
      shirt = const Color(0xFFD94A25);
      pants = const Color(0xFF5A241C);
      shoes = const Color(0xFF241515);
    }

    final outline = Paint()
      ..color = const Color(0xFF17191C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..style = PaintingStyle.fill;

    // ---------------- BODY ----------------

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.66),
        width: size.width * 0.48,
        height: size.height * 0.38,
      ),
      Radius.circular(size.width * 0.10),
    );

    fill.color = shirt;
    canvas.drawRRect(bodyRect, fill);
    canvas.drawRRect(bodyRect, outline);

    // Shirt highlight
    fill.color = Colors.white.withValues(alpha: 0.12);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - size.width * 0.20,
          size.height * 0.51,
          size.width * 0.13,
          size.height * 0.22,
        ),
        Radius.circular(5),
      ),
      fill,
    );

    // ---------------- NECK ----------------

    fill.color = skin;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.48),
          width: size.width * 0.16,
          height: size.height * 0.12,
        ),
        Radius.circular(4),
      ),
      fill,
    );

    // ---------------- ARMS ----------------

    final armPaint = Paint()..color = shirt;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - size.width * 0.29,
          size.height * 0.54,
          size.width * 0.12,
          size.height * 0.27,
        ),
        Radius.circular(8),
      ),
      armPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx + size.width * 0.17,
          size.height * 0.54,
          size.width * 0.12,
          size.height * 0.27,
        ),
        Radius.circular(8),
      ),
      armPaint,
    );

    // Hands
    fill.color = skin;

    canvas.drawCircle(
      Offset(cx - size.width * 0.23, size.height * 0.82),
      size.width * 0.065,
      fill,
    );

    canvas.drawCircle(
      Offset(cx + size.width * 0.23, size.height * 0.82),
      size.width * 0.065,
      fill,
    );

    // ---------------- LEGS ----------------

    fill.color = pants;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - size.width * 0.19,
          size.height * 0.79,
          size.width * 0.15,
          size.height * 0.17,
        ),
        Radius.circular(5),
      ),
      fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx + size.width * 0.04,
          size.height * 0.79,
          size.width * 0.15,
          size.height * 0.17,
        ),
        Radius.circular(5),
      ),
      fill,
    );

    // ---------------- SHOES ----------------

    fill.color = shoes;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          cx - size.width * 0.11,
          size.height * 0.96,
        ),
        width: size.width * 0.20,
        height: size.height * 0.08,
      ),
      fill,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          cx + size.width * 0.11,
          size.height * 0.96,
        ),
        width: size.width * 0.20,
        height: size.height * 0.08,
      ),
      fill,
    );

    // ---------------- HEAD ----------------

    fill.color = skin;

    canvas.drawCircle(
      Offset(cx, headCenterY),
      headRadius,
      fill,
    );

    canvas.drawCircle(
      Offset(cx, headCenterY),
      headRadius,
      outline,
    );

    // ---------------- HAIR ----------------

    final hairPath = Path();

    hairPath.moveTo(
      cx - headRadius * 0.95,
      headCenterY - headRadius * 0.15,
    );

    hairPath.quadraticBezierTo(
      cx - headRadius * 0.85,
      headCenterY - headRadius * 1.10,
      cx,
      headCenterY - headRadius * 1.02,
    );

    hairPath.quadraticBezierTo(
      cx + headRadius * 0.90,
      headCenterY - headRadius * 1.05,
      cx + headRadius * 0.95,
      headCenterY - headRadius * 0.10,
    );

    hairPath.quadraticBezierTo(
      cx + headRadius * 0.55,
      headCenterY - headRadius * 0.40,
      cx + headRadius * 0.20,
      headCenterY - headRadius * 0.55,
    );

    hairPath.quadraticBezierTo(
      cx - headRadius * 0.20,
      headCenterY - headRadius * 0.35,
      cx - headRadius * 0.60,
      headCenterY - headRadius * 0.45,
    );

    hairPath.close();

    fill.color = hair;
    canvas.drawPath(hairPath, fill);
    canvas.drawPath(hairPath, outline);

    // ---------------- EYES ----------------

    final eyeY = headCenterY + headRadius * 0.05;
    final eyeX = headRadius * 0.38;
    final eyeRadius = headRadius * 0.25;

    fill.color = Colors.white;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - eyeX, eyeY),
        width: eyeRadius * 1.55,
        height: eyeRadius * 2.0,
      ),
      fill,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + eyeX, eyeY),
        width: eyeRadius * 1.55,
        height: eyeRadius * 2.0,
      ),
      fill,
    );

    // Pupils
    fill.color = const Color(0xFF202124);

    canvas.drawCircle(
      Offset(cx - eyeX, eyeY),
      eyeRadius * 0.48,
      fill,
    );

    canvas.drawCircle(
      Offset(cx + eyeX, eyeY),
      eyeRadius * 0.48,
      fill,
    );

    // Eye highlights
    fill.color = Colors.white;

    canvas.drawCircle(
      Offset(
        cx - eyeX - eyeRadius * 0.12,
        eyeY - eyeRadius * 0.15,
      ),
      eyeRadius * 0.15,
      fill,
    );

    canvas.drawCircle(
      Offset(
        cx + eyeX - eyeRadius * 0.12,
        eyeY - eyeRadius * 0.15,
      ),
      eyeRadius * 0.15,
      fill,
    );

    // ---------------- NOSE ----------------

    final nosePath = Path();

    nosePath.moveTo(
      cx,
      headCenterY + headRadius * 0.15,
    );

    nosePath.quadraticBezierTo(
      cx - headRadius * 0.08,
      headCenterY + headRadius * 0.38,
      cx + headRadius * 0.08,
      headCenterY + headRadius * 0.39,
    );

    canvas.drawPath(nosePath, outline);

    // ---------------- MOUTH ----------------

    final mouthPath = Path();

    mouthPath.moveTo(
      cx - headRadius * 0.28,
      headCenterY + headRadius * 0.52,
    );

    mouthPath.quadraticBezierTo(
      cx,
      headCenterY + headRadius * 0.67,
      cx + headRadius * 0.28,
      headCenterY + headRadius * 0.52,
    );

    canvas.drawPath(mouthPath, outline);

    // ---------------- SPECIAL DETAILS ----------------

    if (text.contains('wizard') || text.contains('mage')) {
      _drawWizardHat(
        canvas,
        cx,
        headCenterY,
        headRadius,
      );
    }

    if (text.contains('robot') ||
        text.contains('machine') ||
        text.contains('android')) {
      _drawRobotDetails(
        canvas,
        cx,
        headCenterY,
        headRadius,
        outline,
      );
    }

    if (text.contains('knight') ||
        text.contains('armor')) {
      _drawKnightDetails(
        canvas,
        cx,
        headCenterY,
        headRadius,
        outline,
      );
    }
  }

  static void _drawWizardHat(
    Canvas canvas,
    double cx,
    double headY,
    double radius,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF5B3B91)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(
      cx - radius * 0.95,
      headY - radius * 0.65,
    );

    path.lineTo(
      cx,
      headY - radius * 1.65,
    );

    path.lineTo(
      cx + radius * 0.95,
      headY - radius * 0.65,
    );

    path.close();

    canvas.drawPath(path, paint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, headY - radius * 0.62),
        width: radius * 2.15,
        height: radius * 0.35,
      ),
      paint,
    );
  }

  static void _drawRobotDetails(
    Canvas canvas,
    double cx,
    double headY,
    double radius,
    Paint outline,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF56D7FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(cx - radius * 0.38, headY + radius * 0.05),
      radius * 0.07,
      paint,
    );

    canvas.drawCircle(
      Offset(cx + radius * 0.38, headY + radius * 0.05),
      radius * 0.07,
      paint,
    );

    canvas.drawLine(
      Offset(cx, headY - radius * 1.0),
      Offset(cx, headY - radius * 1.25),
      outline,
    );
  }

  static void _drawKnightDetails(
    Canvas canvas,
    double cx,
    double headY,
    double radius,
    Paint outline,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF9DA7B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, headY),
        width: radius * 2.0,
        height: radius * 1.8,
      ),
      3.3,
      2.8,
      false,
      paint,
    );

    canvas.drawLine(
      Offset(cx - radius * 0.75, headY + radius * 0.15),
      Offset(cx + radius * 0.75, headY + radius * 0.15),
      paint,
    );
  }
}