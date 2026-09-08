
import 'dart:convert';

import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // 백엔드 주소
  static const String baseUrl = "http://192.168.56.1:3000";

  static Future<bool> _refreshtoken() async{
    final exrefreshtoken = await TokenStorage.getRefreshToken();
    if(exrefreshtoken == null){
      return false;
    }
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/refresh"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refreshToken": exrefreshtoken,
      })
    );
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      final newAccessToken = data["accesstoken"];

      if (newAccessToken == null) {
        return false;
      }
      await TokenStorage.saveTokens(data["accesstoken"], data["refreshtoken"]);
      return true;
    }
    return false;
  }

  static Future<http.Response> get(String endpoint,{bool token = false, bool retry = false}) async {
    final headers = {
      "Content-Type": "application/json"
    };
    print(token);
    if(token){
      final accesstoken = await TokenStorage.getAccessToken();
      if(accesstoken!=null){
        headers["authorization"] = "Bearer $accesstoken";
      }
    }

    print(headers);
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );

    if(token&&!retry&&response.statusCode == 401){
      final data = jsonDecode(response.body);
      if(data["code"] == "ACCESS_TOKEN_EXPIRED"){
        final success = await _refreshtoken();
        if(success){
          return get(endpoint,token:true,retry: true);
        }
      }
    }

    return response;
  }

  static Future<http.Response> post(
      String endpoint,
      String? body,
      {token = false,
      retry = false}
      ) async {
        final headers = {
      "Content-Type": "application/json"
    };
    if(token){
      final accesstoken = await TokenStorage.getAccessToken();
      if(accesstoken!=null){
        headers["authorization"] = "Bearer $accesstoken";
      }
    }
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
      body: body
    );

    if(token&&!retry&&response.statusCode == 401){
      final data = jsonDecode(response.body);
      if(data["code"] == "ACCESS_TOKEN_EXPIRED"){
        final success = await _refreshtoken();
        if(success){
          return post(endpoint,body,token:true,retry: true);
        }
      }
    }

    return response;
  }

  static Future<http.Response> delete(int postId,String endpoint,{token = false,retry = false}) async{
    final accesstoken = await TokenStorage.getAccessToken();
    final response = await http.delete(
      Uri.parse(
        "$baseUrl$endpoint$postId",
      ),
      headers: {"authorization":"Bearer $accesstoken"} 
    );
    if(token && !retry && response.statusCode == 401){
      final data = jsonDecode(response.body);
        if(data["code"] == "ACCESS_TOKEN_EXPIRED"){
          final success = await _refreshtoken();
          if(success){
            return delete(postId,endpoint,token:true,retry: true);
          }
      }
    }
    return response;
  }

  static Future<http.Response> postMultipart(
  String endpoint, {
  Map<String, String>? fields,
  List<http.MultipartFile>? files,
  bool token = false,
  bool retry = false,
}) async {
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

  if (files != null) {
    request.files.addAll(files);
  }

  final streamedResponse = await request.send();

  // StreamedResponse → Response 변환
  final response = await http.Response.fromStream(streamedResponse);

  if (token && !retry && response.statusCode == 401) {
    final data = jsonDecode(response.body);

    if (data['code'] == 'ACCESS_TOKEN_EXPIRED') {
      final success = await _refreshtoken();

      if (success) {
        return postMultipart(
          endpoint,
          fields: fields,
          files: files,
          token: true,
          retry: true,
        );
      }
    }
  }

  return response;
}


}