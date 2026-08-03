import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'web_token_persistence.dart';

class TokenVault {
  static const accessKey = 'access_token_v2';
  static const refreshKey = 'refresh_token_v2';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _web = WebTokenPersistence();

  Future<String?> accessToken() => _read(accessKey);

  Future<String?> refreshToken() => _read(refreshKey);

  Future<void> save(String access, String refresh) async {
    await Future.wait([
      _secureWrite(accessKey, access),
      _secureWrite(refreshKey, refresh),
      _web.write(accessKey, access),
      _web.write(refreshKey, refresh),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _secureDelete(accessKey),
      _secureDelete(refreshKey),
      _web.delete(accessKey),
      _web.delete(refreshKey),
    ]);
  }

  Future<String?> _read(String key) async {
    try {
      final secureValue = await _storage.read(key: key);
      if (secureValue != null && secureValue.isNotEmpty) return secureValue;
    } catch (_) {
      // Một số trình duyệt không khôi phục được khóa WebCrypto sau reload.
    }
    return _web.read(key);
  }

  Future<void> _secureWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Bản Web đã có localStorage dự phòng; mobile vẫn dùng kho bảo mật.
    }
  }

  Future<void> _secureDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Luôn tiếp tục xóa bản dự phòng để đăng xuất hoàn toàn.
    }
  }
}
