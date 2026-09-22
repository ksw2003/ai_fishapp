import 'dart:async';
import 'dart:math';
import 'package:ai_fishapp/api/sensor_api.dart';
import 'package:flutter/material.dart';

class WaterChangeLoadingScreen extends StatefulWidget {
  const WaterChangeLoadingScreen({super.key});

  @override
  State<WaterChangeLoadingScreen> createState()=>
    _WaterChangeLoadingScreenState();
}

class _WaterChangeLoadingScreenState extends State<WaterChangeLoadingScreen>{
  final SensorApi _sensorApi = SensorApi();

  StreamSubscription<Map<String, dynamic>>? _subscription;
 @override
  void initState() {
    super.initState();
    _connectWCResult();
  }

  void _connectWCResult(){
    _subscription = _sensorApi
        .connect('/api/tank/event?event=waterquality')
        .listen(
      (data) {
        print('환수 결과: $data');

        if (!mounted) return;

        if (data['type'] == 'waterChange') {

          if (data['data'] == 'success') {
            Navigator.pop(context);

          } else if (data['data'] == 'failed') {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('환수 실패했습니다.'),
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
    print('환수 SSE 연결 종료');

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