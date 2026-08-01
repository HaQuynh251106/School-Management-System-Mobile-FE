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
import 'package:sse_mobile/core/network/api_service.dart';
import 'package:sse_mobile/core/storage/token_storage.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const _academicStaffPassword =
    String.fromEnvironment('E2E_ACADEMIC_STAFF_PASSWORD');
const _accountantPassword = String.fromEnvironment('E2E_ACCOUNTANT_PASSWORD');
const _teacherPassword = String.fromEnvironment('E2E_TEACHER_PASSWORD');
const _studentPassword = String.fromEnvironment('E2E_STUDENT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const runLive = bool.fromEnvironment('RUN_LIVE_INTEGRATION');

  test('mobile API đăng nhập đúng đủ sáu vai trò', () async {
    final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    expect(
        [
          _adminPassword,
          _academicStaffPassword,
          _accountantPassword,
          _teacherPassword,
          _studentPassword,
          _parentPassword
        ].every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến E2E_*_PASSWORD');
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
      expect(response.statusCode, 200);
      expect(
          (response.data!['user'] as Map<String, dynamic>)['role'], account.$3);
      expect(response.data!['accessToken'], isNotEmpty);
    }
  }, skip: !runLive);

  testWidgets('mobile UI đăng nhập học sinh và điều hướng đúng vai trò',
      (tester) async {
    await _loginAndExpect(
        tester, 'hs.nguyenminhan', _studentPassword, 'Thời khóa biểu');
  }, skip: !runLive);

  testWidgets('mobile UI mở đúng không gian Giáo vụ', (tester) async {
    await _loginAndExpect(
        tester, 'giaovu', _academicStaffPassword, 'Trung tâm Giáo vụ');
  }, skip: !runLive);

  testWidgets('mobile UI mở đúng không gian Kế toán', (tester) async {
    await _loginAndExpect(
        tester, 'ketoan', _accountantPassword, 'Trung tâm Kế toán');
  }, skip: !runLive);
}

Future<void> _loginAndExpect(
  WidgetTester tester,
  String username,
  String password,
  String expectedText,
) async {
  await initializeDateFormatting('vi_VN');
  FlutterSecureStorage.setMockInitialValues({});
  if (!sl.isRegistered<ApiService>()) await setupServiceLocator();
  await sl<TokenStorage>().clearAll();
  final authBloc = sl<AuthBloc>()..add(const AuthStarted());
  await tester
      .pumpWidget(BlocProvider.value(value: authBloc, child: const SseApp()));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text(expectedText).evaluate().isNotEmpty) break;
  }
  expect(find.text(expectedText), findsOneWidget);
  await authBloc.close();
}
