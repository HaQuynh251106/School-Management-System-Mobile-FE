import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  test('notification and chat inboxes use the same API as Web', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final data = switch (options.path) {
            '/notifications/page' => {
              'items': [
                {'id': 'n-1', 'title': 'Thông báo mới'},
              ],
            },
            '/chat/messages' => [
              {'id': 'm-1', 'content': 'Xin chào'},
            ],
            '/me/notification-preferences' => <Map<String, Object>>[],
            _ => <String, Object>{'ok': true},
          };
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: data),
          );
        },
      ),
    );
    final api = ApiService(dio);

    final notifications = await api.notifications(page: 2, size: 30);
    final messages = await api.chatMessages('teacher-1', page: 1, size: 40);
    await api.markAllNotificationsRead();
    await api.notificationPreferences();
    await api.updateNotificationPreference('EXAM', true);

    expect(notifications.single['id'], 'n-1');
    expect(messages.single['id'], 'm-1');
    expect(requests[0].path, '/notifications/page');
    expect(requests[0].queryParameters, containsPair('page', 2));
    expect(requests[0].queryParameters, containsPair('size', 30));
    expect(requests[0].queryParameters, containsPair('read', 'ALL'));
    expect(requests[1].path, '/chat/messages');
    expect(
      requests[1].queryParameters,
      containsPair('withUserId', 'teacher-1'),
    );
    expect(requests[2].path, '/notifications/read-all');
    expect(requests[3].path, '/me/notification-preferences');
    expect(requests[4].path, '/me/notification-preferences');
    expect(_body(requests[4]), {'channel': 'EXAM', 'enabled': true});
  });
}

Map<String, dynamic> _body(RequestOptions request) {
  final data = request.data;
  if (data is String) {
    return (jsonDecode(data) as Map).cast<String, dynamic>();
  }
  return (data as Map).cast<String, dynamic>();
}
