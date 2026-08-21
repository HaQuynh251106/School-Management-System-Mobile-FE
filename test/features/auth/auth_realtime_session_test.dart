import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/realtime_service.dart';
import 'package:sse_mobile/features/auth/data/auth_repository.dart';
import 'package:sse_mobile/features/auth/data/models/user_model.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.user);

  final UserModel user;
  int logoutCalls = 0;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async => user;

  @override
  Future<UserModel?> tryRestoreSession() async => user;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeRealtimeService extends RealtimeService {
  _FakeRealtimeService() : super(Dio());

  int restartCalls = 0;
  int disconnectCalls = 0;

  @override
  Future<void> restartForAuthenticatedSession() async {
    restartCalls++;
  }

  @override
  void disconnect() {
    disconnectCalls++;
  }
}

void main() {
  const user = UserModel(
    id: 'u-teacher',
    username: 'teacher',
    fullName: 'Giáo viên',
    role: 'TEACHER',
    status: 'ACTIVE',
    passwordChangeRequired: false,
  );

  test('khôi phục phiên mở lại realtime đúng một lần', () async {
    final realtime = _FakeRealtimeService();
    final bloc = AuthBloc(
      repository: _FakeAuthRepository(user),
      realtime: realtime,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthStarted());
    await bloc.stream.firstWhere((state) => state is AuthAuthenticated);

    expect(realtime.restartCalls, 1);
  });

  test(
    'login mở realtime mới và logout đóng stream trước khi xóa phiên',
    () async {
      final realtime = _FakeRealtimeService();
      final repository = _FakeAuthRepository(user);
      final bloc = AuthBloc(repository: repository, realtime: realtime);
      addTearDown(bloc.close);

      bloc.add(
        const AuthLoginRequested(username: 'teacher', password: 'secret'),
      );
      await bloc.stream.firstWhere((state) => state is AuthAuthenticated);
      expect(realtime.restartCalls, 1);

      bloc.add(const AuthLogoutRequested());
      await bloc.stream.firstWhere((state) => state is AuthUnauthenticated);

      expect(realtime.disconnectCalls, 1);
      expect(repository.logoutCalls, 1);
    },
  );
}
