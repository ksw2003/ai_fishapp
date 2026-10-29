import 'package:flutter/material.dart';

class DailyTempDetailScreen extends StatelessWidget {
  const DailyTempDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 달력 화면에서 넘겨받는 값 (기존 기능 유지)
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final DateTime selectedDate = args?['selectedDate'] ?? DateTime.now();
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
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 현재 수온 화면과 동일한 뒤로가기 버튼
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

                      SizedBox(height: screenHeight * 0.10),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 현재 수온 화면과 동일한 텍스트 위치 및 간격
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(0, -40),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 34),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: screenHeight * 0.08),

                                    // 선택한 날짜를 표시 (기존 데이터 유지)
                                    Text(
                                      '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일의',
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
                                      '${averageTemp.round()}°C',
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF005BD8),
                                        height: 1,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.23),

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
                                      '${maxTemp.toStringAsFixed(1)}°C',
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
                                      '${minTemp.toStringAsFixed(1)}°C',
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

                          // 동일한 가로 위치, 너비, 높이의 게이지
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
    // 평균 수온 화면의 기존 0~40°C 게이지 계산 그대로 유지
    final double ratio =
        ((temperature - minTemperature) / (maxTemperature - minTemperature))
            .clamp(0.0, 1.0);

    const double barWidth = 58;
    final double fillHeight = barHeight * ratio;

    return SizedBox(
      width: 80,
      height: barHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: barWidth,
              height: fillHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // 현재 수온 화면의 게이지 색상과 통일
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
          Positioned(
            bottom: getTemperatureTextBottom(fillHeight, barHeight),
            child: Text(
              '${temperature.toStringAsFixed(1)}°C',
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

  double getTemperatureTextBottom(double fillHeight, double barHeight) {
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
