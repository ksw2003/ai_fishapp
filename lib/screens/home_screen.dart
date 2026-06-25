import 'package:flutter/material.dart';
import '../widgets/common_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ===============================
    // 화면 구현용 임시 데이터
    // 나중에 로그인/백엔드/API 응답값으로 교체할 부분
    // ===============================

    // 로그인한 사용자 이름
    const String userName = '한경이';

    // 백엔드에서 받아올 현재 수온 값
    const double waterTemp = 25;

    // 백엔드에서 받아올 현재 수질 상태
    const String waterQuality = '정상';

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            height: 760,
            color: Colors.white,
            child: Stack(
              children: [
                // 상단 환영 문구
                Positioned(
                  top: 34,
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
                            color: Color(0xFF008DF2),
                          ),
                        ),
                        TextSpan(text: '님'),
                      ],
                    ),
                  ),
                ),

                // 날짜 + 카메라 + 오늘의 물고기 상태 카드
                // 카드 전체를 누르면 실시간 영상 화면으로 이동
                Positioned(
                  top: 82,
                  left: 28,
                  right: 28,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white.withOpacity(0.22),
                      highlightColor: Colors.white.withOpacity(0.10),
                      onTap: () {
                        Navigator.pushNamed(context, '/live-video');
                      },
                      child: Ink(
                        height: 135,
                        padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // 카메라 아이콘
                            // 백엔드에서 실시간 영상 URL을 받아오면 이 카드 클릭 시 영상 화면으로 이동
                            const Positioned(
                              top: 2,
                              right: 2,
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 34,
                                color: Colors.white,
                              ),
                            ),

                            const Positioned(
                              right: 0,
                              bottom: 18,
                              child: Text(
                                '오늘의 물고기 상태:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 카드 4개
                Positioned(
                  top: 236,
                  left: 28,
                  right: 28,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: HomeInfoCard(
                              title: '수온',
                              value: '${waterTemp.toInt()}˚C',
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
                              value: waterQuality,
                              valueColor: const Color(0xFF00BDF2),
                              onTap: () {
                                // 나중에 수질 상세 화면 만들면 여기 route 연결
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

                // 공통 하단 네비게이션바
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CommonBottomNavBar(
                    selectedIndex: 0,
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
        shadowColor: Colors.black.withOpacity(0.18),
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
            height: 110,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3E5F),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 6,
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 23,
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
        shadowColor: Colors.black.withOpacity(0.18),
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
            height: 110,
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
                      fontSize: 14,
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
                    size: 34,
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