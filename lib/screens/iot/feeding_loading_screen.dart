import 'dart:async';
import 'dart:math';
import 'package:ai_fishapp/api/sensor_api.dart';
import 'package:flutter/material.dart';

class FeedingLoadingScreen extends StatefulWidget {
  const FeedingLoadingScreen({super.key});

  @override
  State<FeedingLoadingScreen> createState() =>
      _FeedingLoadingScreenState();
}

class _FeedingLoadingScreenState
    extends State<FeedingLoadingScreen> {

  final SensorApi _sensorApi = SensorApi();

  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();

    _connectFeedResult();
  }

  void _connectFeedResult() {
    _subscription = _sensorApi
        .connect('/api/tank/event?event=feed')
        .listen(
      (data) {
        print('먹이 지급 결과: $data');

        if (!mounted) return;

        if (data['type'] == 'feed') {

          if (data['data'] == 'success') {
            Navigator.pop(context);

          } else if (data['data'] == 'failed') {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('먹이 지급에 실패했습니다.'),
              ),
            );

            Navigator.pop(context);
          }
        }
      },
      onError: (error) {
        print('SSE 연결 오류: $error');
      },
    );
  }

  @override
  void dispose() {
    print('먹이 SSE 연결 종료');

    _subscription?.cancel();

    super.dispose();
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const Center(
              child: Column(
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
              ),
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

class _FeedingRotatingLoadingIconState extends State<FeedingRotatingLoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final SensorApi _sensorApi = SensorApi();

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
  bool shouldRepaint(covariant FeedingLoadingArcPainter oldDelegate) {
    return false;
  }
}