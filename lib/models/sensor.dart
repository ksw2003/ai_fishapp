class SensorData {
  final double temperature;
  final int water_quality;
  final double maxTemp;
  final double minTemp;
  final DateTime maxTempAt;
  final DateTime minTempAt;

  SensorData({
    required this.temperature,
    required this.water_quality,
    required this.maxTemp,
    required this.minTemp,
    required this.maxTempAt,
    required this.minTempAt,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      water_quality: json['water_quality'] as int,
      maxTemp: (json['max_temp'] as num).toDouble(),
      minTemp: (json['min_temp'] as num).toDouble(),
      maxTempAt: DateTime.parse(json['max_temp_at']),
      minTempAt: DateTime.parse(json['min_temp_at']),
    );
  }
}