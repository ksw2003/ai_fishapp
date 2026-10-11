import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/sensor_api.dart';
import '../../models/sensor.dart';
import '../../services/tank_service.dart';
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
  double? minTemp;
  double? maxTemp;

  Future<void> loadTankSetting() async {
    final setting = await TankService.getTankSetting();

    setState(() {
      minTemp = (setting['min_temp'] as num).toDouble();
      maxTemp = (setting['max_temp'] as num).toDouble();
    });
  }

  @override
  void initState() {
    super.initState();
    loadTankSetting();
    SensorApi().connect('/api/tank/data').listen((data) {
      if (!mounted) return;

      if (data["type"] == "sensor") {
        setState(() {
          sensor = SensorData.fromJson(data["data"]);
        });
      }
    });
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
    final double currentmaxTemp = sensor!.maxTemp;
    final double currentminTemp = sensor!.minTemp;

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
                                    '${currentmaxTemp.toInt()}°C',
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
                                    '${currentminTemp.toInt()}°C',
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
                            minTemperature: currentminTemp ?? 15,
                            maxTemperature: currentmaxTemp ?? 30,
                            minTemp : minTemp ?? 10,
                            maxTemp: maxTemp ?? 30,
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
  final double minTemp;
  final double maxTemp;


  const TemperatureBar({
    super.key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.barHeight,
    required this.minTemp,
    required this.maxTemp
  });

  List<Color> getTemperatureGradient(double temp) {
    if (minTemp == null || maxTemp == null) {
      return const [
        Color(0xFF18DDE8),
        Color(0xFF00A8F5),
        Color(0xFF006BF0),
      ];
    }

    if (temp < minTemp!) {
      return const [
        Color(0xFF0083D5),
        Color(0xFF0047CC),
        Color(0xFF001392),
      ];
    } else if (temp > maxTemp!) {
      return const [
        Color(0xFFFF9A9A),
        Color(0xFFFF5252),
        Color(0xFFD50000),
      ];
    } else {
      return const [
        Color(0xFF18DDE8),
        Color(0xFF00A8F5),
        Color(0xFF006BF0),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barWidth = 58;

    final double ratio =
    (temperature / 40.0).clamp(0.0, 1.0);

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