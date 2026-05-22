import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_keyAccess, accessToken);
    await _prefs.setString(_keyRefresh, refreshToken);
  }

  Future<String?> getAccessToken() async => _prefs.getString(_keyAccess);
  Future<String?> getRefreshToken() async => _prefs.getString(_keyRefresh);

  Future<void> clearAll() async {
    await _prefs.remove(_keyAccess);
    await _prefs.remove(_keyRefresh);
  }
}
