
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiaryService {
  // .env에서 API 서버 주소 가져오기
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

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
