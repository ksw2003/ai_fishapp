import 'package:flutter/material.dart';
import '../widgets/common_bottom_nav_bar.dart';
import '../api/sensor_api.dart';
import '../models/sensor.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final SensorApi _sensorApi = SensorApi();

  SensorData? sensor;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    loadSensor();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => loadSensor(),
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSensor() async {
    try {
      print("API 호출 시작");

      final result = await _sensorApi.getStatus();

      print("온도 : ${result.temperature}");
      print("TDS : ${result.waterQuality}");
      print("물고기 : ${result.fishStatus}");

      setState(() {
        sensor = result;
      });

    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ===============================
    // 화면 구현용 임시 데이터
    // 나중에 로그인/백엔드/API 응답값으로 교체할 부분
    // ===============================

    // 로그인한 사용자 이름
    const String userName = '한경이';

    // AI 분석 결과 또는 백엔드에서 받아올 오늘의 물고기 상태
    const String fishCondition = '매우 좋음';

    // 백엔드에서 받아올 오늘 환수 완료 여부
    const bool waterChangeDone = false;

    // 백엔드에서 받아올 오늘 먹이 급여 완료 여부
    const bool feedingDone = true;

    final DateTime now = DateTime.now();
    final String todayText =
        '${now.year}년 ${now.month}월 ${now.day}일 (${getKoreanWeekday(now.weekday)})';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(37.5, 24, 30, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 환영 문구
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 26.19,
                          fontWeight: FontWeight.w700,
                          height: 1.09,
                          color: Color(0xFF2D3E5F),
                        ),
                        children: [
                          TextSpan(text: '환영합니다 '),
                          TextSpan(
                            text: userName,
                            style: TextStyle(
                              color: Color(0xFF008DF2),
                            ),
                          ),
                          TextSpan(text: '님'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 날짜 + 카메라 + 오늘의 물고기 상태 카드
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22.5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22.5),
                        splashColor: Colors.white.withOpacity(0.22),
                        highlightColor: Colors.white.withOpacity(0.10),
                        onTap: () {
                          Navigator.pushNamed(context, '/live-video');
                        },
                        child: Ink(
                          width: 340,
                          height: 210.50,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF238BFF),
                                Color(0xFF25C6F2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Text(
                                  todayText,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),

                              const Positioned(
                                right: 0,
                                bottom: 36,
                                child: Text(
                                  '오늘의 물고기 상태:',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Text(
                                  fishCondition,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 19),

                    // 카드 4개
                    Row(
                      children: [
                        Expanded(
                          child: HomeInfoCard(
                            title: '수온',
                            value: sensor == null
                                ? '--℃'
                                : '${sensor!.temperature.toInt()}℃',
                            valueColor: const Color(0xFF9CB8E8),
                            onTap: () {
                              Navigator.pushNamed(context, '/water-temp');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HomeInfoCard(
                            title: '수질',
                            value: sensor == null
                                ? '--'
                                : _getWaterQualityText(sensor!.waterQuality),
                            valueColor: const Color(0xFF00BDF2),
                            onTap: () {
                              print('수질 카드 클릭');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: HomeActionCard(
                            title: '환수하기',
                            isDone: waterChangeDone,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/water-change-loading',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HomeActionCard(
                            title: '먹이주기',
                            isDone: feedingDone,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/feeding-loading',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 공통 하단 네비게이션바
      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 0,
      ),
    );
  }
}

String _getWaterQualityText(int tds) {
  if (tds <= 300) {
    return "좋음";
  } else if (tds <= 600) {
    return "보통";
  } else {
    return "나쁨";
  }
}

class HomeInfoCard extends StatefulWidget {
  final String title;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  const HomeInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.onTap,
  });

  @override
  State<HomeInfoCard> createState() => _HomeInfoCardState();
}

class _HomeInfoCardState extends State<HomeInfoCard> {
  bool isPressed = false;

  void setPressed(bool value) {
    setState(() {
      isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        elevation: isPressed ? 1 : 5,
        shadowColor: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
          highlightColor: const Color(0xFF8FA8D8).withOpacity(0.10),
          onTap: widget.onTap,
          onTapDown: (_) {
            setPressed(true);
          },
          onTapUp: (_) {
            setPressed(false);
          },
          onTapCancel: () {
            setPressed(false);
          },
          child: Ink(
            height: 158,
            width: 158,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isPressed ? const Color(0xFFF4F8FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEAF1FA),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3E5F),
                      height: 1.46,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 6,
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: widget.valueColor,
                    ),
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

class HomeActionCard extends StatefulWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.onTap,
  });

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard> {
  bool isPressed = false;

  void setPressed(bool value) {
    setState(() {
      isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        widget.isDone ? const Color(0xFF00BDF2) : const Color(0xFFFF91A4);

    final IconData statusIcon =
        widget.isDone ? Icons.check_circle_outline : Icons.close;

    return AnimatedScale(
      scale: isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        elevation: isPressed ? 1 : 5,
        shadowColor: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
          highlightColor: const Color(0xFF8FA8D8).withOpacity(0.10),
          onTap: widget.onTap,
          onTapDown: (_) {
            setPressed(true);
          },
          onTapUp: (_) {
            setPressed(false);
          },
          onTapCancel: () {
            setPressed(false);
          },
          child: Ink(
            height: 158,
            width: 158,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isPressed ? const Color(0xFFF4F8FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEAF1FA),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3E5F),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    statusIcon,
                    size: 48,
                    color: statusColor,
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