class SensorData {
  final double temperature;
  final int waterQuality;
  final int activity;
  final String fishStatus;
  final List<dynamic> alerts;
  final DateTime updatedAt;

  SensorData({
    required this.temperature,
    required this.waterQuality,
    required this.activity,
    required this.fishStatus,
    required this.alerts,
    required this.updatedAt,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      waterQuality: json['waterQuality'] as int,
      activity: json['activity'] as int,
      fishStatus: json['fishStatus'] as String,
      alerts: json['alerts'] as List<dynamic>,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}