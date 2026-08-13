import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sse_mobile/core/network/realtime_service.dart';
import 'package:sse_mobile/app.dart';
import 'package:sse_mobile/core/config/env.dart';
import 'package:sse_mobile/core/di/service_locator.dart';
import 'package:sse_mobile/core/network/api_service.dart';
import 'package:sse_mobile/core/storage/token_storage.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const _teacherPassword = String.fromEnvironment('E2E_TEACHER_PASSWORD');
const _studentPassword = String.fromEnvironment('E2E_STUDENT_PASSWORD');
const _secondStudentPassword =
    String.fromEnvironment('E2E_SECOND_STUDENT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');
const _temporaryTeacherPassword = 'MobileLiveTest123@@';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const runLive = bool.fromEnvironment('RUN_LIVE_INTEGRATION');

  test('mobile API đăng nhập đúng đủ bốn vai trò', () async {
    final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    expect(
        [_adminPassword, _teacherPassword, _studentPassword, _parentPassword]
            .every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến E2E_*_PASSWORD');
    final accounts = <(String, String, String)>[
      ('admin', _adminPassword, 'ADMIN'),
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

  test('phụ huynh chỉ đọc lịch đã công bố của con được liên kết', () async {
    final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final login = await dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': 'ph.nguyenvanhung',
        'password': _parentPassword,
      },
    );
    final token = '${login.data!['accessToken']}';
    final auth = Options(headers: {'Authorization': 'Bearer $token'});
    final children =
        await dio.get<List<dynamic>>('/me/children', options: auth);
    final child = (children.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => item['id'] == 'u-student-1');
    final timetable = await dio.get<List<dynamic>>(
      '/children/${child['id']}/timetable',
      options: auth,
    );
    final rows =
        (timetable.data ?? const <dynamic>[]).cast<Map<String, dynamic>>();
    expect(rows, isNotEmpty);
    expect(rows.every((item) => item['classId'] == child['classId']), isTrue);
    expect(
        rows.every((item) => '${item['publishedPlanId']}'.isNotEmpty), isTrue);

    try {
      await dio.get<List<dynamic>>(
        '/children/u-admin-1/timetable',
        options: auth,
      );
      fail('Phụ huynh không được đọc lịch của người không liên kết');
    } on DioException catch (error) {
      expect(error.response?.statusCode, 403);
    }
  }, skip: !runLive);

  test('giáo viên sửa điểm thì học sinh và phụ huynh nhận event và đọc lại',
      () async {
    expect(_secondStudentPassword, isNotEmpty,
        reason: 'Thiếu biến E2E_SECOND_STUDENT_PASSWORD');
    final teacherDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final studentDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final parentDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final teacherSession = await _teacherBusinessSession(teacherDio);
    final teacherToken = teacherSession.token;
    final studentToken =
        await _token(studentDio, 'hs.binh', _secondStudentPassword);
    final parentToken =
        await _token(parentDio, 'ph.nguyenvanhung', _parentPassword);
    teacherDio.options.headers['Authorization'] = 'Bearer $teacherToken';
    studentDio.options.headers['Authorization'] = 'Bearer $studentToken';
    parentDio.options.headers['Authorization'] = 'Bearer $parentToken';
    final studentProfile = await studentDio.get<Map<String, dynamic>>('/me');

    final studentRealtime = RealtimeService(studentDio)..connect();
    final parentRealtime = RealtimeService(parentDio)..connect();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    Map<String, dynamic>? current;
    Object? updatedVersion;
    try {
      final currentResponse = await studentDio.get<List<dynamic>>('/grades');
      current = (currentResponse.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .firstWhere((item) => item['id'] == 'g-8');
      current['classId'] = studentProfile.data!['classId'];
      final originalScore = (current['score'] as num).toDouble();
      final changedScore = originalScore == 9.75 ? 9.5 : 9.75;
      final stopwatch = Stopwatch()..start();
      final studentEvent = studentRealtime.events.firstWhere((event) =>
          event.type == 'GRADE_UPDATED' && event.data['entityId'] == 'g-8');
      final parentEvent = parentRealtime.events.firstWhere((event) =>
          event.type == 'GRADE_UPDATED' && event.data['entityId'] == 'g-8');

      final update = await teacherDio.post<List<dynamic>>(
        '/grades/bulk',
        data: _gradeBulkPayload(
          current,
          score: changedScore,
          note: 'Kiểm thử đồng bộ đa vai trò',
          reason: 'E2E realtime Mobile',
          expectedVersion: current['version'],
        ),
      );
      updatedVersion = update.data!.single['version'];
      await Future.wait([
        studentEvent.timeout(const Duration(seconds: 5)),
        parentEvent.timeout(const Duration(seconds: 5)),
      ]);
      expect(stopwatch.elapsed, lessThanOrEqualTo(const Duration(seconds: 5)));

      final studentRead = await studentDio.get<List<dynamic>>('/grades');
      final parentRead = await parentDio.get<List<dynamic>>('/grades',
          queryParameters: {'studentId': 'u-student-2'});
      for (final rows in [studentRead.data!, parentRead.data!]) {
        final grade = rows
            .cast<Map<String, dynamic>>()
            .firstWhere((item) => item['id'] == 'g-8');
        expect(grade['score'], changedScore);
        expect(grade['version'], updatedVersion);
      }
    } finally {
      if (current != null && updatedVersion != null) {
        await teacherDio.post<List<dynamic>>(
          '/grades/bulk',
          data: _gradeBulkPayload(
            current,
            score: (current['score'] as num).toDouble(),
            note: current['note']?.toString(),
            reason: 'Khôi phục sau E2E realtime',
            expectedVersion: updatedVersion,
          ),
        );
      }
      await studentRealtime.dispose();
      await parentRealtime.dispose();
      if (teacherSession.passwordChanged) {
        await _restoreTeacherPassword(teacherDio);
      }
    }
  }, skip: !runLive);

  test('giáo viên điểm danh thì học sinh và phụ huynh nhận event và đọc lại',
      () async {
    final teacherDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final studentDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final parentDio = Dio(BaseOptions(baseUrl: Env.baseUrl));
    final teacherSession = await _teacherBusinessSession(teacherDio);
    final studentToken =
        await _token(studentDio, 'hs.nguyenminhan', _studentPassword);
    final parentToken =
        await _token(parentDio, 'ph.nguyenvanhung', _parentPassword);
    teacherDio.options.headers['Authorization'] =
        'Bearer ${teacherSession.token}';
    studentDio.options.headers['Authorization'] = 'Bearer $studentToken';
    parentDio.options.headers['Authorization'] = 'Bearer $parentToken';

    final studentRealtime = RealtimeService(studentDio)..connect();
    final parentRealtime = RealtimeService(parentDio)..connect();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    Map<String, dynamic>? original;
    Object? latestVersion;
    ({Map<String, dynamic> slot, String date})? occurrence;
    try {
      occurrence = await _writableAttendanceOccurrence(teacherDio);
      final slotId = occurrence.slot['id'].toString();
      final date = occurrence.date;
      final existingResponse = await studentDio.get<List<dynamic>>(
        '/attendance',
      );
      final existingRows = (existingResponse.data ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .where((item) =>
              item['slotId']?.toString() == slotId &&
              item['date']?.toString() == date)
          .toList();
      if (existingRows.isNotEmpty) {
        original = Map<String, dynamic>.from(existingRows.single);
      }
      final firstStatus = original?['status'] == 'LATE' ? 'PRESENT' : 'LATE';
      final stopwatch = Stopwatch()..start();
      final studentEvent = studentRealtime.events.firstWhere((event) =>
          event.type == 'ATTENDANCE_UPDATED' &&
          event.data['studentId'] == 'u-student-1' &&
          event.data['slotId'] == slotId &&
          event.data['date'] == date);
      final parentEvent = parentRealtime.events.firstWhere((event) =>
          event.type == 'ATTENDANCE_UPDATED' &&
          event.data['studentId'] == 'u-student-1' &&
          event.data['slotId'] == slotId &&
          event.data['date'] == date);

      final saved = await teacherDio.post<List<dynamic>>(
        '/attendance/bulk',
        data: {
          'slotId': slotId,
          'date': date,
          'marks': [
            {
              'studentId': 'u-student-1',
              'status': firstStatus,
              'note':
                  firstStatus == 'LATE' ? 'Kiểm thử đồng bộ đa vai trò' : null,
              if (original != null) 'expectedVersion': original['version'],
            },
          ],
        },
      );
      final record = saved.data!.cast<Map<String, dynamic>>().single;
      latestVersion = record['version'];
      await Future.wait([
        studentEvent.timeout(const Duration(seconds: 5)),
        parentEvent.timeout(const Duration(seconds: 5)),
      ]);
      expect(stopwatch.elapsed, lessThanOrEqualTo(const Duration(seconds: 5)));

      final studentRead = await studentDio.get<List<dynamic>>('/attendance');
      final parentRead = await parentDio.get<List<dynamic>>(
        '/attendance',
        queryParameters: {'studentId': 'u-student-1'},
      );
      for (final rows in [studentRead.data!, parentRead.data!]) {
        final attendance = rows
            .cast<Map<String, dynamic>>()
            .firstWhere((item) => item['id'] == record['id']);
        expect(attendance['status'], firstStatus);
        expect(attendance['version'], record['version']);
      }

      final updated = await teacherDio.post<List<dynamic>>(
        '/attendance/bulk',
        data: {
          'slotId': slotId,
          'date': date,
          'marks': [
            {
              'studentId': 'u-student-1',
              'status': firstStatus == 'LATE' ? 'PRESENT' : 'LATE',
              'note': firstStatus == 'LATE'
                  ? null
                  : 'Cập nhật lần hai để tăng version',
              'expectedVersion': record['version'],
            },
          ],
        },
      );
      latestVersion = updated.data!.single['version'];
      expect(updated.data!.single['version'], isNot(record['version']));

      try {
        await teacherDio.post<List<dynamic>>(
          '/attendance/bulk',
          data: {
            'slotId': slotId,
            'date': date,
            'marks': [
              {
                'studentId': 'u-student-1',
                'status': firstStatus,
                'note':
                    firstStatus == 'LATE' ? 'Gửi lại bằng version cũ' : null,
                'expectedVersion': record['version'],
              },
            ],
          },
        );
        fail('Version điểm danh cũ phải bị từ chối');
      } on DioException catch (error) {
        expect(error.response?.statusCode, 409);
      }
    } finally {
      if (original != null && latestVersion != null) {
        await teacherDio.post<List<dynamic>>(
          '/attendance/bulk',
          data: {
            'slotId': original['slotId'],
            'date': original['date'],
            'marks': [
              {
                'studentId': original['studentId'],
                'status': original['status'],
                'note': original['note'],
                'expectedVersion': latestVersion,
              },
            ],
          },
        );
      } else if (latestVersion != null && occurrence != null) {
        // API không có delete điểm danh; đưa fixture vừa tạo về trạng thái trung
        // tính, ổn định để lần chạy tiếp theo có thể khôi phục chính xác.
        await teacherDio.post<List<dynamic>>(
          '/attendance/bulk',
          data: {
            'slotId': occurrence.slot['id'],
            'date': occurrence.date,
            'marks': [
              {
                'studentId': 'u-student-1',
                'status': 'PRESENT',
                'note': null,
                'expectedVersion': latestVersion,
              },
            ],
          },
        );
      }
      await studentRealtime.dispose();
      await parentRealtime.dispose();
      if (teacherSession.passwordChanged) {
        await _restoreTeacherPassword(teacherDio);
      }
    }
  }, skip: !runLive);
}

Map<String, dynamic> _gradeBulkPayload(
  Map<String, dynamic> grade, {
  required double score,
  required String? note,
  required String reason,
  required Object? expectedVersion,
}) =>
    {
      'classId': grade['classId'],
      'subjectId': grade['subjectId'],
      'semesterId': grade['semesterId'],
      'category': grade['category'],
      'assessmentIndex': grade['assessmentIndex'],
      'reason': reason,
      'entries': [
        {
          'studentId': grade['studentId'],
          'score': score,
          'note': note,
          'expectedVersion': expectedVersion,
        },
      ],
    };

Future<({Map<String, dynamic> slot, String date})>
    _writableAttendanceOccurrence(Dio teacherDio) async {
  final responses = await Future.wait([
    teacherDio.get<List<dynamic>>('/me/timetable'),
    teacherDio.get<List<dynamic>>('/semesters'),
  ]);
  final slots = (responses[0].data ?? const <dynamic>[])
      .cast<Map<String, dynamic>>()
      .where((item) => item['classId'] == 'c-10a1')
      .toList();
  final semesters =
      (responses[1].data ?? const <dynamic>[]).cast<Map<String, dynamic>>();

  for (final semester in semesters) {
    final start = DateTime.tryParse('${semester['startDate']}');
    final end = DateTime.tryParse('${semester['endDate']}');
    if (start == null || end == null) continue;
    final until = end.difference(start).inDays.clamp(0, 45);
    for (var offset = 0; offset <= until; offset++) {
      final day = start.add(Duration(days: offset));
      final dayCode = const [
        'MON',
        'TUE',
        'WED',
        'THU',
        'FRI',
        'SAT',
        'SUN'
      ][day.weekday - 1];
      for (final slot in slots.where((item) =>
          item['dayOfWeek'] == dayCode &&
          '${item['semesterId']}' == '${semester['id']}')) {
        final date = day.toIso8601String().substring(0, 10);
        Response<Map<String, dynamic>> response;
        try {
          response = await teacherDio.get<Map<String, dynamic>>(
            '/attendance/session-status',
            queryParameters: {'slotId': slot['id'], 'date': date},
          );
        } on DioException catch (error) {
          if ({400, 403, 409}.contains(error.response?.statusCode)) continue;
          rethrow;
        }
        final status = response.data!;
        if (status['canMark'] == true) return (slot: slot, date: date);
        if (status['requiresUnlockReason'] == true) {
          try {
            await teacherDio.post<Map<String, dynamic>>(
              '/attendance/unlock',
              data: {
                'slotId': slot['id'],
                'date': date,
                'reason':
                    'Kiểm thử tích hợp Mobile trên dữ liệu demo sau giờ học',
              },
            );
            return (slot: slot, date: date);
          } on DioException catch (error) {
            if ({400, 403, 409}.contains(error.response?.statusCode)) continue;
            rethrow;
          }
        }
      }
    }
  }
  throw StateError(
    'Backend chưa có buổi học hợp lệ để test điểm danh. '
    'Hãy chạy profile demo với sse.demo.fixed-clock nằm sau ngày bắt đầu học kỳ.',
  );
}

Future<({String token, bool passwordChanged})> _teacherBusinessSession(
    Dio dio) async {
  final response = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': 'gv.nguyenminh', 'password': _teacherPassword},
  );
  final token = '${response.data!['accessToken']}';
  final user = response.data!['user'] as Map<String, dynamic>;
  if (user['passwordChangeRequired'] != true) {
    return (token: token, passwordChanged: false);
  }

  dio.options.headers['Authorization'] = 'Bearer $token';
  await dio.put<Map<String, dynamic>>(
    '/me/password',
    data: {
      'currentPassword': _teacherPassword,
      'newPassword': _temporaryTeacherPassword,
    },
  );
  dio.options.headers.remove('Authorization');
  return (
    token: await _token(dio, 'gv.nguyenminh', _temporaryTeacherPassword),
    passwordChanged: true,
  );
}

Future<void> _restoreTeacherPassword(Dio dio) async {
  dio.options.headers.remove('Authorization');
  final token = await _token(dio, 'gv.nguyenminh', _temporaryTeacherPassword);
  dio.options.headers['Authorization'] = 'Bearer $token';
  await dio.put<Map<String, dynamic>>(
    '/me/password',
    data: {
      'currentPassword': _temporaryTeacherPassword,
      'newPassword': _teacherPassword,
    },
  );
}

Future<String> _token(Dio dio, String username, String password) async {
  final response = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': username, 'password': password},
  );
  return '${response.data!['accessToken']}';
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
