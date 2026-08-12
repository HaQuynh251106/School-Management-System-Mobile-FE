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

const _academicStaffPassword = String.fromEnvironment(
  'E2E_ACADEMIC_STAFF_PASSWORD',
);
const _teacherPassword = String.fromEnvironment('E2E_TEACHER_PASSWORD');
const _studentPassword = String.fromEnvironment('E2E_STUDENT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const runLive = bool.fromEnvironment('RUN_LIVE_INTEGRATION');

  test(
    'year-end is scoped by role and an incomplete year cannot roll over',
    () async {
      expect(
        [
          _academicStaffPassword,
          _teacherPassword,
          _studentPassword,
          _parentPassword,
        ].every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến mật khẩu E2E cho luồng tổng kết cuối năm',
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final academicStaff = await _login(dio, 'giaovu', _academicStaffPassword);
      final teacher = await _login(dio, 'gv.nguyenminh', _teacherPassword);
      final student = await _login(dio, 'hs.nguyenminhan', _studentPassword);
      final parent = await _login(dio, 'ph.nguyenvanhung', _parentPassword);

      final yearsResponse = await dio.get<List<dynamic>>(
        '/academicYears',
        options: _auth(academicStaff),
      );
      expect(yearsResponse.statusCode, 200);
      final years = yearsResponse.data!
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList();
      final activeYear = years.firstWhere((item) => item['status'] == 'ACTIVE');
      final yearId = activeYear['id'].toString();

      final rolloverPreview = await dio.get<Map<String, dynamic>>(
        '/academic-years/$yearId/rollover-preview',
        options: _auth(academicStaff),
      );
      expect(rolloverPreview.statusCode, 200);
      expect(rolloverPreview.data!['studentCount'], greaterThan(0));
      expect(rolloverPreview.data!['incompleteCount'], greaterThan(0));
      expect(rolloverPreview.data!['blockers'], isNotEmpty);

      final promotionPreview = await dio.get<List<dynamic>>(
        '/academic-years/$yearId/promotion-preview',
        options: _auth(academicStaff),
      );
      expect(promotionPreview.statusCode, 200);
      expect(promotionPreview.data, isNotEmpty);

      final teacherRows = await dio.get<List<dynamic>>(
        '/academic-years/$yearId/homeroom-summaries',
        options: _auth(teacher),
      );
      expect(teacherRows.statusCode, 200);
      expect(teacherRows.data, isNotEmpty);
      final teacherStudentIds = teacherRows.data!
          .map((item) => (item as Map)['studentId'].toString())
          .toSet();

      final studentSummary = await dio.get<Map<String, dynamic>>(
        '/academic-years/$yearId/my-summary',
        options: _auth(student),
      );
      expect(studentSummary.statusCode, 200);
      expect(teacherStudentIds, contains(studentSummary.data!['studentId']));

      final children = await dio.get<List<dynamic>>(
        '/me/children',
        options: _auth(parent),
      );
      expect(children.statusCode, 200);
      expect(children.data, isNotEmpty);
      final childId = (children.data!.first as Map)['id'].toString();
      final childSummary = await dio.get<Map<String, dynamic>>(
        '/academic-years/$yearId/children/$childId/summary',
        options: _auth(parent),
      );
      expect(childSummary.statusCode, 200);
      expect(childSummary.data!['studentId'], childId);

      final forbiddenTeacherPreview = await dio.get<dynamic>(
        '/academic-years/$yearId/rollover-preview',
        options: _auth(teacher),
      );
      expect(forbiddenTeacherPreview.statusCode, 403);
      final forbiddenParentSelfSummary = await dio.get<dynamic>(
        '/academic-years/$yearId/my-summary',
        options: _auth(parent),
      );
      expect(forbiddenParentSelfSummary.statusCode, 403);

      final yearCountBefore = years.length;
      final blockedRollover = await dio.post<dynamic>(
        '/academic-years/$yearId/rollover',
        data: {
          'nextYearCode':
              'E2E-BLOCKED-${DateTime.now().millisecondsSinceEpoch}',
          'nextYearName': 'E2E phải bị chặn',
          'startDate': '2098-08-01',
          'endDate': '2099-05-31',
          'createIntakeClasses': true,
          'activateNextYear': false,
        },
        options: _auth(academicStaff),
      );
      expect(blockedRollover.statusCode, 400);

      final yearsAfter = await dio.get<List<dynamic>>(
        '/academicYears',
        options: _auth(academicStaff),
      );
      expect(yearsAfter.statusCode, 200);
      expect(yearsAfter.data, hasLength(yearCountBefore));
    },
    skip: !runLive,
  );

  testWidgets(
    'Giáo vụ thấy blocker và không thể chuyển năm khi chưa đủ dữ liệu',
    (tester) async {
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
      await tester.enterText(fields.at(0), 'giaovu');
      await tester.enterText(fields.at(1), _academicStaffPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));

      await _pumpUntil(tester, find.text('Tổng kết và chuyển năm học'));
      await tester.tap(find.text('Tổng kết và chuyển năm học'));
      await _pumpUntil(tester, find.text('Điều kiện chuyển năm'));

      expect(find.text('Điều kiện chuyển năm'), findsOneWidget);
      expect(
        find.textContaining('học sinh thiếu điểm hoặc hạnh kiểm'),
        findsOneWidget,
      );
      final rolloverButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Chuyển sang năm học mới'),
      );
      expect(rolloverButton.onPressed, isNull);

      await authBloc.close();
    },
    skip: !runLive,
  );
}

Future<String> _login(Dio dio, String username, String password) async {
  final response = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': username, 'password': password},
  );
  expect(response.statusCode, 200, reason: 'Không đăng nhập được $username');
  return response.data!['accessToken'].toString();
}

Options _auth(String token) =>
    Options(headers: {'Authorization': 'Bearer $token'});

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}
