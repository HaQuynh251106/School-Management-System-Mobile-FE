import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_identity_api/sse_identity_api.dart' as identity;
import 'package:sse_mobile/features/auth/data/auth_api.dart';

void main() {
  test('generated identity models serialize login and roles correctly', () {
    final request = identity.LoginRequest(
      username: 'admin',
      password: 'Admin123@@',
    );
    final user = identity.User.fromJson({
      'id': 'u-admin',
      'username': 'admin',
      'fullName': 'Quan tri',
      'role': 'ADMIN',
      'status': 'ACTIVE',
      'passwordChangeRequired': false,
    });

    expect(request.toJson(), {'username': 'admin', 'password': 'Admin123@@'});
    expect(user.role, identity.UserRoleEnum.ADMIN);
    expect(user.status, identity.UserStatusEnum.ACTIVE);
    expect(user.toJson()['role'], 'ADMIN');
  });

  test('AuthApi uses typed identity endpoints and payloads', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    final requests = <RequestOptions>[];
    dio.httpClientAdapter = _IdentityAdapter(requests);
    final api = AuthApi(dio);

    final login = await api.login(username: 'admin', password: 'Admin123@@');
    final me = await api.getMe();
    final refreshed = await api.refresh('refresh-1');
    await api.forgotPassword('admin@example.test');
    await api.logout('refresh-2');

    expect(login.accessToken, 'access-1');
    expect(login.user.role, identity.UserRoleEnum.ADMIN);
    expect(me.role, 'ADMIN');
    expect(refreshed.refreshToken, 'refresh-new');
    expect(requests.map((request) => request.path), [
      '/auth/login',
      '/me',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/logout',
    ]);
    expect(jsonDecode(requests[0].data as String), {
      'username': 'admin',
      'password': 'Admin123@@',
    });
    expect(jsonDecode(requests[2].data as String), {
      'refreshToken': 'refresh-1',
    });
  });
}

class _IdentityAdapter implements HttpClientAdapter {
  _IdentityAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch (options.path) {
      '/auth/login' => {
        'accessToken': 'access-1',
        'refreshToken': 'refresh-1',
        'expiresIn': 900,
        'user': _userJson,
      },
      '/auth/refresh' => {
        'accessToken': 'access-new',
        'refreshToken': 'refresh-new',
        'expiresIn': 900,
      },
      '/auth/forgot-password' => {'ok': true, 'message': 'Da tiep nhan'},
      '/auth/logout' => {'ok': true},
      '/me' => _userJson,
      _ => throw StateError('Unexpected request ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _userJson = {
  'id': 'u-admin',
  'username': 'admin',
  'fullName': 'Quan tri',
  'role': 'ADMIN',
  'status': 'ACTIVE',
  'passwordChangeRequired': false,
};
