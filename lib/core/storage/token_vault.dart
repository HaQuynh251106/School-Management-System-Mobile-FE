import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenVault {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  Future<String?> accessToken() => _storage.read(key: 'access_token_v2');

  Future<String?> refreshToken() => _storage.read(key: 'refresh_token_v2');

  Future<void> save(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: 'access_token_v2', value: access),
      _storage.write(key: 'refresh_token_v2', value: refresh),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: 'access_token_v2'),
      _storage.delete(key: 'refresh_token_v2'),
    ]);
  }
}
