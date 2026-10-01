class AlertModel {
  final int alertId;
  final String type;
  final String status;
  final String message;
  final DateTime createdAt;

  AlertModel({
    required this.alertId,
    required this.type,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alert_id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}