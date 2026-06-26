import 'package:flutter/material.dart';

class DailyTempDetailScreen extends StatelessWidget {
  const DailyTempDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 달력 화면에서 넘겨받는 값
    // 나중에 백엔드에서 선택 날짜의 평균/최고/최저 수온 받아와서 전달
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final DateTime selectedDate = args?['selectedDate'] ?? DateTime.now();
    final double averageTemp = args?['averageTemp'] ?? 24.0;
    final double maxTemp = args?['maxTemp'] ?? 25.0;
    final double minTemp = args?['minTemp'] ?? 23.0;

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
                      size: 16,
                      color: Color(0xFF8FA8D8),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // 왼쪽 텍스트 영역
                Positioned(
                  top: 190,
                  left: 38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일의',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF006FEF),
                        ),
                      ),
                      const Text(
                        '평균 수온은',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF006FEF),
                        ),
                      ),
                      Text(
                        '${averageTemp.toStringAsFixed(0)}˚C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF006FEF),
                        ),
                      ),

                      const SizedBox(height: 70),

                      const Text(
                        '최고수온:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9CB8E8),
                        ),
                      ),
                      Text(
                        '${maxTemp.toStringAsFixed(0)}˚C',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF006FEF),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        '최저수온:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9CB8E8),
                        ),
                      ),
                      Text(
                        '${minTemp.toStringAsFixed(0)}˚C',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF006FEF),
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽 수온 바
                Positioned(
                  top: 140,
                  right: 48,
                  child: DailyTemperatureBar(
                    temperature: averageTemp,
                    minTemperature: 0,
                    maxTemperature: 40,
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

class DailyTemperatureBar extends StatelessWidget {
  final double temperature;
  final double minTemperature;
  final double maxTemperature;

  const DailyTemperatureBar({
    super.key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio =
        ((temperature - minTemperature) / (maxTemperature - minTemperature))
            .clamp(0.0, 1.0);

    const double barWidth = 52;
    const double barHeight = 430;

    return SizedBox(
      width: barWidth,
      height: barHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 회색 배경 바
          Container(
            width: 52,
            height: barHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(26),
            ),
          ),

          // 수온 채워지는 부분
          Container(
            width: 52,
            height: barHeight * ratio,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF20D7E8),
                  Color(0xFF0073F5),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
          ),

          // 가운데 수온 텍스트
          Positioned(
            bottom: (barHeight * ratio) - 42 < 20
                ? 20
                : (barHeight * ratio) - 42,
            child: Text(
              '${temperature.toStringAsFixed(0)}˚C',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}