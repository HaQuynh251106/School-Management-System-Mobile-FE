import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Quản lý giao diện dùng chung cho toàn ứng dụng và lưu lựa chọn trên thiết bị.
class ThemeController extends ChangeNotifier {
  ThemeController(this._storage);

  static const _storageKey = 'theme_mode';
  final FlutterSecureStorage _storage;
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    final saved = await _storage.read(key: _storageKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await _storage.write(key: _storageKey, value: mode.name);
    notifyListeners();
  }

  Future<void> toggle(Brightness platformBrightness) {
    final currentlyDark = _mode == ThemeMode.dark ||
        (_mode == ThemeMode.system && platformBrightness == Brightness.dark);
    return setMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
