import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sse_mobile/core/config/env.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
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
          _adminPassword,
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
      final admin = await _login(dio, 'admin', _adminPassword);
      final teacher = await _login(dio, 'gv.nguyenminh', _teacherPassword);
      final student = await _login(dio, 'hs.nguyenminhan', _studentPassword);
      final parent = await _login(dio, 'ph.nguyenvanhung', _parentPassword);

      final yearsResponse = await dio.get<List<dynamic>>(
        '/academicYears',
        options: _auth(admin),
      );
      expect(yearsResponse.statusCode, 200);
      final years = yearsResponse.data!
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList();
      final activeYear = years.firstWhere((item) => item['status'] == 'ACTIVE');
      final yearId = activeYear['id'].toString();

      final rolloverPreview = await dio.get<Map<String, dynamic>>(
        '/academic-years/$yearId/rollover-preview',
        options: _auth(admin),
      );
      expect(rolloverPreview.statusCode, 200);
      expect(rolloverPreview.data!['studentCount'], greaterThan(0));
      expect(rolloverPreview.data!['incompleteCount'], greaterThan(0));
      expect(rolloverPreview.data!['blockers'], isNotEmpty);

      final promotionPreview = await dio.get<List<dynamic>>(
        '/academic-years/$yearId/promotion-preview',
        options: _auth(admin),
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
        options: _auth(admin),
      );
      expect(blockedRollover.statusCode, 400);

      final yearsAfter = await dio.get<List<dynamic>>(
        '/academicYears',
        options: _auth(admin),
      );
      expect(yearsAfter.statusCode, 200);
      expect(yearsAfter.data, hasLength(yearCountBefore));
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
