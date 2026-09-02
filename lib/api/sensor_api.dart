import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorApi {
  Stream<Map<String, dynamic>> connect() async* {
    final request = http.Request(
      'GET',
      Uri.parse(
        'http://192.168.45.165:3000/api/tank/data',
      ),
    );

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