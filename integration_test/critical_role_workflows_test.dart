import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:4000',
);

const _accounts = <String, ({String username, String password})>{
  'ADMIN': (
    username: 'admin',
    password: String.fromEnvironment('E2E_ADMIN_PASSWORD'),
  ),
  'ACADEMIC_STAFF': (
    username: 'giaovu',
    password: String.fromEnvironment('E2E_ACADEMIC_STAFF_PASSWORD'),
  ),
  'ACCOUNTANT': (
    username: 'ketoan',
    password: String.fromEnvironment('E2E_ACCOUNTANT_PASSWORD'),
  ),
  'TEACHER': (
    username: 'gv.nguyenminh',
    password: String.fromEnvironment('E2E_TEACHER_PASSWORD'),
  ),
  'STUDENT': (
    username: 'hs.nguyenminhan',
    password: String.fromEnvironment('E2E_STUDENT_PASSWORD'),
  ),
  'PARENT': (
    username: 'ph.nguyenvanhung',
    password: String.fromEnvironment('E2E_PARENT_PASSWORD'),
  ),
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('đăng nhập, khôi phục phiên và phân quyền đủ sáu vai trò', (
    tester,
  ) async {
    final anonymous = Dio(BaseOptions(baseUrl: _apiBase));
    for (final entry in _accounts.entries) {
      expect(
        entry.value.password,
        isNotEmpty,
        reason: 'Thiếu dart-define mật khẩu cho ${entry.key}',
      );
      final login = await anonymous.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': entry.value.username,
          'password': entry.value.password,
        },
      );
      expect(login.statusCode, 200);
      expect(login.data?['user']?['role'], entry.key);

      final access = '${login.data?['accessToken']}';
      final refresh = '${login.data?['refreshToken']}';
      final authenticated = Dio(
        BaseOptions(
          baseUrl: _apiBase,
          headers: {'Authorization': 'Bearer $access'},
        ),
      );
      expect((await authenticated.get('/me')).statusCode, 200);
      expect((await authenticated.get('/dashboard')).statusCode, 200);

      final refreshed = await anonymous.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      expect(refreshed.statusCode, 200);
      expect(refreshed.data?['accessToken'], isNotEmpty);
    }
  });

  testWidgets('thời khóa biểu, điểm, điểm danh và thông báo trả dữ liệu thật', (
    tester,
  ) async {
    final teacher = await _login('TEACHER');
    expect((await teacher.get('/me/timetable')).data, isA<List>());
    expect(
      (await teacher.get(
        '/attendance/day-status',
        queryParameters: {'date': '2026-08-03'},
      )).statusCode,
      200,
    );
    expect((await teacher.get('/notifications')).statusCode, 200);

    final student = await _login('STUDENT');
    expect(
      (await student.get(
        '/grades',
        queryParameters: {'semesterId': 'sem-2026-1'},
      )).data,
      isA<List>(),
    );
    expect((await student.get('/attendance')).data, isA<List>());
    expect((await student.get('/notifications')).statusCode, 200);
  });

  testWidgets('giáo vụ, kế toán và phụ huynh truy cập đúng nghiệp vụ', (
    tester,
  ) async {
    final academic = await _login('ACADEMIC_STAFF');
    expect((await academic.get('/academicYears')).data, isA<List>());
    expect(
      (await academic.get(
        '/classes',
        queryParameters: {'academicYearId': 'ay-2026'},
      )).data,
      isA<List>(),
    );

    final accountant = await _login('ACCOUNTANT');
    expect((await accountant.get('/fee-periods')).data, isA<List>());

    final parent = await _login('PARENT');
    final childrenResponse = await parent.get<List<dynamic>>('/me/children');
    final children = childrenResponse.data ?? const [];
    expect(children, isNotEmpty);
    final childId = '${(children.first as Map)['id']}';
    expect(
      (await parent.get(
        '/grades',
        queryParameters: {
          'studentId': childId,
          'semesterId': 'sem-2026-1',
        },
      )).statusCode,
      200,
    );
    expect((await parent.get('/notifications')).statusCode, 200);
  });
}

Future<Dio> _login(String role) async {
  final account = _accounts[role]!;
  expect(account.password, isNotEmpty, reason: 'Thiếu mật khẩu $role');
  final anonymous = Dio(BaseOptions(baseUrl: _apiBase));
  final response = await anonymous.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': account.username, 'password': account.password},
  );
  expect(response.data?['user']?['role'], role);
  return Dio(
    BaseOptions(
      baseUrl: _apiBase,
      headers: {'Authorization': 'Bearer ${response.data?['accessToken']}'},
    ),
  );
}
