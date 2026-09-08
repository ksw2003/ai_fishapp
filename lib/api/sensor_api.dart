import 'dart:convert';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;
import '../models/sensor.dart';
import 'api_client.dart';

class SensorApi {
  Stream<Map<String, dynamic>> connect() async* {
    final token = await TokenStorage.getAccessToken();
    final request = http.Request(
      'GET',
      Uri.parse(
        'http://192.168.56.1:3000/api/tank/data',
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