import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fishinfo.dart';
import '../api/api_client.dart';

//물고기 목록 데이터(JSON) 불러오기
class FishService {
  static Future<List<Fish>> getFishList() async {
    final response =
    await ApiClient.get("/api/fishinfo/data");

    final data = jsonDecode(response.body);

    final List fishList =
        data["fishInfo"] ?? [];

    return fishList
        .map((e) => Fish.fromJson(e))
        .toList();
  }


  //새 물고기 등록
  static Future<void> addFish({
    required String fishType,
    required int fishCount,
  }) async {
    await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/fishinfo/new",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "newFish": {
          "fish_type": fishType,
          "fish_count": fishCount,
        }
      }),
    );
  }

  //물고기 정보 수정 예: /api/fish/3 : 3번 물고기 수정
  static Future<void> updateFish({
    required int fishId,
    required String fishType,
    required int fishCount,
  }) async {
    await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/fishinfo/$fishId",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fish_type": fishType,
        "fish_count": fishCount,
      }),
    );
  }

  //물고기 삭제
  static Future<void> deleteFish(
      int fishId) async {
    await http.delete(
      Uri.parse(
        "${ApiClient.baseUrl}/api/fishinfo/$fishId",
      ),
    );
  }
}