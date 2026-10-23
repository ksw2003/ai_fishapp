import 'dart:convert';

import '../models/alert.dart';
import '../api/api_client.dart';

class AlertService {

  static Future<List<AlertModel>> getAlerts() async {

    final response =
<<<<<<< HEAD
    await ApiClient.get('/api/tank/alert',token:true);
=======
    await ApiClient.get('/api/tank/alert', token: true);
>>>>>>> ba73d0ea909390573f9f9e5de9e2119e627a3684

    if (response.statusCode != 200) {
      throw Exception('알림 조회 실패');
    }

    print(response.body);

    final List data =
    jsonDecode(utf8.decode(response.bodyBytes));
    for (final e in data) {
      String? message;
      if(e['type'] == 'waterquality'){
        message = '수질이 안좋아보입니다.';
      }else if(e['type'] == 'temp'){
        if(e['status'] == 'low'){
          message = '온도가 낮습니다.';
        }else{
          message = '온도가 높습니다.';
        }
      }
      e['message'] = message;
      print(e);
    }
    return data
        .map((e) => AlertModel.fromJson(e))
        .toList();
  }
}