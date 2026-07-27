import 'dart:async';

import 'package:flutter/material.dart';
import '../../api/sensor_api.dart';
import '../../models/sensor.dart';

class WaterTempDetailScreen extends StatefulWidget {
  const WaterTempDetailScreen({super.key});

  @override
  State<WaterTempDetailScreen> createState() =>
      _WaterTempDetailScreenState();
}

class _WaterTempDetailScreenState extends State<WaterTempDetailScreen> {
  final SensorApi _sensorApi = SensorApi();

  SensorData? sensor;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadData();

    // 5초마다 최신 데이터 조회
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await _sensorApi.getStatus();

      if (!mounted) return;

      setState(() {
        sensor = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sensor == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final double currentTemp = sensor!.temperature;

    // 아직 API가 없으므로 임시
    final double maxTemp = currentTemp;
    final double minTemp = currentTemp;

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

                      SizedBox(height: screenHeight * 0.10),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 텍스트 영역
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 34),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: screenHeight * 0.08),

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

                                  SizedBox(height: screenHeight * 0.23),

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
                          ),

                          const SizedBox(width: 16),

                          // 오른쪽 수온 게이지
                          TemperatureBar(
                            temperature: currentTemp,
                            minTemperature: 15,
                            maxTemperature: 30,
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

class TemperatureBar extends StatelessWidget {
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double barHeight;

  const TemperatureBar({
    super.key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.barHeight,
  });

  @override
  Widget build(BuildContext context) {
    const double barWidth = 58;

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
            bottom: getTemperatureTextBottom(fillHeight, barHeight),
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

// 온도에 따라 게이지 색 바뀌는 부분
List<Color> getTemperatureGradient(double temp) {
  if (temp < 18) {
    // 낮은 수온: 밝은 하늘색 ~ 파랑
    return const [
      Color(0xFFB8F3FF),
      Color(0xFF48B8FF),
      Color(0xFF006BF0),
    ];
  } else if (temp <= 22) {
    // 적정 수온: 청록 ~ 파랑
    return const [
      Color(0xFF18DDE8),
      Color(0xFF00A8F5),
      Color(0xFF006BF0),
    ];
  } else if (temp <= 26) {
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