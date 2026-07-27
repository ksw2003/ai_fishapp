import 'dart:convert';

import '../models/sensor.dart';
import 'api_client.dart';

class SensorApi {
  Future<SensorData> getStatus() async {
    final response = await ApiClient.get("/api/tank/status");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return SensorData.fromJson(data["tank"]);
    }

    throw Exception("상태 조회 실패");
  }
}