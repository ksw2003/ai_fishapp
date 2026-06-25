import 'dart:math';
import 'package:flutter/material.dart';

class LiveVideoScreen extends StatelessWidget {
  const LiveVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 지금은 화면 구현용 가짜 사용자 이름
    // 나중에 로그인 정보 or 백엔드에서 받은 이름으로 교체
    const String userName = '한경이';

    final DateTime now = DateTime.now();
    final String todayText =
        '${now.year}년 ${now.month}월 ${now.day}일 (${getKoreanWeekday(now.weekday)})';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            height: 760,
            color: Colors.white,
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

                // 상단 환영 문구
                Positioned(
                  top: 72,
                  left: 28,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3E5F),
                      ),
                      children: [
                        TextSpan(text: '환영합니다 '),
                        TextSpan(
                          text: userName,
                          style: TextStyle(
                            color: Color(0xFF25A8F2),
                          ),
                        ),
                        TextSpan(text: '님'),
                      ],
                    ),
                  ),
                ),

                // 날짜 그라데이션 박스
                Positioned(
                  top: 120,
                  left: 28,
                  right: 28,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF238BFF),
                          Color(0xFF25C6F2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            todayText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // 카메라 아이콘
                        const Icon(
                          Icons.photo_camera_outlined,
                          size: 25,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                // 실시간 영상 영역
                const Positioned(
                  top: 196,
                  left: 28,
                  right: 28,
                  child: Column(
                    children: [
                      RealtimeVideoBox(
                        videoUrl: null,
                      ),
                      SizedBox(height: 18),
                      Text(
                        '실시간 어항 영상',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RealtimeVideoBox extends StatelessWidget {
  final String? videoUrl;

  const RealtimeVideoBox({
    super.key,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // 지금은 실제 영상 주소가 없으니까 로딩 표시
    if (videoUrl == null || videoUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 155,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: RotatingLoadingIcon(),
        ),
      );
    }

    // 나중에 실제 영상 붙일 자리
    return Container(
      width: double.infinity,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          '실시간 영상 연결 예정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
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
    return SizedBox(
      width: 46,
      height: 46,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: CustomPaint(
              painter: LoadingArcPainter(),
            ),
          );
        },
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
    final double radius = size.width / 2 - 8;

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

    canvas.drawCircle(dotOffset, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

String getKoreanWeekday(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return '월';
    case DateTime.tuesday:
      return '화';
    case DateTime.wednesday:
      return '수';
    case DateTime.thursday:
      return '목';
    case DateTime.friday:
      return '금';
    case DateTime.saturday:
      return '토';
    case DateTime.sunday:
      return '일';
    default:
      return '';
  }
}