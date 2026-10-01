import 'dart:convert';
import 'package:http/http.dart' as http;

class DiaryService {
  static const String baseUrl =
      'http://13.239.199.189:3000';

  static Future<Map<String, dynamic>> getDiary(
      DateTime day) async {

    final response = await http.get(
      Uri.parse('$baseUrl/api/daily?day=$day'),
    );

    print('상태코드: ${response.statusCode}');
    print('응답: ${response.body}');

    return jsonDecode(response.body);
  }
}