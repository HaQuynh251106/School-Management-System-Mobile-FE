// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

class WebTokenPersistence {
  static const prefix = 'sse_mobile_v2.';
  static const refreshKey = 'refresh_token_v2';

  Future<String?> read(String key) async {
    if (key == refreshKey) return null;
    return html.window.localStorage['$prefix$key'];
  }

  Future<void> write(String key, String value) async {
    if (key == refreshKey) return;
    html.window.localStorage['$prefix$key'] = value;
  }

  Future<void> delete(String key) async {
    html.window.localStorage.remove('$prefix$key');
  }
}
