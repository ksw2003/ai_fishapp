import 'dart:convert';
import 'package:http/http.dart' as http;

class MotorApi {
  static const String baseUrl =
      'http://192.168.45.165:3000';

  static Future<http.Response> waterChange() {
    return http.post(
      Uri.parse('$baseUrl/api/tank/waterchange'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_Id': 'SS501',
      }),
    );
  }

  static Future<http.Response> feed() {
    return http.post(
      Uri.parse('$baseUrl/api/tank/feed'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceId': 'SS501',
      }),
    );
  }
}