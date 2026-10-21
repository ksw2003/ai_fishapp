import 'dart:convert';

import '../models/alert.dart';
import '../api/api_client.dart';

class AlertService {

  static Future<List<AlertModel>> getAlerts() async {

    final response =
    await ApiClient.get('/api/tank/alert', token: true);

    if (response.statusCode != 200) {
      throw Exception('알림 조회 실패');
    }

    final List data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return data
        .map((e) => AlertModel.fromJson(e))
        .toList();
  }
}