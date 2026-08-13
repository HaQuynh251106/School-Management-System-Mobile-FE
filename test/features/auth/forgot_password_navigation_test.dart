import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/router/app_router.dart';
import 'package:sse_mobile/features/auth/data/auth_repository.dart';
import 'package:sse_mobile/features/auth/data/models/user_model.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async => {
        'deliveryChannel': 'EMAIL',
      };

  @override
  Future<UserModel?> tryRestoreSession() async => null;

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  testWidgets('nút Về đăng nhập đóng dialog và về trang login', (tester) async {
    final authBloc = AuthBloc(repository: _FakeAuthRepository());
    final router = AppRouter(authBloc);
    addTearDown(() async {
      router.dispose();
      await authBloc.close();
    });

    authBloc.add(const AuthStarted());
    await authBloc.stream.firstWhere((state) => state is AuthUnauthenticated);

    await tester.pumpWidget(
      BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: router.config),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();
    expect(find.text('Gửi link đặt lại'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      'user@example.com',
    );
    await tester.tap(find.text('Gửi link đặt lại'));
    await tester.pumpAndSettle();

    expect(find.text('Đã tiếp nhận yêu cầu'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Về đăng nhập').last);
    await tester.pumpAndSettle();

    expect(find.text('Đã tiếp nhận yêu cầu'), findsNothing);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });

  testWidgets('deep link reset có token và luôn có đường về đăng nhập',
      (tester) async {
    final authBloc = AuthBloc(repository: _FakeAuthRepository());
    final router = AppRouter(authBloc);
    addTearDown(() async {
      router.dispose();
      await authBloc.close();
    });

    authBloc.add(const AuthStarted());
    await authBloc.stream.firstWhere((state) => state is AuthUnauthenticated);
    router.config.go('/reset-password?token=one-time-token');

    await tester.pumpWidget(
      BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: router.config),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đặt lại mật khẩu'), findsWidgets);
    expect(find.text('Mã đặt lại mật khẩu'), findsNothing);
    expect(find.text('Về đăng nhập'), findsOneWidget);
    await tester.tap(find.text('Về đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });
}
