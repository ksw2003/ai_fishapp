
import 'dart:convert';

import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart' show XFile;

//http://192.168.56.1:3000
//127.0.0.1:3000
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
  List<XFile>? images,
  String imageField = 'images',
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

  if (images != null) {
    for (final image in images) {

      final multipartFile =
          await http.MultipartFile.fromPath(
        imageField,
        image.path,
        contentType:
            getImageContentType(image.path),
      );

      request.files.add(multipartFile);
    }
  }

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
        streamedResponse,
      );

  if (token && !retry && response.statusCode == 401) {
    final data = jsonDecode(response.body);

    if (data['code'] == 'ACCESS_TOKEN_EXPIRED') {
      final success = await _refreshtoken();

      if (success) {
        return postMultipart(
          endpoint,
          fields: fields,
          images: images,
          imageField: imageField,
          token: true,
          retry: true,
        );
      }
    }
  }

  return response;
}

static MediaType getImageContentType(String path) {
  final extension = path.split('.').last.toLowerCase();

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');

    case 'png':
      return MediaType('image', 'png');

    case 'webp':
      return MediaType('image', 'webp');

    default:
      throw Exception('지원하지 않는 이미지 형식입니다.');
  }
}

}