import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/auth/data/auth_repository.dart';
import 'package:sse_mobile/features/auth/data/models/user_model.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.loginUser, this.restoredUser});

  final UserModel loginUser;
  final UserModel? restoredUser;
  bool loggedOut = false;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async => loginUser;

  @override
  Future<UserModel?> tryRestoreSession() async => restoredUser;

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserModel _user(String role) => UserModel(
  id: 'u-$role',
  username: role.toLowerCase(),
  fullName: role,
  role: role,
  status: 'ACTIVE',
  passwordChangeRequired: false,
);

void main() {
  test('từ chối và xóa phiên khi Admin đăng nhập Mobile', () async {
    final repository = _FakeAuthRepository(loginUser: _user('ADMIN'));
    final bloc = AuthBloc(repository: repository);
    addTearDown(bloc.close);

    final result = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthLoginFailure>().having(
          (state) => state.message,
          'message',
          contains('chỉ sử dụng trên phiên bản Web'),
        ),
      ]),
    );
    bloc.add(const AuthLoginRequested(username: 'admin', password: 'secret'));

    await result;
    expect(repository.loggedOut, isTrue);
  });

  test('xóa phiên Admin đã lưu khi khởi động lại Mobile', () async {
    final repository = _FakeAuthRepository(
      loginUser: _user('ADMIN'),
      restoredUser: _user('ADMIN'),
    );
    final bloc = AuthBloc(repository: repository);
    addTearDown(bloc.close);

    final result = expectLater(
      bloc.stream,
      emitsInOrder([isA<AuthLoading>(), isA<AuthUnauthenticated>()]),
    );
    bloc.add(const AuthStarted());

    await result;
    expect(repository.loggedOut, isTrue);
  });

  test('giữ nguyên đăng nhập cho ba vai trò Mobile', () async {
    for (final role in ['TEACHER', 'STUDENT', 'PARENT']) {
      final repository = _FakeAuthRepository(loginUser: _user(role));
      final bloc = AuthBloc(repository: repository);

      final result = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.role,
            'role',
            role,
          ),
        ]),
      );
      bloc.add(const AuthLoginRequested(username: 'user', password: 'secret'));

      await result;
      expect(repository.loggedOut, isFalse);
      await bloc.close();
    }
  });
}
