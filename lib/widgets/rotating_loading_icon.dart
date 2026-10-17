import 'dart:math';
import 'package:flutter/material.dart';

class RotatingLoadingIcon extends StatefulWidget {
  const RotatingLoadingIcon({super.key});

  @override
  State<RotatingLoadingIcon> createState() =>
      _RotatingLoadingIconState();
}

class _RotatingLoadingIconState extends State<RotatingLoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(64, 64),
        painter: LoadingArcPainter(),
      ),
    );
  }
}

class LoadingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF7BA4FF),
          Color(0xFF5BC8FF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF5BC8FF)
      ..style = PaintingStyle.fill;

    final Offset center =
        Offset(size.width / 2, size.height / 2);

    final double radius = size.width / 2 - 10;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      pi * 0.25,
      pi * 1.45,
      false,
      arcPaint,
    );

    final double dotAngle = pi * 0.25;

    final Offset dotOffset = Offset(
      center.dx + cos(dotAngle) * radius,
      center.dy + sin(dotAngle) * radius,
    );

    canvas.drawCircle(dotOffset, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant LoadingArcPainter oldDelegate) {
    return false;
  }
}