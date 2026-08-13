import 'package:http/http.dart' as http;

class ApiClient {
  // 백엔드 주소
  static const String baseUrl = "http://192.168.45.161:3000";

  static Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  static Future<http.Response> post(
      String endpoint,
      String body,
      ) async {
    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );
  }
}