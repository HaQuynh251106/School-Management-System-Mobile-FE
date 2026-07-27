import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models/app_user.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_vault.dart';

enum SessionStatus { booting, signedOut, signingIn, signedIn }

class AppSession extends ChangeNotifier {
  AppSession() {
    api = ApiClient(vault, onUnauthorized: _unauthorized);
  }

  final vault = TokenVault();
  late final ApiClient api;
  SessionStatus status = SessionStatus.booting;
  AppUser? user;
  List<Map<String, dynamic>> children = const [];
  String? selectedChildId;
  ThemeMode themeMode = ThemeMode.system;
  String? error;
  int notificationUnread = 0;
  int chatUnread = 0;
  Timer? _realtimeTimer;

  Future<void> bootstrap() async {
    final token = await vault.accessToken();
    if (token == null) {
      status = SessionStatus.signedOut;
      return;
    }
    try {
      user = AppUser.fromJson(await api.map('/me'));
      await _loadRoleContext();
      _startRealtime();
      status = SessionStatus.signedIn;
    } catch (_) {
      await vault.clear();
      status = SessionStatus.signedOut;
    }
  }

  Future<void> login(String username, String password) async {
    status = SessionStatus.signingIn;
    error = null;
    notifyListeners();
    try {
      final data = await api.post('/auth/login', {
        'username': username.trim(),
        'password': password,
      });
      await vault.save('${data['accessToken']}', '${data['refreshToken']}');
      final rawUser = data['user'] is Map
          ? (data['user'] as Map).cast<String, dynamic>()
          : await api.map('/me');
      user = AppUser.fromJson(rawUser);
      await _loadRoleContext();
      _startRealtime();
      status = SessionStatus.signedIn;
    } catch (exception) {
      error = _message(exception);
      status = SessionStatus.signedOut;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      final refresh = await vault.refreshToken();
      await api.post('/auth/logout', {'refreshToken': refresh});
    } catch (_) {
      // Token vẫn phải được xóa khi backend không khả dụng.
    }
    await vault.clear();
    _realtimeTimer?.cancel();
    user = null;
    children = const [];
    selectedChildId = null;
    notificationUnread = 0;
    chatUnread = 0;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  Future<void> selectChild(String childId) async {
    selectedChildId = childId;
    notifyListeners();
  }

  Future<void> _loadRoleContext() async {
    if (user?.role != 'PARENT') {
      children = const [];
      selectedChildId = null;
      return;
    }
    children = await api.list('/me/children');
    if (children.isNotEmpty) {
      final currentStillExists =
          children.any((child) => '${child['id']}' == selectedChildId);
      if (!currentStillExists) selectedChildId = '${children.first['id']}';
    }
  }

  Future<void> refreshUnreadCounts() async {
    if (status != SessionStatus.signedIn && user == null) return;
    try {
      final results = await Future.wait([
        api.map('/notifications/unread-count'),
        api.map('/chat/unread-count'),
      ]);
      final nextNotification =
          (results[0]['count'] as num?)?.toInt() ?? notificationUnread;
      final nextChat = (results[1]['count'] as num?)?.toInt() ?? chatUnread;
      if (nextNotification != notificationUnread || nextChat != chatUnread) {
        notificationUnread = nextNotification;
        chatUnread = nextChat;
        notifyListeners();
      }
    } catch (_) {
      // Mất kết nối tạm thời không làm gián đoạn phiên làm việc.
    }
  }

  void _startRealtime() {
    _realtimeTimer?.cancel();
    unawaited(refreshUnreadCounts());
    _realtimeTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => unawaited(refreshUnreadCounts()),
    );
  }

  void _unauthorized() {
    user = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  String _message(Object error) {
    final text = error.toString();
    if (text.contains('401')) return 'Tên đăng nhập hoặc mật khẩu không đúng.';
    if (text.contains('SocketException') || text.contains('connection')) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
    }
    return 'Đăng nhập không thành công. Vui lòng thử lại.';
  }
}
