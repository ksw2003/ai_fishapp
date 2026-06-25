import 'package:flutter/material.dart';

class WaterTempDetailScreen extends StatelessWidget {
  const WaterTempDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 지금은 화면 구현용 임시값
    // 나중에 백엔드에서 받은 수온값으로 바꾸면 됨
    const double currentTemp = 25;
    const double maxTemp = 25;
    const double minTemp = 23;

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

                // 현재 수온 텍스트
                Positioned(
                  top: 185,
                  left: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '현재 수온은',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF005BD8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${currentTemp.toInt()}°C',
                        style: const TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF005BD8),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // 오늘 최고/최저 수온
                Positioned(
                  top: 415,
                  left: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘 최고수온:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB0C4EA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${maxTemp.toInt()}°C',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF91ACDF),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        '오늘 최저수온:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB0C4EA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${minTemp.toInt()}°C',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF91ACDF),
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽 수온 게이지
                const Positioned(
                  top: 128,
                  right: 44,
                  child: TemperatureBar(
                    temperature: currentTemp,
                    minTemperature: 15,
                    maxTemperature: 30,
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

class TemperatureBar extends StatelessWidget {
  final double temperature;
  final double minTemperature;
  final double maxTemperature;

  const TemperatureBar({
    super.key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
  });

  @override
  Widget build(BuildContext context) {
    const double barWidth = 58;
    const double barHeight = 430;

    final double ratio =
        ((temperature - minTemperature) / (maxTemperature - minTemperature))
            .clamp(0.0, 1.0);

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

          // 현재 온도만큼 차오른 게이지
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: barWidth,
              height: fillHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: getTemperatureGradient(temperature),
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // 게이지 안 온도 텍스트
          Positioned(
            bottom: getTemperatureTextBottom(fillHeight),
            child: Text(
              '${temperature.toInt()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double getTemperatureTextBottom(double fillHeight) {
    final double position = fillHeight - 65;

    if (position < 20) {
      return 20;
    }

    if (position > 350) {
      return 350;
    }

    return position;
  }
}

// 온도에 따라 게이지 색 바뀌는 부분
List<Color> getTemperatureGradient(double temp) {
  if (temp <= 20) {
    // 낮은 수온: 밝은 하늘색 ~ 파랑
    return const [
      Color(0xFFB8F3FF),
      Color(0xFF48B8FF),
      Color(0xFF006BF0),
    ];
  } else if (temp <= 26) {
    // 적정 수온: 네 사진 느낌 청록 ~ 파랑
    return const [
      Color(0xFF18DDE8),
      Color(0xFF00A8F5),
      Color(0xFF006BF0),
    ];
  } else if (temp <= 30) {
    // 높은 수온: 노랑 ~ 주황
    return const [
      Color(0xFFFFE082),
      Color(0xFFFFA726),
      Color(0xFFFF7043),
    ];
  } else {
    // 위험 수온: 빨강 계열
    return const [
      Color(0xFFFF9A9A),
      Color(0xFFFF5252),
      Color(0xFFD50000),
    ];
  }
}