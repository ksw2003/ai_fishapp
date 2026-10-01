import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fishinfo.dart';
import '../api/api_client.dart';

//물고기 목록 데이터(JSON) 불러오기
class FishService {
  static Future<List<Fish>> getFishList() async {
    final response =
    await ApiClient.get("/api/fishinfo",token: true);

    final data = jsonDecode(response.body);
    print(data);

    final List fishList =
        data["fishInfo"] ?? [];


    return fishList
        .map((e) => Fish.fromJson(e))
        .toList();
  }

  static Future<void> postFishList({
    required List<Map<String,dynamic>> fishes
  }) async{
    try{
      final body = {'fishes':fishes};
      final response = await ApiClient.post('/api/fishinfo',jsonEncode(body),token: true);
      print("성공");
    }catch(error){
      print(error);
      print("실패");
    }

  }
}