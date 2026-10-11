import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/common_bottom_nav_bar.dart';
import '../api/dairy_api.dart';
import '../services/tank_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  int? normalWater;
  int? warningWater;

  String _getWaterQualityText(int tds) {
    if (normalWater == null || warningWater == null) {
      return '로딩중';
    }

    if (tds <= normalWater!) {
      return '좋음';
    } else if (tds <= warningWater!) {
      return '보통';
    } else {
      return '나쁨';
    }
  }
  DateTime focusedDay = DateTime.now();

  // 사용자가 선택한 날짜
  DateTime selectedDay = DateTime.now();
  Map<String, dynamic>? selectedData;
  bool isLoading = false;

  Future<void> loadDiary() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await DiaryApi.getDiary(selectedDay);

      if (response != null && response['exist'] == true) {
        setState(() {
          selectedData = response;
        });
      } else {
        setState(() {
          selectedData = null;
        });
      }
    } catch (e) {
      print('일지 조회 실패 : $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String monthName(int month) {
    const List<String> monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return monthNames[month];
  }

  @override
  void initState() {
    super.initState();
    loadDiary();
  }

  @override
  Widget build(BuildContext context) {
    final String selectedKey = dateKey(selectedDay);
    final data = selectedData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 54, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 월 표시 + 이전/다음 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthName(focusedDay.month),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3E5F),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 22,
                          color: Color(0xFF8FA8D8),
                        ),
                        onPressed: () {
                          setState(() {
                            focusedDay = DateTime(
                              focusedDay.year,
                              focusedDay.month - 1,
                              1,
                            );
                            selectedDay = focusedDay;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: Color(0xFF8FA8D8),
                        ),
                        onPressed: () {
                          setState(() {
                            focusedDay = DateTime(
                              focusedDay.year,
                              focusedDay.month + 1,
                              1,
                            );
                            selectedDay = focusedDay;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 달력
              TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2035, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekHeight: 50,
                rowHeight: 50,
                sixWeekMonthsEnforced: false,
                onDaySelected: (selected, focused) async {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                  await loadDiary();
                },
                onPageChanged: (focused) {
                  setState(() {
                    focusedDay = focused;
                  });
                },
                eventLoader: (day) {
                  return [];
                },
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3E5F),
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3E5F),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3E5F),
                  ),
                  weekendTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3E5F),
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFFBDEBFF).withOpacity(0.75),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3E5F),
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF22B8F2),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF22B8F2),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerSize: 4,
                  markerMargin: const EdgeInsets.only(top: 3),
                  cellMargin: const EdgeInsets.all(4),
                ),
              ),

              const SizedBox(height: 22),

              // 선택 날짜 표시
              Text(
                '${selectedDay.year}.${selectedDay.month.toString().padLeft(2, '0')}.${selectedDay.day.toString().padLeft(2, '0')} 기록',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF393C43),
                ),
              ),

              const SizedBox(height: 18),

              // 선택 날짜의 기록 카드
              Row(
                children: [
                  Expanded(
                    child: CalendarInfoCard(
                      title: '평균 수온',
                      value: data == null
                          ? '-'
                          : '${data?['daily']?['temp_avg']}˚C',
                      valueColor: const Color(0xFF9CB8E8),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/daily-temp-detail',
                          arguments: {
                            'selectedDate': selectedDay,
                            'averageTemp': data?['daily']['temp_avg'] ?? 0.0,
                            'maxTemp': data?['daily']['temp_max'] ?? 0.0,
                            'minTemp': data?['daily']['temp_min'] ?? 0.0,
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CalendarInfoCard(
                      title: '수질',
                      value: data == null
                          ? '기록 없음'
                          : _getWaterQualityText(
                        data?['daily']?['water_quality'] ?? 0,

                      ),
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
                    child: CalendarActionCard(
                      title: '환수하기',
                      isDone: (data?['waterChange'] as List?)?.isNotEmpty ?? false,
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
                    child: CalendarActionCard(
                      title: '먹이주기',
                      isDone: (data?['Feeding'] as List?)?.isNotEmpty ?? false,
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // 하단 네비게이션바 고정
      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}

class CalendarInfoCard extends StatefulWidget {
  final String title;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  const CalendarInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.onTap,
  });

  @override
  State<CalendarInfoCard> createState() => _CalendarInfoCardState();
}

class _CalendarInfoCardState extends State<CalendarInfoCard> {
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
        elevation: isPressed ? 2 : 8,
        shadowColor: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
          highlightColor: const Color(0xFF8FA8D8).withOpacity(0.10),
          onTap: widget.onTap,
          onTapDown: (_) => setPressed(true),
          onTapUp: (_) => setPressed(false),
          onTapCancel: () => setPressed(false),
          child: Ink(
            height: 110,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isPressed ? const Color(0xFFF4F8FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDCE8F6),
                width: 1.5,
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
                      fontSize: 20,
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
                      fontSize: 22,
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

class CalendarActionCard extends StatefulWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;

  const CalendarActionCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.onTap,
  });

  @override
  State<CalendarActionCard> createState() => _CalendarActionCardState();
}

class _CalendarActionCardState extends State<CalendarActionCard> {
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
        elevation: isPressed ? 2 : 8,
        shadowColor: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
          highlightColor: const Color(0xFF8FA8D8).withOpacity(0.10),
          onTap: widget.onTap,
          onTapDown: (_) => setPressed(true),
          onTapUp: (_) => setPressed(false),
          onTapCancel: () => setPressed(false),
          child: Ink(
            height: 110,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isPressed ? const Color(0xFFF4F8FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDCE8F6),
                width: 1.5,
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
                      fontSize: 20,
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