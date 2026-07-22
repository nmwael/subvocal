import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'opensubtitles_token';
  static const _usernameKey = 'opensubtitles_username';
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token, {String? username}) async {
    await _storage.write(key: _key, value: token);
    if (username != null) {
      await _storage.write(key: _usernameKey, value: username);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _usernameKey);
  }
}
