
import 'dart:convert';

import 'package:ai_fishapp/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


class _MultipartFileData {
  final String field;
  final String filename;
  final List<int> bytes;
  final MediaType contentType;

  _MultipartFileData({
    required this.field,
    required this.filename,
    required this.bytes,
    required this.contentType,
  });
}

class ApiClient {
  // .env에서 AWS Node.js 백엔드 주소 가져오기
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  // 액세스 토큰 갱신
  static Future<bool> _refreshtoken() async {
    final exrefreshtoken = await TokenStorage.getRefreshToken();

    if (exrefreshtoken == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/refresh"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refreshToken": exrefreshtoken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data["accesstoken"];

      if (newAccessToken == null) {
        return false;
      }

      await TokenStorage.saveTokens(
        data["accesstoken"],
        data["refreshtoken"],
      );

      return true;
    }

    return false;
  }

  // GET 요청
  static Future<http.Response> get(
    String endpoint, {
    bool token = false,
    bool retry = false,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    print(token);

    if (token) {
      final accesstoken = await TokenStorage.getAccessToken();

      if (accesstoken != null) {
        headers["authorization"] = "Bearer $accesstoken";
      }
    }


    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );

    if (token && !retry && response.statusCode == 401) {
      final data = jsonDecode(response.body);

      if (data["code"] == "ACCESS_TOKEN_EXPIRED") {
        final success = await _refreshtoken();

        if (success) {
          return get(
            endpoint,
            token: true,
            retry: true,
          );
        }
      }
    }

    return response;
  }

  // POST 요청
  static Future<http.Response> post(
    String endpoint,
    String? body, {
    token = false,
    retry = false,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    print(baseUrl);
    if (token) {
      final accesstoken = await TokenStorage.getAccessToken();

      if (accesstoken != null) {
        headers["authorization"] = "Bearer $accesstoken";
      }
    }



    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
      body: body,
    );

    if (token && !retry && response.statusCode == 401) {
      final data = jsonDecode(response.body);

      if (data["code"] == "ACCESS_TOKEN_EXPIRED") {
        final success = await _refreshtoken();

        if (success) {
          return post(
            endpoint,
            body,
            token: true,
            retry: true,
          );
        }
      }
    }

    return response;
  }

  // DELETE 요청
  static Future<http.Response> delete(
    int postId,
    String endpoint, {
    token = false,
    retry = false,
  }) async {
    final accesstoken = await TokenStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint$postId"),
      headers: {
        "authorization": "Bearer $accesstoken",
      },
    );

    if (token && !retry && response.statusCode == 401) {
      final data = jsonDecode(response.body);

      if (data["code"] == "ACCESS_TOKEN_EXPIRED") {
        final success = await _refreshtoken();

        if (success) {
          return delete(
            postId,
            endpoint,
            token: true,
            retry: true,
          );
        }
      }
    }

    return response;
  }

  // 이미지 및 파일 업로드
  static Future<http.Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool token = false,
    bool retry = false,
  }) async {

    // 파일 데이터를 최초 요청 전에 메모리에 보관
    final savedFiles = <_MultipartFileData>[];

    if (files != null) {
      for (final file in files) {
        final bytes = await file.finalize().toBytes();

        final filename = file.filename ?? 'image.jpg';
        final extension = filename.split('.').last.toLowerCase();

        final contentType = switch (extension) {
          'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
          'png' => MediaType('image', 'png'),
          'webp' => MediaType('image', 'webp'),
          _ => throw Exception('지원하지 않는 이미지 형식입니다: $filename'),
        };

        savedFiles.add(
          _MultipartFileData(
            field: file.field,
            filename: filename,
            bytes: bytes,
            contentType: contentType,
          ),
        );
      }
    }

    // 실제 HTTP 요청을 실행하는 내부 함수
    Future<http.Response> sendRequest() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      if (token) {
        final accessToken = await TokenStorage.getAccessToken();

        if (accessToken != null) {
          request.headers['authorization'] = 'Bearer $accessToken';
        }
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      // 매 요청마다 새로운 MultipartFile 생성
      for (final file in savedFiles) {
        request.files.add(
          http.MultipartFile.fromBytes(
            file.field,
            file.bytes,
            filename: file.filename,
            contentType: file.contentType,
          ),
        );
      }

      final streamedResponse = await request.send();

      return http.Response.fromStream(streamedResponse);
    }

    // 최초 요청
    var response = await sendRequest();

    // Access Token 만료 처리
    if (token && !retry && response.statusCode == 401) {
      final data = jsonDecode(response.body);

      if (data['code'] == 'ACCESS_TOKEN_EXPIRED') {
        final success = await _refreshtoken();

        if (success) {
          // 갱신된 토큰과 새 MultipartFile로 재요청
          response = await sendRequest();
        }
      }
    }

    return response;
  }
}