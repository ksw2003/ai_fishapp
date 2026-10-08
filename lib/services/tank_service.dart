import 'dart:convert';
import '../api/api_client.dart';
import 'token_storage.dart';

class TankService {
  static Future<Map<String, dynamic>> getTankSetting() async {
    final tankId = await TokenStorage.getdeviceId();

    final response = await ApiClient.get(
      '/api/tank/setting/$tankId',
      token: true,
    );

    return jsonDecode(response.body);
  }
}