import 'dart:math' as math;

import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final ValueChanged<Offset> onDirectionChanged;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset knobPosition = Offset.zero;

  static const double size = 120;
  static const double knobSize = 50;
  static const double maxDistance = 35;

  void _updateJoystick(Offset localPosition) {
    final center = const Offset(size / 2, size / 2);

    Offset offset = localPosition - center;

    final distance = offset.distance;

    if (distance > maxDistance) {
      offset = Offset(
        offset.dx / distance * maxDistance,
        offset.dy / distance * maxDistance,
      );
    }

    setState(() {
      knobPosition = offset;
    });

    final direction = Offset(
      offset.dx / maxDistance,
      offset.dy / maxDistance,
    );

    widget.onDirectionChanged(direction);
  }

  void _resetJoystick() {
    setState(() {
      knobPosition = Offset.zero;
    });

    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _updateJoystick(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateJoystick(details.localPosition);
      },
      onPanEnd: (_) {
        _resetJoystick();
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.35),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),

            Transform.translate(
              offset: knobPosition,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}