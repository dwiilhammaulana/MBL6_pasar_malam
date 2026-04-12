import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyToken = 'auth_token';

  static Future<void> saveToken(String token) async =>
      _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() async =>
      _storage.read(key: _keyToken);

  static Future<void> clearAll() async =>
      _storage.deleteAll();
}