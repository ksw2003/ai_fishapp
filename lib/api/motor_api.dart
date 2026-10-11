import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/token_storage.dart';

class MotorApi {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static Future<http.Response> waterChange() async {
    final deviceId = await TokenStorage.getdeviceId();

    return http.post(
      Uri.parse('$baseUrl/api/tank/waterchange'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_Id': deviceId,
      }),
    );
  }

  static Future<http.Response> feed() async {
    final deviceId = await TokenStorage.getdeviceId();

    return http.post(
      Uri.parse('$baseUrl/api/tank/feed'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceId': deviceId,
      }),
    );
  }
}