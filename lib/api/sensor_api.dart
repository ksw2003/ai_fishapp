
import 'dart:convert';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SensorApi {
  // .env에서 API 서버 주소 가져오기
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Stream<Map<String, dynamic>> connect(String accout) async* {
    final token = await TokenStorage.getAccessToken();

    final request = http.Request(
      'GET',
      Uri.parse('$baseUrl$accout'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'text/event-stream';

    final client = http.Client();

    try {
      final response = await client.send(request);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonString = line.substring(6);
            yield jsonDecode(jsonString);
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
