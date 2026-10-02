import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const storage = FlutterSecureStorage();

  static Future<void> saveTokens(
      String accessToken,
      String refreshToken,
      ) async {
    await storage.write(
      key: 'accessToken',
      value: accessToken,
    );

    await storage.write(
      key: 'refreshToken',
      value: refreshToken,
    );
  }

  // 사용자 ID 저장
  static Future<void> saveUserId(int userId) async {
    await storage.write(
      key: 'user_id',
      value: userId.toString(),
    );
  }

  // 사용자 ID 조회
  static Future<int?> getUserId() async {
    final value = await storage.read(
      key: 'user_id',
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  // 사용자 ID 삭제
  static Future<void> deleteUserId() async {
    await storage.delete(
      key: 'user_id',
    );
  }

  static Future<void> savedeviceId(String deviceId) async {
    await storage.write(
      key: 'device_id',
      value: deviceId,
    );
  }

  static Future<String?> getdeviceId() async {
    return await storage.read(
      key: 'device_id',
    );
  }

  static Future<void> deleteDeviceId() async {
    await storage.delete(
      key: 'device_id',
    );
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(
      key: 'accessToken',
    );
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(
      key: 'refreshToken',
    );
  }

  static Future<void> deleteTokens() async {
    await storage.delete(
      key: 'accessToken',
    );

    await storage.delete(
      key: 'refreshToken',
    );
  }
}