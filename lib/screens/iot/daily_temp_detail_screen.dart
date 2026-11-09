
import 'package:flutter/material.dart';

class DailyTempDetailScreen extends StatelessWidget {
  const DailyTempDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 달력 화면에서 전달받은 데이터
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    final DateTime selectedDate =
        args?['selectedDate'] ?? DateTime.now();

    final double averageTemp =
        (args?['averageTemp'] as num?)?.toDouble() ?? 24.0;

    final double maxTemp =
        (args?['maxTemp'] as num?)?.toDouble() ?? 25.0;

    final double minTemp =
        (args?['minTemp'] as num?)?.toDouble() ?? 23.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenHeight = constraints.maxHeight;
            final double gaugeHeight =
                (screenHeight * 0.58).clamp(330.0, 430.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 뒤로가기 버튼 (크기 24)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 24,
                          color: Color(0xFF8FA8D8),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      SizedBox(height: screenHeight * 0.10),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 수온 정보
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(0, -40),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 34),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.08,
                                    ),

                                    // 선택한 날짜
                                    Text(
                                      '${selectedDate.year}년 '
                                      '${selectedDate.month}월 '
                                      '${selectedDate.day}일의',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF005BD8),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    const Text(
                                      '평균 수온은',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF005BD8),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '${averageTemp.toInt()}°C',
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF005BD8),
                                        height: 1,
                                      ),
                                    ),

                                    // 최고·최저수온 위치 조정
                                    SizedBox(
                                      height: screenHeight * 0.19,
                                    ),

                                    const Text(
                                      '최고수온:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB0C4EA),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      '${maxTemp.toInt()}°C',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF91ACDF),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    const Text(
                                      '최저수온:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB0C4EA),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      '${minTemp.toInt()}°C',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF91ACDF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // 오른쪽 수온 게이지
                          DailyTemperatureBar(
                            temperature: averageTemp,
                            minTemperature: 0,
                            maxTemperature: 40,
                            barHeight: gaugeHeight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DailyTemperatureBar extends StatelessWidget {
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double barHeight;

  const DailyTemperatureBar({
    super.key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.barHeight,
  });

  @override
  Widget build(BuildContext context) {
    // 0~40°C 기준 게이지 계산
    final double ratio =
        ((temperature - minTemperature) /
                (maxTemperature - minTemperature))
            .clamp(0.0, 1.0);

    const double barWidth = 58;
    final double fillHeight = barHeight * ratio;

    return SizedBox(
      width: 80,
      height: barHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 회색 배경 게이지
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(40),
            ),
          ),

          // 평균 수온만큼 차오르는 게이지
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: barWidth,
              height: fillHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF18DDE8),
                    Color(0xFF00A8F5),
                    Color(0xFF006BF0),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // 게이지 내부 온도 (소수점 제거)
          Positioned(
            bottom: getTemperatureTextBottom(
              fillHeight,
              barHeight,
            ),
            child: Text(
              '${temperature.toInt()}°C',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double getTemperatureTextBottom(
    double fillHeight,
    double barHeight,
  ) {
    final double position = fillHeight - 65;
    final double maxPosition = barHeight - 80;

    if (position < 20) {
      return 20;
    }

    if (position > maxPosition) {
      return maxPosition;
    }

    return position;
  }
}
