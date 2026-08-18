import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorApi {
  Stream<Map<String, dynamic>> connect() async* {
    final request = http.Request(
      'GET',
      Uri.parse(
        'http://192.168.45.161:3000/api/tank/data',
      ),
    );

    final response =
    await http.Client().send(request);

    if (response.statusCode != 200) {
      final body =
      await response.stream.bytesToString();

      try {
        final json =
        jsonDecode(body);

        throw Exception(
          json['message'],
        );
      } catch (_) {
        throw Exception(
          '서버 연결 실패',
        );
      }
    }

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