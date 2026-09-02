import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../api/motor_api.dart';

class FeedingLoadingScreen extends StatefulWidget {
  const FeedingLoadingScreen({super.key});

  @override
  State<FeedingLoadingScreen> createState() =>
      _FeedingLoadingScreenState();
}

class _FeedingLoadingScreenState
    extends State<FeedingLoadingScreen> {

  bool _isCompleted = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _startFeeding();
  }

  Future<void> _startFeeding() async {
    try {
      final response = await MotorApi.feed();

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

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
      print('급여 오류 : $e');

      if (!mounted) return;

      setState(() {
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isError) {
      content = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            '먹이 급여에 실패했습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (_isCompleted) {
      content = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Color(0xFF00BDF2),
          ),
          SizedBox(height: 20),
          Text(
            '먹이 급여가 완료되었습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00BDF2),
            ),
          ),
        ],
      );
    } else {
      content = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FeedingRotatingLoadingIcon(),
          SizedBox(height: 24),
          Text(
            '먹이 급여중입니다...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CB8E8),
            ),
          ),
        ],
      );
    }

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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            Center(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingRotatingLoadingIcon extends StatefulWidget {
  const FeedingRotatingLoadingIcon({super.key});

  @override
  State<FeedingRotatingLoadingIcon> createState() =>
      _FeedingRotatingLoadingIconState();
}

class _FeedingRotatingLoadingIconState
    extends State<FeedingRotatingLoadingIcon>
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
        painter: FeedingLoadingArcPainter(),
      ),
    );
  }
}

class FeedingLoadingArcPainter extends CustomPainter {
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
      ..color = const Color(0xFF5BC8FF);

    final Offset center =
    Offset(size.width / 2, size.height / 2);

    final double radius =
        size.width / 2 - 10;

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

    canvas.drawCircle(
      dotOffset,
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant FeedingLoadingArcPainter oldDelegate) {
    return false;
  }
}