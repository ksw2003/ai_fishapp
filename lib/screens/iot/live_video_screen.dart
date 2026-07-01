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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기 버튼
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 30),

              // 상단 환영 문구
              RichText(
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

              const SizedBox(height: 28),

              // 날짜 그라데이션 박스
              Container(
                width: double.infinity,
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
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 실시간 영상 영역
              const RealtimeVideoBox(
                videoUrl: null,
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  '실시간 어항 영상',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
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
          child: LiveVideoRotatingLoadingIcon(),
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

class LiveVideoRotatingLoadingIcon extends StatefulWidget {
  const LiveVideoRotatingLoadingIcon({super.key});

  @override
  State<LiveVideoRotatingLoadingIcon> createState() =>
      _LiveVideoRotatingLoadingIconState();
}

class _LiveVideoRotatingLoadingIconState
    extends State<LiveVideoRotatingLoadingIcon>
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
        size: const Size(46, 46),
        painter: LiveVideoLoadingArcPainter(),
      ),
    );
  }
}

class LiveVideoLoadingArcPainter extends CustomPainter {
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
  bool shouldRepaint(covariant LiveVideoLoadingArcPainter oldDelegate) {
    return false;
  }
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