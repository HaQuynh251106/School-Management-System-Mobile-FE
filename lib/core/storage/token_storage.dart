import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  // The browser preview is only a local development surface. Keeping tokens
  // in memory avoids Web Crypto incompatibilities while Android/iOS continue
  // to use the operating system's secure storage.
  String? _webAccessToken;
  String? _webRefreshToken;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      _webAccessToken = accessToken;
      _webRefreshToken = refreshToken;
      return;
    }
    await _storage.write(key: _keyAccess, value: accessToken);
    await _storage.write(key: _keyRefresh, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) return _webAccessToken;
    return _storage.read(key: _keyAccess);
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) return _webRefreshToken;
    return _storage.read(key: _keyRefresh);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      _webAccessToken = null;
      _webRefreshToken = null;
      return;
    }
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }
}
