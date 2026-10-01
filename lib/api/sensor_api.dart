import 'dart:convert';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;

class SensorApi {
  Stream<Map<String, dynamic>> connect(String accout) async* {
    final token = await TokenStorage.getAccessToken();
    final request = http.Request(
      'GET',
      Uri.parse(
        'http://13.239.199.189:3000$accout',
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'text/event-stream';

    final response =
    await http.Client().send(request);

    await for (final chunk in response.stream
        .transform(utf8.decoder)) {

      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final jsonString =
          line.substring(6);
          yield jsonDecode(jsonString);
        }
      }
    }
  }
}