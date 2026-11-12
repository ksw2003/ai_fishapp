import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SensorApi {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Stream<Map<String, dynamic>> connect(String account) async* {
    while (true) {
      final client = http.Client();

      try {
        debugPrint('[SSE] 연결 요청 시작');

        // 재연결할 때마다 최신 토큰 가져오기
        final token = await TokenStorage.getAccessToken();

        final request = http.Request(
          'GET',
          Uri.parse('$baseUrl$account'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'text/event-stream';

        final response = await client.send(request);

        if (response.statusCode != 200) {
          throw Exception(
            'SSE 연결 실패: HTTP ${response.statusCode}',
          );
        }

        debugPrint('[SSE] 연결 성공');

        StringBuffer dataBuffer = StringBuffer();

        // SSE 데이터 수신
        await for (final line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {

          // 빈 줄이면 하나의 SSE 이벤트 종료
          if (line.isEmpty) {
            final jsonString = dataBuffer.toString();

            if (jsonString.isNotEmpty) {
              try {
                final data = jsonDecode(jsonString);

                if (data is Map<String, dynamic>) {
                  yield data;
                }
              } catch (e) {
                debugPrint('[SSE] JSON 변환 오류: $e');
              }
            }

            dataBuffer.clear();
          }
          // data 필드만 처리
          else if (line.startsWith('data:')) {
            if (dataBuffer.isNotEmpty) {
              dataBuffer.write('\n');
            }

            String value = line.substring(5);

            if (value.startsWith(' ')) {
              value = value.substring(1);
            }

            dataBuffer.write(value);
          }
        }

        // 스트림이 정상 종료된 경우에도 재연결
        debugPrint('[SSE] 연결 종료됨');

      } catch (e) {
        debugPrint('[SSE] 연결 오류: $e');
      } finally {
        client.close();
      }

      // 3초 후 재연결
      debugPrint('[SSE] 3초 후 재연결 시도');

      await Future.delayed(const Duration(seconds: 3));
    }
  }
}