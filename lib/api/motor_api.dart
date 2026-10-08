import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

class MotorApi {
  static const String baseUrl =
      'http://13.239.199.189:3000';

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

  static Future<http.Response> feed() async{
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