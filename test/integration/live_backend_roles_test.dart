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

const _teacherPassword = String.fromEnvironment('E2E_TEACHER_PASSWORD');
const _studentPassword = String.fromEnvironment('E2E_STUDENT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const runLive = bool.fromEnvironment('RUN_LIVE_INTEGRATION');

  test('mobile API đăng nhập đúng ba vai trò được hỗ trợ', () async {
    final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    expect(
      [
        _teacherPassword,
        _studentPassword,
        _parentPassword,
      ].every((value) => value.isNotEmpty),
      isTrue,
      reason: 'Thiếu biến E2E_*_PASSWORD',
    );
    final accounts = <(String, String, String)>[
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
        (response.data!['user'] as Map<String, dynamic>)['role'],
        account.$3,
      );
      expect(response.data!['accessToken'], isNotEmpty);
    }
  }, skip: !runLive);

  testWidgets('mobile UI đăng nhập học sinh và điều hướng đúng vai trò', (
    tester,
  ) async {
    await _loginAndExpect(
      tester,
      'hs.nguyenminhan',
      _studentPassword,
      'Thời khóa biểu',
    );
  }, skip: !runLive);

  testWidgets('học sinh không thấy lịch thi giả khi backend chưa có kỳ thi', (
    tester,
  ) async {
    final agenda = await _agenda(
      username: 'hs.nguyenminhan',
      password: _studentPassword,
    );
    await _loginAndExpect(
      tester,
      'hs.nguyenminhan',
      _studentPassword,
      'Thời khóa biểu',
    );
    for (var attempt = 0; attempt < (agenda.isEmpty ? 2 : 30); attempt++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (agenda.isNotEmpty &&
          find.text('Kỳ thi sắp diễn ra').evaluate().isNotEmpty) {
        break;
      }
    }
    expect(
      find.text('Kỳ thi sắp diễn ra'),
      agenda.isEmpty ? findsNothing : findsOneWidget,
    );
  }, skip: !runLive);

  testWidgets('phụ huynh không thấy lịch thi giả khi backend chưa có kỳ thi', (
    tester,
  ) async {
    final agenda = await _agenda(
      username: 'ph.nguyenvanhung',
      password: _parentPassword,
      childId: 'u-student-1',
    );
    await _loginAndExpect(
      tester,
      'ph.nguyenvanhung',
      _parentPassword,
      'Giám sát con',
    );
    for (var attempt = 0; attempt < (agenda.isEmpty ? 2 : 30); attempt++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (agenda.isNotEmpty &&
          find
              .textContaining('Kỳ thi sắp diễn ra của Nguyễn Minh An')
              .evaluate()
              .isNotEmpty) {
        break;
      }
    }
    expect(
      find.textContaining('Kỳ thi sắp diễn ra của Nguyễn Minh An'),
      agenda.isEmpty ? findsNothing : findsOneWidget,
    );
  }, skip: !runLive);
}

Future<List<dynamic>> _agenda({
  required String username,
  required String password,
  String? childId,
}) async {
  final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
  final login = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': username, 'password': password},
  );
  final token = login.data!['accessToken'] as String;
  final response = await dio.get<List<dynamic>>(
    '/me/exam-agenda',
    queryParameters: childId == null ? null : {'childId': childId},
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  return response.data ?? const [];
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
  await tester.pumpWidget(
    BlocProvider.value(value: authBloc, child: const SseApp()),
  );
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
