import 'dart:convert';
import 'dart:math';

import 'package:ai_fishapp/api/motor_api.dart';
import 'package:flutter/material.dart';

class WaterChangeLoadingScreen extends StatefulWidget {
  const WaterChangeLoadingScreen({super.key});

  @override
  State<WaterChangeLoadingScreen> createState() =>
      _WaterChangeLoadingScreenState();
}

class _WaterChangeLoadingScreenState
    extends State<WaterChangeLoadingScreen> {
  bool _isCompleted = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _startWaterChange();
  }

  Future<void> _startWaterChange() async {
    try {
      final response = await MotorApi.waterChange();

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isCompleted = true;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted) return;

          Navigator.pop(context, true);
        });
      } else {
        setState(() {
          _isError = true;
        });
      }
    } catch (e) {
      print('환수 오류 : $e');

      if (!mounted) return;

      setState(() {
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18,
              left: 18,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: _isCompleted || _isError
                    ? () {
                  Navigator.pop(context);
                }
                    : null,
              ),
            ),

            Center(
              child: _isError
                  ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 70,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '환수에 실패했습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : _isCompleted
                  ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 70,
                    color: Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '환수가 완료되었습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WaterChangeRotatingLoadingIcon(),
                  SizedBox(height: 24),
                  Text(
                    '환수중입니다...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CB8E8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterChangeRotatingLoadingIcon extends StatefulWidget {
  const WaterChangeRotatingLoadingIcon({super.key});

  @override
  State<WaterChangeRotatingLoadingIcon> createState() =>
      _WaterChangeRotatingLoadingIconState();
}

class _WaterChangeRotatingLoadingIconState
    extends State<WaterChangeRotatingLoadingIcon>
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
        painter: WaterChangeLoadingArcPainter(),
      ),
    );
  }
}

class WaterChangeLoadingArcPainter extends CustomPainter {
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

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
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
  bool shouldRepaint(covariant WaterChangeLoadingArcPainter oldDelegate) {
    return false;
  }
}