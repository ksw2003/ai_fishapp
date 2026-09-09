import 'dart:convert';
import 'package:ai_fishapp/api/api_client.dart';

class DiaryApi {
  static Future<Map<String, dynamic>?> getDiary(
      DateTime date) async {

    final day =
        '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

    final response = await ApiClient.get(
      '/api/daily?day=$day',
      token: true,
    );

    print('상태코드=${response.statusCode}');
    print('응답=<<<${response.body}>>>');

    return jsonDecode(response.body);

    return null;
  }
}