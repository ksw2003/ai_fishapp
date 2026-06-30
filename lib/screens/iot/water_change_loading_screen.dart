import 'dart:math';
import 'package:flutter/material.dart';

class WaterChangeLoadingScreen extends StatelessWidget {
  const WaterChangeLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 뒤로가기 버튼
            Positioned(
              top: 18,
              left: 18,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // 중앙 로딩 영역
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotatingLoadingIcon(),
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

class RotatingLoadingIcon extends StatefulWidget {
  const RotatingLoadingIcon({super.key});

  @override
  State<RotatingLoadingIcon> createState() => _RotatingLoadingIconState();
}

class _RotatingLoadingIconState extends State<RotatingLoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 서버 완료 신호가 오기 전까지 계속 회전
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

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 10;

    // 일부만 그려지는 원
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.25,
      pi * 1.45,
      false,
      arcPaint,
    );

    // 끝에 작은 점
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