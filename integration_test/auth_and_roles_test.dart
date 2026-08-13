import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sse_mobile/app.dart';
import 'package:sse_mobile/core/config/env.dart';
import 'package:sse_mobile/core/di/service_locator.dart';
import 'package:sse_mobile/core/storage/token_storage.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const _academicStaffPassword = String.fromEnvironment(
  'E2E_ACADEMIC_STAFF_PASSWORD',
);
const _accountantPassword = String.fromEnvironment('E2E_ACCOUNTANT_PASSWORD');
const _teacherPassword = String.fromEnvironment('E2E_TEACHER_PASSWORD');
const _studentPassword = String.fromEnvironment('E2E_STUDENT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const runLive = bool.fromEnvironment('RUN_LIVE_INTEGRATION');

  testWidgets('API đăng nhập trả đúng đủ sáu vai trò', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    expect(
      [
        _adminPassword,
        _academicStaffPassword,
        _accountantPassword,
        _teacherPassword,
        _studentPassword,
        _parentPassword,
      ].every((value) => value.isNotEmpty),
      isTrue,
      reason: 'Thiếu biến E2E_*_PASSWORD',
    );
    final accounts = <(String, String, String)>[
      ('admin', _adminPassword, 'ADMIN'),
      ('giaovu', _academicStaffPassword, 'ACADEMIC_STAFF'),
      ('ketoan', _accountantPassword, 'ACCOUNTANT'),
      ('gv.nguyenminh', _teacherPassword, 'TEACHER'),
      ('hs.nguyenminhan', _studentPassword, 'STUDENT'),
      ('ph.nguyenvanhung', _parentPassword, 'PARENT'),
    ];

    for (final account in accounts) {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': account.$1, 'password': account.$2},
      );
      expect(
        response.statusCode,
        200,
        reason: 'Đăng nhập thất bại: ${account.$1}',
      );
      final user = response.data!['user'] as Map<String, dynamic>;
      expect(user['role'], account.$3);
      expect(response.data!['accessToken'], isNotEmpty);
    }
  }, skip: !runLive);

  testWidgets('học sinh đăng nhập qua giao diện và mở đúng trang chủ', (
    tester,
  ) async {
    await initializeDateFormatting('vi_VN');
    FlutterSecureStorage.setMockInitialValues({});
    await setupServiceLocator();
    await sl<TokenStorage>().clearAll();
    final authBloc = sl<AuthBloc>()..add(const AuthStarted());

    await tester.pumpWidget(
      BlocProvider.value(value: authBloc, child: const SseApp()),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), 'hs.nguyenminhan');
    await tester.enterText(fields.at(1), _studentPassword);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));

    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('Thời khóa biểu').evaluate().isNotEmpty) break;
    }
    expect(find.text('Thời khóa biểu'), findsOneWidget);

    await authBloc.close();
  }, skip: !runLive);
}
