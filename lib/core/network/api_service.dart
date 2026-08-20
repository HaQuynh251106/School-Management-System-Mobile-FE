import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:sse_finance_api/sse_finance_api.dart';
import 'package:sse_identity_api/sse_identity_api.dart' as identity;
import 'package:sse_academic_api/sse_academic_api.dart' as academic;
import 'package:sse_report_api/sse_report_api.dart' as report;

import '../../features/timetable/data/timetable_slot.dart';

/// Lớp gọi API SSE backend (Spring Boot, :4000) dùng Dio đã gắn interceptor JWT.
/// Trả JSON thô (List/Map dynamic) để các trang đọc field trực tiếp — gọn, ít model.
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  FinancePaymentsApi get _financeApi => FinancePaymentsApi(_dio);
  identity.IdentityApi get _identityApi => identity.IdentityApi(_dio);
  academic.AcademicApi get _academicApi => academic.AcademicApi(_dio);
  report.ReportApi get _reportApi => report.ReportApi(_dio);

  List<Map<String, dynamic>> _list(Response r) =>
      (r.data as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _map(Response r) =>
      (r.data as Map).cast<String, dynamic>();

  String _localDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  identity.CreateUserRequestRoleEnum _identityRole(String value) =>
      identity.CreateUserRequestRoleEnum.values.firstWhere(
        (role) => role.value == value,
        orElse: () => throw ArgumentError.value(
          value,
          'role',
          'Vai tro nguoi dung khong hop le',
        ),
      );

  DateTime? _optionalDate(Object? value) {
    if (value == null || value.toString().isEmpty) return null;
    return value is DateTime ? value : DateTime.parse(value.toString());
  }

  academic.CreateClassRequestStudyShiftEnum? _studyShift(Object? value) {
    if (value == null || value.toString().isEmpty) return null;
    return academic.CreateClassRequestStudyShiftEnum.values.firstWhere(
      (shift) => shift.value == value,
      orElse: () =>
          throw ArgumentError.value(value, 'studyShift', 'Ca hoc khong hop le'),
    );
  }

  Future<Map<String, dynamic>> dashboard({String? childId}) async {
    final response = await _reportApi.getDashboard(childId: childId);
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> auditLogsPage({
    String? query,
    int page = 0,
    int size = 50,
  }) async => _map(
    await _dio.get(
      '/audit-logs/page',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'page': page,
        'size': size,
      },
    ),
  );

  Future<Map<String, dynamic>> personalReport({String? childId}) async {
    final data = await dashboard(childId: childId);
    final metrics = data['metrics'];
    if (metrics is List) {
      return {
        for (final item in metrics.whereType<Map>())
          if (item['key'] != null) '${item['key']}': item['value'],
      };
    }
    return metrics is Map ? metrics.cast<String, dynamic>() : const {};
  }

  Future<Map<String, dynamic>> reportOverview() async {
    final response = await _reportApi.getReportOverview();
    return response.data!.toJson();
  }

  Future<List<Map<String, dynamic>>> reportGradeDistribution({
    String? semesterId,
    String? classId,
    String? subjectId,
  }) async {
    final response = await _reportApi.getGradeDistribution(
      semesterId: semesterId,
      classId: classId,
      subjectId: subjectId,
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<Map<String, dynamic>> reportAttendance({
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _reportApi.getAttendanceSummary(
      classId: classId,
      startDate: startDate,
      endDate: endDate,
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> reportRevenue({
    String? periodId,
    String? classId,
  }) async {
    final response = await _reportApi.getRevenueReport(
      periodId: periodId,
      classId: classId,
    );
    return response.data!.toJson();
  }

  Future<List<int>> exportReport({
    required String type,
    required String format,
    String? semesterId,
    String? classId,
    String? subjectId,
    DateTime? startDate,
    DateTime? endDate,
    String? periodId,
  }) async {
    final response = await _reportApi.exportReport(
      type: type,
      format: format,
      semesterId: semesterId,
      classId: classId,
      subjectId: subjectId,
      startDate: startDate,
      endDate: endDate,
      periodId: periodId,
    );
    return response.data ?? const <int>[];
  }

  Future<List<int>> exportPersonalReport({String? childId}) async {
    final response = await _reportApi.exportPersonalReport(childId: childId);
    return response.data ?? const <int>[];
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profile,
  ) async => _map(await _dio.put('/me/profile', data: profile));

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async => _dio.put(
    '/me/password',
    data: {'currentPassword': currentPassword, 'newPassword': newPassword},
  );

  // ---------- Admin: users ----------
  Future<List<Map<String, dynamic>>> users({
    String? role,
    String? q,
    String? classId,
  }) async {
    final response = await _identityApi.listUsers(
      role: role,
      q: q,
      classId: classId,
    );
    return (response.data ?? const []).map((user) => user.toJson()).toList();
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _identityApi.createUser(
      createUserRequest: identity.CreateUserRequest(
        id: data['id'] as String?,
        username: data['username'] as String,
        password: data['password'] as String,
        fullName: data['fullName'] as String,
        role: _identityRole(data['role'] as String),
        email: data['email'] as String,
        phone: data['phone'] as String,
        avatarUrl: data['avatarUrl'] as String?,
        mainSubjectId: data['mainSubjectId'] as String?,
        classId: data['classId'] as String?,
        className: data['className'] as String?,
        dateOfBirth: _optionalDate(data['dateOfBirth']),
        gender: data['gender'] as String?,
        placeOfBirth: data['placeOfBirth'] as String?,
        ethnicity: data['ethnicity'] as String?,
        nationality: data['nationality'] as String?,
        address: data['address'] as String?,
        enrollmentDate: _optionalDate(data['enrollmentDate']),
        guardianName: data['guardianName'] as String?,
        guardianPhone: data['guardianPhone'] as String?,
      ),
    );
    return response.data!.toJson();
  }

  Future<void> lockUser(String id) async => _identityApi.lockUser(id: id);
  Future<void> unlockUser(String id) async => _identityApi.unlockUser(id: id);
  Future<Map<String, dynamic>> user(String id) async =>
      (await _identityApi.getUser(id: id)).data!.toJson();
  Future<Map<String, dynamic>> resetUserPassword(
    String id, {
    String? newPassword,
  }) async => (await _identityApi.adminResetUserPassword(
    id: id,
    adminResetPasswordRequest: identity.AdminResetPasswordRequest(
      newPassword: newPassword,
    ),
  )).data!.toJson();
  Future<List<Map<String, dynamic>>> loginHistory(String id) async =>
      _list(await _dio.get('/users/$id/login-history'));
  Future<List<Map<String, dynamic>>> userChildren(String id) async =>
      _list(await _dio.get('/users/$id/children'));

  Future<Map<String, dynamic>> previewUserImport(
    Uint8List bytes,
    String filename,
  ) async => _map(
    await _dio.post(
      '/users/import/preview',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    ),
  );

  Future<Map<String, dynamic>> commitUserImport(
    Uint8List bytes,
    String filename,
    String token, {
    String strategy = 'ALL_OR_NOTHING',
  }) async => _map(
    await _dio.post(
      '/users/import/commit',
      queryParameters: {'token': token, 'strategy': strategy},
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    ),
  );

  Future<Uint8List> userImportTemplate() async {
    final response = await _dio.get<List<int>>(
      '/users/import-template',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  // ---------- Admin: structure extras ----------
  Future<List<Map<String, dynamic>>> academicYears() async =>
      (await _academicApi.listAcademicYears()).data!
          .map((item) => item.toJson())
          .toList();
  Future<List<Map<String, dynamic>>> rooms() async =>
      (await _academicApi.listRooms()).data!
          .map((item) => item.toJson())
          .toList();
  Future<void> setConduct(
    String yearId,
    String studentId,
    String conductGrade,
  ) async => _dio.put(
    '/academic-years/$yearId/students/$studentId/conduct',
    data: {'conductGrade': conductGrade},
  );
  Future<List<Map<String, dynamic>>> finalizeYear(String yearId) async =>
      _list(await _dio.post('/academic-years/$yearId/finalize'));

  // ---------- Admin: finance / templates ----------
  Future<List<Map<String, dynamic>>> feePeriods() async =>
      _list(await _dio.get('/fee-periods'));
  Future<Map<String, dynamic>> createFeePeriod(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/fee-periods', data: data));
  Future<Map<String, dynamic>> feePeriodDetail(String id) async =>
      _map(await _dio.get('/fee-periods/$id'));
  Future<Map<String, dynamic>> updateFeePeriod(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/fee-periods/$id', data: data));
  Future<Map<String, dynamic>> feePeriodPreview(String id) async =>
      _map(await _dio.get('/fee-periods/$id/preview'));
  Future<Map<String, dynamic>> addFeePeriodItem(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/fee-periods/$id/items', data: data));
  Future<void> deleteFeePeriodItem(String periodId, String itemId) async =>
      _dio.delete('/fee-periods/$periodId/items/$itemId');
  Future<Map<String, dynamic>> saveFeePeriodAdjustment(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/fee-periods/$id/adjustments', data: data));
  Future<void> deleteFeePeriodAdjustment(
    String periodId,
    String adjustmentId,
  ) async => _dio.delete('/fee-periods/$periodId/adjustments/$adjustmentId');
  Future<Map<String, dynamic>> openFeePeriod(String id) async =>
      _map(await _dio.post('/fee-periods/$id/open'));
  Future<Map<String, dynamic>> closeFeePeriod(String id) async =>
      _map(await _dio.post('/fee-periods/$id/close'));
  Future<Map<String, dynamic>> financeOverview({
    String? grade,
    String? classId,
    String? feePeriodId,
  }) async => _map(
    await _dio.get(
      '/finance/overview',
      queryParameters: {
        if (grade != null) 'grade': grade,
        if (classId != null) 'classId': classId,
        if (feePeriodId != null) 'feePeriodId': feePeriodId,
      },
    ),
  );
  Future<List<Map<String, dynamic>>> generateInvoices(
    String feePeriodId,
  ) async =>
      _list(await _dio.post('/fee-periods/$feePeriodId/generate-invoices'));
  Future<List<Map<String, dynamic>>> notificationTemplates() async =>
      _list(await _dio.get('/notification-templates'));
  Future<Map<String, dynamic>> saveNotificationTemplate(
    Map<String, dynamic> data,
  ) async => data['id'] == null
      ? _map(await _dio.post('/notification-templates', data: data))
      : _map(
          await _dio.put('/notification-templates/${data['id']}', data: data),
        );

  // ---------- Academic structure ----------
  Future<List<Map<String, dynamic>>> classes() async =>
      (await _academicApi.listClasses()).data!
          .map((item) => item.toJson())
          .toList();
  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async =>
      (await _academicApi.createClass(
        createClassRequest: academic.CreateClassRequest(
          id: data['id'] as String?,
          code: data['code'] as String,
          name: data['name'] as String?,
          gradeLevel: data['gradeLevel'] as String,
          academicYearId: data['academicYearId'] as String?,
          homeroomTeacherId: data['homeroomTeacherId'] as String?,
          studyShift: _studyShift(data['studyShift']),
          capacity: data['capacity'] as int?,
          roomId: data['roomId'] as String?,
        ),
      )).data!.toJson();
  Future<Map<String, dynamic>> updateClass(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/classes/$id', data: data));
  Future<void> deleteClass(String id) async => _dio.delete('/classes/$id');
  Future<List<Map<String, dynamic>>> subjects() async =>
      (await _academicApi.listSubjects()).data!
          .map((item) => item.toJson())
          .toList();
  Future<Map<String, dynamic>> createSubject(Map<String, dynamic> data) async =>
      (await _academicApi.createSubject(
        createSubjectRequest: academic.CreateSubjectRequest(
          id: data['id'] as String?,
          code: data['code'] as String,
          name: data['name'] as String,
          coefficient: (data['coefficient'] as num?)?.toDouble(),
        ),
      )).data!.toJson();
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data) async =>
      (await _academicApi.createRoom(
        createRoomRequest: academic.CreateRoomRequest(
          id: data['id'] as String?,
          code: data['code'] as String,
          name: data['name'] as String?,
          capacity: data['capacity'] as int?,
          supportsMorning: data['supportsMorning'] as bool?,
          supportsAfternoon: data['supportsAfternoon'] as bool?,
        ),
      )).data!.toJson();
  Future<List<Map<String, dynamic>>> semesters() async =>
      (await _academicApi.listSemesters()).data!
          .map((item) => item.toJson())
          .toList();
  Future<List<Map<String, dynamic>>> examCategories() async =>
      (await _academicApi.listExamCategories()).data!
          .map((item) => item.toJson())
          .toList();
  Future<List<Map<String, dynamic>>> classStudents(String classId) async =>
      _list(await _dio.get('/classes/$classId/students'));

  Future<Map<String, dynamic>> createAcademicYear(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/academicYears', data: data));
  Future<Map<String, dynamic>> createSemester(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/semesters', data: data));
  Future<List<Map<String, dynamic>>> intakeCandidates(
    String academicYearId,
    String gradeLevel,
  ) async => _list(
    await _dio.get(
      '/intake-class-placement/candidates',
      queryParameters: {
        'academicYearId': academicYearId,
        'gradeLevel': gradeLevel,
      },
    ),
  );
  Future<Map<String, dynamic>> previewIntakePlacement(
    Map<String, dynamic> data,
  ) async =>
      _map(await _dio.post('/intake-class-placement/preview', data: data));
  Future<Map<String, dynamic>> applyIntakePlacement(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/intake-class-placement/apply', data: data));

  Future<List<Map<String, dynamic>>> curriculumRequirements(
    String semesterId,
  ) async => _list(
    await _dio.get(
      '/curriculum-requirements',
      queryParameters: {'semesterId': semesterId},
    ),
  );
  Future<Map<String, dynamic>> saveCurriculumRequirement(
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/curriculum-requirements', data: data));
  Future<void> deleteCurriculumRequirement(String id) async =>
      _dio.delete('/curriculum-requirements/$id');
  Future<Map<String, dynamic>> updateCurriculumRequirementStatus(
    String id,
    String status,
    int expectedVersion,
  ) async => _map(
    await _dio.put(
      '/curriculum-requirements/$id/status',
      data: {'status': status, 'expectedVersion': expectedVersion},
    ),
  );

  // ---------- Timetable ----------
  Future<List<Map<String, dynamic>>> myTimetable() async =>
      (await _academicApi.getMyTimetable()).data!
          .map((item) => item.toJson())
          .toList();
  Future<List<TimetableSlot>> childTimetable(String studentId) async {
    final response = await _dio.get<List<dynamic>>(
      '/students/$studentId/timetable',
    );
    return (response.data ?? const <dynamic>[])
        .map(
          (item) =>
              TimetableSlot.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> timetableOfClass(String classId) async =>
      (await _academicApi.listTimetableSlots(
        classId: classId,
      )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> timetableSlots({
    required String classId,
    required String semesterId,
  }) async => (await _academicApi.listTimetableSlots(
    classId: classId,
    semesterId: semesterId,
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> classTimetableSlots(
    String classId,
  ) async => _list(
    await _dio.get('/timetableSlots', queryParameters: {'classId': classId}),
  );

  Future<Map<String, dynamic>> createTimetableSlot(
    Map<String, dynamic> data,
  ) async => (await _academicApi.createTimetableSlot(
    saveTimetableSlotRequest: academic.SaveTimetableSlotRequest(
      id: data['id'] as String?,
      classId: data['classId'] as String,
      subjectId: data['subjectId'] as String,
      teacherId: data['teacherId'] as String,
      roomCode: data['roomCode'] as String?,
      dayOfWeek: data['dayOfWeek'] as String,
      periodNo: data['periodNo'] as int,
      startTime: data['startTime'] as String,
      endTime: data['endTime'] as String,
      semesterId: data['semesterId'] as String,
    ),
  )).data!.toJson();

  Future<Map<String, dynamic>> updateTimetableSlot(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/timetableSlots/$id', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteTimetableSlot(String id) async =>
      _dio.delete('/timetableSlots/$id');

  Future<Map<String, dynamic>> autoPlanTimetable(
    String semesterId, {
    bool apply = false,
    bool allowPartial = false,
    String? scopeGradeLevel,
    String? draftName,
    List<String>? allowedDays,
  }) async => _map(
    await _dio.post(
      '/timetableSlots/auto-plan',
      data: {
        'semesterId': semesterId,
        'apply': apply,
        'allowPartial': allowPartial,
        if (scopeGradeLevel != null) 'scopeGradeLevel': scopeGradeLevel,
        if (draftName != null) 'draftName': draftName,
        if (allowedDays != null) 'allowedDays': allowedDays,
      },
    ),
  );

  Future<List<Map<String, dynamic>>> timetableVersions(
    String semesterId,
  ) async => _list(
    await _dio.get(
      '/timetable-versions',
      queryParameters: {'semesterId': semesterId},
    ),
  );

  Future<Map<String, dynamic>> createTimetableVersion(
    String semesterId,
    String name,
  ) async => _map(
    await _dio.post(
      '/timetable-versions',
      data: {'semesterId': semesterId, 'name': name},
    ),
  );

  Future<Map<String, dynamic>> publishTimetableVersion(String id) async =>
      _map(await _dio.post('/timetable-versions/$id/publish'));
  Future<List<Map<String, dynamic>>> timetableVersionSlots(String id) async =>
      _list(await _dio.get('/timetable-versions/$id/slots'));
  Future<void> deleteTimetableVersion(String id) async =>
      _dio.delete('/timetable-versions/$id');
  Future<List<Map<String, dynamic>>> teacherLoadRegistrations(
    String semesterId,
  ) async => _list(
    await _dio.get(
      '/teacher-load-registrations',
      queryParameters: {'semesterId': semesterId},
    ),
  );

  Future<List<Map<String, dynamic>>> teachingAssignments({
    String? classId,
    String? subjectId,
    String? teacherId,
    String? semesterId,
    String? dayOfWeek,
    int? periodNo,
  }) async => (await _academicApi.listTeachingAssignments(
    classId: classId,
    subjectId: subjectId,
    teacherId: teacherId,
    semesterId: semesterId,
    dayOfWeek: dayOfWeek,
    periodNo: periodNo,
  )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> createTeachingAssignment(
    Map<String, dynamic> data,
  ) async => (await _academicApi.createTeachingAssignment(
    saveTeachingAssignmentRequest: academic.SaveTeachingAssignmentRequest(
      classId: data['classId'] as String,
      subjectId: data['subjectId'] as String,
      teacherId: data['teacherId'] as String,
      semesterId: data['semesterId'] as String,
      weeklyPeriods: data['weeklyPeriods'] as int,
    ),
  )).data!.toJson();

  Future<List<Map<String, dynamic>>> teacherWorkloads({
    String? semesterId,
  }) async => _list(
    await _dio.get(
      '/teaching-assignments/workloads',
      queryParameters: {if (semesterId != null) 'semesterId': semesterId},
    ),
  );

  Future<Map<String, dynamic>> updateTeachingAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/teaching-assignments/$id', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteTeachingAssignment(String id) async =>
      _dio.delete('/teaching-assignments/$id');

  Future<List<Map<String, dynamic>>> teachingProgress({
    required String semesterId,
    String? classId,
    String? subjectId,
  }) async => _list(
    await _dio.get(
      '/teaching-progress',
      queryParameters: {
        'semesterId': semesterId,
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      },
    ),
  );

  Future<Map<String, dynamic>> saveTeachingProgress(
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/teaching-progress', data: data));

  Future<Map<String, dynamic>> reviewMakeup(
    String id,
    String status,
    String? reviewNote,
  ) async => _map(
    await _dio.put(
      '/teaching-progress/$id/makeup',
      data: {'status': status, 'reviewNote': reviewNote},
    ),
  );

  // ---------- Attendance ----------
  Future<List<Map<String, dynamic>>> attendance({
    String? studentId,
    String? classId,
    String? slotId,
    String? date,
  }) async {
    return _list(
      await _dio.get(
        '/attendance',
        queryParameters: {
          if (studentId != null) 'studentId': studentId,
          if (classId != null) 'classId': classId,
          if (slotId != null) 'slotId': slotId,
          if (date != null) 'date': date,
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> bulkAttendance({
    required String slotId,
    required String date,
    required List<Map<String, dynamic>> marks,
    String? classId,
    String? subjectName,
    int? periodNo,
  }) async {
    const allowedStatuses = {
      'PRESENT',
      'LATE',
      'ABSENT_EXCUSED',
      'ABSENT_UNEXCUSED',
    };
    for (final mark in marks) {
      if (!allowedStatuses.contains('${mark['status'] ?? ''}')) {
        throw ArgumentError.value(
          mark['status'],
          'status',
          'Trạng thái điểm danh không hợp lệ',
        );
      }
    }
    return _list(
      await _dio.post(
        '/attendance/bulk',
        data: {
          'slotId': slotId,
          if (classId != null) 'classId': classId,
          'date': date,
          if (subjectName != null) 'subjectName': subjectName,
          if (periodNo != null) 'periodNo': periodNo,
          'marks': marks,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> attendanceDayStatus(DateTime date) async {
    final holidays = _list(await _dio.get('/school-holidays'));
    final day = DateTime(date.year, date.month, date.day);
    for (final holiday in holidays) {
      final start = DateTime.tryParse('${holiday['date'] ?? ''}');
      final end = DateTime.tryParse(
        '${holiday['endDate'] ?? holiday['date'] ?? ''}',
      );
      if (start == null || end == null) continue;
      if (!day.isBefore(start) && !day.isAfter(end)) {
        return {
          'attendanceRequired': false,
          'title': holiday['name'],
          'reason': holiday['description'],
          'holidayStartDate': holiday['date'],
          'holidayEndDate': holiday['endDate'] ?? holiday['date'],
        };
      }
    }
    return {'attendanceRequired': true};
  }

  Future<Map<String, dynamic>> attendanceSessionStatus({
    required String slotId,
    required DateTime date,
  }) async {
    final rows = await attendance(slotId: slotId, date: _localDate(date));
    return {
      'state': rows.isEmpty ? 'OPEN' : 'COMPLETED',
      'recordedCount': rows.length,
      'date': _localDate(date),
      'slotId': slotId,
    };
  }

  Future<List<Map<String, dynamic>>> approvedLeavesForAttendance({
    required String slotId,
    required DateTime date,
  }) async {
    return _list(
      await _dio.get(
        '/attendance/approved-leaves',
        queryParameters: {'slotId': slotId, 'date': _localDate(date)},
      ),
    );
  }

  Future<Map<String, dynamic>> unlockLateAttendance({
    required String slotId,
    required DateTime date,
    required String reason,
  }) async {
    final response = await _academicApi.unlockLateAttendance(
      unlockAttendanceRequest: academic.UnlockAttendanceRequest(
        slotId: slotId,
        date: date,
        reason: reason,
      ),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> unlockAttendance(
    String slotId,
    String date,
    String reason,
  ) async => _map(
    await _dio.post(
      '/attendance/unlock',
      data: {'slotId': slotId, 'date': date, 'reason': reason},
    ),
  );

  // ---------- Grades ----------
  Future<List<Map<String, dynamic>>> grades({
    String? studentId,
    String? classId,
    String? subjectId,
    String? semesterId,
    String? category,
  }) async {
    return _list(
      await _dio.get(
        studentId == null ? '/grades' : '/students/$studentId/grades',
        queryParameters: {
          if (studentId == null && classId != null) 'classId': classId,
          if (subjectId != null) 'subjectId': subjectId,
          if (semesterId != null) 'semesterId': semesterId,
          if (category != null) 'category': category,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> teacherGradebookContext({
    required String classId,
    required String semesterId,
  }) async {
    final assignments = _list(await _dio.get('/me/teacher-class-subjects'))
        .where(
          (item) =>
              '${item['classId'] ?? ''}' == classId &&
              '${item['semesterId'] ?? ''}' == semesterId,
        )
        .toList(growable: false);
    final subjects = <String, Map<String, dynamic>>{};
    for (final item in assignments) {
      final subjectId = '${item['subjectId'] ?? ''}';
      if (subjectId.isEmpty) continue;
      subjects[subjectId] = {
        'subjectId': subjectId,
        'subjectName': item['subjectName'] ?? subjectId,
        'editable': true,
      };
    }
    final first = subjects.values.firstOrNull;
    return {
      'classId': classId,
      'semesterId': semesterId,
      'homeroomTeacher': false,
      'subjects': subjects.values.toList(growable: false),
      'subjectId': first?['subjectId'],
      'subjectName': first?['subjectName'],
    };
  }

  Future<List<Map<String, dynamic>>> bulkGrades({
    required String classId,
    required String subjectId,
    required String semesterId,
    required String category,
    String? reason,
    required List<Map<String, dynamic>> entries,
    int? assessmentIndex,
  }) async {
    return _list(
      await _dio.post(
        '/grades/bulk',
        data: {
          'subjectId': subjectId,
          'semesterId': semesterId,
          'category': category,
          'assessmentIndex': assessmentIndex ?? 1,
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
          'entries': entries
              .map(
                (entry) => {
                  'studentId': entry['studentId'],
                  'score': entry['score'],
                  if (entry['note'] != null) 'note': entry['note'],
                },
              )
              .toList(growable: false),
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> gradeChangeLogs(String id) async {
    final response = await _academicApi.listGradeChangeLogs(id: id);
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> gradeSummaries({
    String? studentId,
    String? semesterId,
  }) async {
    final values = await Future.wait([
      grades(studentId: studentId, semesterId: semesterId),
      _dio.get('/exam-categories').then(_list),
    ]);
    final rows = values[0];
    final categories = values[1];
    final weights = <String, double>{
      for (final category in categories)
        '${category['code'] ?? ''}':
            (category['weight'] as num?)?.toDouble() ?? 1,
    };
    final requiredCounts = <String, int>{
      for (final category in categories)
        '${category['code'] ?? ''}':
            (category['requiredCount'] as num?)?.toInt() ?? 1,
    };
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final key = '${row['subjectId'] ?? ''}#${row['semesterId'] ?? ''}';
      grouped.putIfAbsent(key, () => []).add(row);
    }
    return grouped.values
        .map((subjectRows) {
          final complete = requiredCounts.entries.every((definition) {
            final indexes = subjectRows
                .where((row) => '${row['category'] ?? ''}' == definition.key)
                .map((row) => (row['assessmentIndex'] as num?)?.toInt() ?? 1)
                .toSet();
            return indexes.length >= definition.value;
          });
          var weightedTotal = 0.0;
          var totalWeight = 0.0;
          for (final row in subjectRows) {
            final score = (row['score'] as num?)?.toDouble();
            final category = '${row['category'] ?? ''}';
            if (score == null || !weights.containsKey(category)) continue;
            final index = (row['assessmentIndex'] as num?)?.toInt() ?? 1;
            if (index > (requiredCounts[category] ?? 1)) continue;
            final weight = weights[category] ?? 1;
            weightedTotal += score * weight;
            totalWeight += weight;
          }
          final rawAverage = complete && totalWeight > 0
              ? weightedTotal / totalWeight
              : null;
          final average = rawAverage == null
              ? null
              : (rawAverage * 10).roundToDouble() / 10;
          final first = subjectRows.first;
          return <String, dynamic>{
            'studentId': first['studentId'],
            'subjectId': first['subjectId'],
            'subjectName': first['subjectName'],
            'semesterId': first['semesterId'],
            'average': average,
          };
        })
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createExamCategory(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/exam-categories', data: data));

  Future<Map<String, dynamic>> updateExamCategory(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/exam-categories/$id', data: data));

  Future<Map<String, dynamic>> saveExamCategory({
    String? id,
    required String code,
    required String name,
    num? weight,
    int? requiredCount,
  }) async {
    final request = academic.SaveExamCategoryRequest(
      id: id,
      code: code,
      name: name,
      weight: weight,
      requiredCount: requiredCount,
    );
    final response = id == null
        ? await _academicApi.createExamCategory(
            saveExamCategoryRequest: request,
          )
        : await _academicApi.updateExamCategory(
            id: id,
            saveExamCategoryRequest: request,
          );
    return response.data!.toJson();
  }

  Future<void> deleteExamCategory(String id) async {
    await _academicApi.deleteExamCategory(id: id);
  }

  Future<Map<String, dynamic>> assignHomeroomTeacher(
    String classId,
    String teacherId,
  ) async {
    final response = await _dio.put(
      '/classes/$classId/homeroom-teacher',
      data: {'teacherId': teacherId},
    );
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> clearHomeroomTeacher(String classId) async {
    final response = await _dio.delete('/classes/$classId/homeroom-teacher');
    return (response.data as Map).cast<String, dynamic>();
  }

  // ---------- Parent ----------
  Future<List<Map<String, dynamic>>> children() async =>
      _list(await _dio.get('/me/children'));

  // Clubs (F13)
  Future<List<Map<String, dynamic>>> clubs() async =>
      _list(await _dio.get('/clubs'));

  Future<Map<String, dynamic>> createClub(Map<String, dynamic> data) async =>
      _map(await _dio.post('/clubs', data: data));

  Future<List<Map<String, dynamic>>> adminClubRegistrations({
    String? clubId,
    String? status,
  }) async {
    final query = <String, dynamic>{};
    if (clubId != null && clubId.isNotEmpty) query['clubId'] = clubId;
    if (status != null && status.isNotEmpty) query['status'] = status;
    return _list(
      await _dio.get('/admin/club-registrations', queryParameters: query),
    );
  }

  Future<Map<String, dynamic>> approveClubRegistration(
    String registrationId, {
    String? note,
  }) async => _map(
    await _dio.post(
      '/club-registrations/$registrationId/approve',
      data: {'note': note ?? 'Duyệt từ ứng dụng mobile'},
    ),
  );

  Future<Map<String, dynamic>> rejectClubRegistration(
    String registrationId, {
    String? note,
  }) async => _map(
    await _dio.post(
      '/club-registrations/$registrationId/reject',
      data: {'note': note ?? 'Từ chối từ ứng dụng mobile'},
    ),
  );

  Future<List<Map<String, dynamic>>> myClubRegistrations() async =>
      _list(await _dio.get('/me/club-registrations'));

  Future<List<Map<String, dynamic>>> childClubRegistrations(
    String studentId,
  ) async => _list(
    await _dio.get(
      '/me/club-registrations',
      queryParameters: {'studentId': studentId},
    ),
  );

  Future<Map<String, dynamic>> registerClub(
    String clubId, {
    String? studentId,
  }) async {
    return _map(
      await _dio.post(
        '/clubs/$clubId/register',
        data: studentId == null
            ? <String, dynamic>{}
            : {'studentId': studentId},
      ),
    );
  }

  Future<Map<String, dynamic>> cancelClubRegistration(
    String registrationId, {
    String? reason,
  }) async =>
      _map(await _dio.post('/club-registrations/$registrationId/cancel'));

  Future<List<Map<String, dynamic>>> invoices({
    String? studentId,
    String? status,
    String? feePeriodId,
    String? classId,
    String? gradeLevel,
    String? query,
  }) async {
    final response = await _financeApi.listInvoices(
      studentId: studentId,
      status: status == null ? null : _invoiceStatus(status),
      periodId: feePeriodId,
      classId: classId,
      gradeLevel: gradeLevel,
      q: query,
    );
    return response.data!.map((invoice) => invoice.toJson()).toList();
  }

  InvoiceStatus _invoiceStatus(String value) => InvoiceStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => throw ArgumentError.value(
      value,
      'status',
      'Trạng thái hóa đơn không hợp lệ',
    ),
  );

  Future<Map<String, dynamic>> invoiceDetail(String id) async {
    final response = await _financeApi.getInvoiceDetail(invoiceId: id);
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> pay(
    String invoiceId, {
    String method = 'MB_BANK_TRANSFER',
  }) async {
    if (!const {'MB_BANK_TRANSFER', 'VNPAY', 'MOMO'}.contains(method)) {
      throw ArgumentError.value(method, 'method', 'Phương thức không hợp lệ');
    }
    return _map(
      await _dio.post(
        '/payments',
        data: {'invoiceId': invoiceId, 'method': method},
      ),
    );
  }

  Future<Map<String, dynamic>> recordCashPayment(
    String invoiceId, {
    int? amount,
    String? payerName,
    String? note,
  }) async {
    final response = await _financeApi.recordCashPayment(
      cashPaymentRequest: CashPaymentRequest(
        invoiceId: invoiceId,
        amount: amount,
        payerName: payerName?.trim().isEmpty == true ? null : payerName?.trim(),
        note: note?.trim().isEmpty == true ? null : note?.trim(),
      ),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> refundInvoice(
    String invoiceId,
    int amount,
    String reason,
  ) async {
    final response = await _financeApi.refundInvoice(
      invoiceId: invoiceId,
      refundInvoiceRequest: RefundInvoiceRequest(
        amount: amount,
        reason: reason,
      ),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> submitPaymentProof({
    required String paymentId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final file = await uploadFile(
      bytes: bytes,
      fileName: fileName,
      scope: 'PAYMENT_PROOF',
    );
    return _map(
      await _dio.post(
        '/payments/$paymentId/proofs',
        data: {'fileId': file['id']},
      ),
    );
  }

  Future<List<Map<String, dynamic>>> pendingVietQrPayments() async {
    final response = await _financeApi.listPendingVietQrPayments();
    return response.data!.map((item) => item.toJson()).toList();
  }

  Future<Map<String, dynamic>> confirmVietQrPayment(
    String paymentId,
    String bankTransactionRef,
  ) async {
    final response = await _financeApi.confirmVietQrPayment(
      paymentId: paymentId,
      vietQrConfirmationRequest: VietQrConfirmationRequest(
        bankTransactionRef: bankTransactionRef,
      ),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> rejectVietQrPayment(String paymentId) async {
    final response = await _financeApi.rejectVietQrPayment(
      paymentId: paymentId,
    );
    return response.data!.toJson();
  }

  // ---------- Notifications / Announcements ----------
  Future<List<Map<String, dynamic>>> notifications({
    int page = 0,
    int size = 100,
    bool unread = false,
  }) async {
    final response = await _dio.get(
      '/notifications/page',
      queryParameters: {
        'page': page,
        'size': size,
        'read': unread ? 'UNREAD' : 'ALL',
      },
    );
    final data = response.data;
    if (data is! Map) return const [];
    final items = data['items'];
    return items is List
        ? items
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .toList()
        : const [];
  }

  Future<int> notificationUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotiRead(String id) async =>
      _dio.post('/notifications/$id/read');
  Future<void> markAllNotificationsRead() async =>
      _dio.post('/notifications/read-all');
  Future<List<Map<String, dynamic>>> notificationPreferences() async =>
      _list(await _dio.get('/me/notification-preferences'));
  Future<void> updateNotificationPreference(
    String channel,
    bool enabled,
  ) async => _dio.put(
    '/me/notification-preferences',
    data: {'channel': channel, 'enabled': enabled},
  );
  Future<List<Map<String, dynamic>>> announcements() async =>
      _list(await _dio.get('/announcements'));
  Future<List<Map<String, dynamic>>> teacherAnnouncementScopes() async =>
      _list(await _dio.get('/teacher/announcements/scopes'));
  Future<List<Map<String, dynamic>>> teacherAnnouncements() async =>
      _list(await _dio.get('/teacher/announcements'));
  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/announcements', data: data));
  Future<Map<String, dynamic>> sendTeacherAnnouncement({
    required String classId,
    required String target,
    required String category,
    required String priority,
    required String title,
    required String body,
    String? idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/announcements',
      data: {
        'audience': '$target:$classId',
        'category': category,
        'priority': priority,
        'title': title,
        'body': body,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      },
    );
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> previewTeacherAnnouncement({
    required String classId,
    required String target,
    required String category,
  }) async {
    final response = await _dio.post(
      '/announcements/preview',
      data: {'audience': '$target:$classId', 'category': category},
    );
    return (response.data as Map).cast<String, dynamic>();
  }

  // ---------- Chat (B6/D3) ----------
  Future<List<Map<String, dynamic>>> chatThreads() async =>
      _list(await _dio.get('/chat/threads'));
  Future<List<Map<String, dynamic>>> chatContacts() async =>
      _list(await _dio.get('/chat/contacts'));
  Future<List<Map<String, dynamic>>> teachingClasses() async =>
      _list(await _dio.get('/me/teaching-classes'));
  Future<void> broadcastToClass(
    String classId,
    String title,
    String body,
  ) async => sendTeacherAnnouncement(
    classId: classId,
    target: 'CLASS_ALL',
    category: 'STUDENT_STATUS',
    priority: 'NORMAL',
    title: title,
    body: body,
    idempotencyKey: 'class-$classId-${DateTime.now().microsecondsSinceEpoch}',
  );
  Future<List<Map<String, dynamic>>> chatMessages(
    String withUserId, {
    int page = 0,
    int size = 100,
  }) async {
    return _list(
      await _dio.get(
        '/chat/messages',
        queryParameters: {'withUserId': withUserId},
      ),
    );
  }

  Future<Map<String, dynamic>> sendChat(String toUserId, String body) async {
    final r = await _dio.post(
      '/chat/messages',
      data: {'toUserId': toUserId, 'body': body},
    );
    return (r.data as Map).cast<String, dynamic>();
  }

  // ---------- Assignments ----------
  Future<List<Map<String, dynamic>>> myAssignments() async =>
      _list(await _dio.get('/me/assignments'));
  Future<List<Map<String, dynamic>>> mySubmissions() async =>
      _list(await _dio.get('/me/submissions'));
  Future<List<Map<String, dynamic>>> childAssignments(String studentId) async =>
      _list(await _dio.get('/me/children/$studentId/assignments'));
  Future<List<Map<String, dynamic>>> teacherAssignments() async =>
      _list(await _dio.get('/assignments'));
  Future<Map<String, dynamic>> createAssignment(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/assignments', data: data));
  Future<List<Map<String, dynamic>>> assignmentSubmissions(String id) async =>
      _list(await _dio.get('/assignments/$id/submissions'));
  Future<Map<String, dynamic>> submitAssignment(
    String id, {
    String? content,
    String? attachmentFileId,
  }) async {
    final r = await _dio.post(
      '/assignments/$id/submit',
      data: {'content': content, 'attachmentFileId': attachmentFileId},
    );
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> gradeSubmission(
    String id, {
    required double score,
    String? feedback,
  }) async => _map(
    await _dio.post(
      '/submissions/$id/grade',
      data: {'score': score, 'feedback': feedback},
    ),
  );

  Future<Map<String, dynamic>> allowResubmit(String id) async => _map(
    await _dio.post(
      '/submissions/$id/request-resubmission',
      data: {'reason': 'Cho phép học sinh nộp lại theo phản hồi của giáo viên'},
    ),
  );

  Future<Map<String, dynamic>> publishAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/publish'));

  Future<Map<String, dynamic>> uploadFile({
    required List<int> bytes,
    required String fileName,
    String scope = 'SUBMISSION',
  }) async {
    final contentType = _fileMediaType(fileName).toString();
    final presigned = _map(
      await _dio.post(
        '/files/presigned-upload',
        data: {
          'scope': scope,
          'fileName': fileName,
          'contentType': contentType,
          'sizeBytes': bytes.length,
        },
      ),
    );
    await _dio.put<void>(
      '${presigned['uploadUrl']}',
      data: Stream.fromIterable([Uint8List.fromList(bytes)]),
      options: Options(
        contentType: contentType,
        headers: {Headers.contentLengthHeader: bytes.length},
      ),
    );
    return _map(await _dio.post('/files/${presigned['id']}/complete'));
  }

  MediaType _fileMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.doc')) return MediaType('application', 'msword');
    if (lower.endsWith('.docx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    if (lower.endsWith('.xls')) {
      return MediaType('application', 'vnd.ms-excel');
    }
    if (lower.endsWith('.xlsx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
    return MediaType('text', 'plain');
  }

  Future<List<int>> downloadFile(String id) async {
    final presigned = _map(await _dio.post('/files/$id/presigned-download'));
    final response = await _dio.get<List<int>>(
      '${presigned['downloadUrl']}',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  // ---------- Xin nghỉ học ----------
  Future<List<Map<String, dynamic>>> leaveRequests() async =>
      _list(await _dio.get('/attendance/excuse-requests'));

  Future<Map<String, dynamic>> createLeaveRequest({
    required String startDate,
    required String endDate,
    required String reason,
  }) async => _map(
    await _dio.post(
      '/leave-requests',
      data: {'startDate': startDate, 'endDate': endDate, 'reason': reason},
    ),
  );

  Future<Map<String, dynamic>> decideLeaveRequest(
    String id,
    String action, {
    String? note,
  }) async => _map(
    await _dio.post(
      '/attendance/excuse-requests/$id/review',
      data: {
        'decision': action == 'approve' ? 'APPROVED' : 'REJECTED',
        if (note != null) 'note': note,
      },
    ),
  );

  // ---------- Khảo thí ----------
  Future<List<Map<String, dynamic>>> examPeriods() async =>
      (await _academicApi.listExamPeriods()).data!
          .map((item) => item.toJson())
          .toList();

  Future<Map<String, dynamic>> createExamPeriod(
    Map<String, dynamic> data,
  ) async => _map(await _dio.post('/exam-periods', data: data));

  Future<Map<String, dynamic>> autoPlanExam(
    String periodId, {
    required List<String> subjectIds,
    required String startTime,
    required int durationMinutes,
    required bool apply,
    required String idempotencyKey,
  }) async => _map(
    await _dio.post(
      '/exam-periods/$periodId/auto-plan',
      data: {
        'subjectIds': subjectIds,
        'startTime': startTime,
        'durationMinutes': durationMinutes,
        'apply': apply,
        'idempotencyKey': idempotencyKey,
      },
    ),
  );

  Future<Map<String, dynamic>> saveExamPeriod({
    String? id,
    required String code,
    required String name,
    required String academicYearId,
    required String semesterId,
    String? gradeLevel,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final request = academic.SaveExamPeriodRequest(
      code: code,
      name: name,
      academicYearId: academicYearId,
      semesterId: semesterId,
      gradeLevel: gradeLevel,
      startDate: startDate,
      endDate: endDate,
    );
    final response = id == null
        ? await _academicApi.createExamPeriod(saveExamPeriodRequest: request)
        : await _academicApi.updateExamPeriod(
            id: id,
            saveExamPeriodRequest: request,
          );
    return response.data!.toJson();
  }

  Future<void> deleteExamPeriod(String id) async {
    await _academicApi.deleteExamPeriod(id: id);
  }

  Future<Map<String, dynamic>> publishExamSchedule(String periodId) async =>
      (await _academicApi.publishExamSchedule(id: periodId)).data!.toJson();

  Future<List<Map<String, dynamic>>> examSchedules(String periodId) async =>
      (await _academicApi.listExamSchedules(
        id: periodId,
      )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> saveExamSchedule({
    String? id,
    required String periodId,
    required String subjectId,
    required List<String> classIds,
    required DateTime examDate,
    required String startTime,
    required int durationMinutes,
    String? notes,
  }) async {
    final request = academic.SaveExamScheduleRequest(
      subjectId: subjectId,
      classIds: classIds.toSet(),
      examDate: examDate,
      startTime: startTime,
      durationMinutes: durationMinutes,
      notes: notes,
    );
    final response = id == null
        ? await _academicApi.createExamSchedule(
            id: periodId,
            saveExamScheduleRequest: request,
          )
        : await _academicApi.updateExamSchedule(
            id: id,
            saveExamScheduleRequest: request,
          );
    return response.data!.toJson();
  }

  Future<void> deleteExamSchedule(String id) async {
    await _academicApi.deleteExamSchedule(id: id);
  }

  Future<List<Map<String, dynamic>>> examRooms(String scheduleId) async =>
      (await _academicApi.listExamRooms(
        id: scheduleId,
      )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> createExamRoom({
    required String scheduleId,
    required String roomCode,
    required int capacity,
    String? proctorOneId,
    String? proctorTwoId,
  }) async => (await _academicApi.createExamRoom(
    id: scheduleId,
    saveExamRoomRequest: academic.SaveExamRoomRequest(
      roomCode: roomCode,
      capacity: capacity,
      proctorOneId: proctorOneId,
      proctorTwoId: proctorTwoId,
    ),
  )).data!.toJson();

  Future<Map<String, dynamic>> saveExamRoom(
    String scheduleId,
    Map<String, dynamic> data,
  ) async =>
      _map(await _dio.post('/exam-schedules/$scheduleId/rooms', data: data));

  Future<List<Map<String, dynamic>>> allocateExamCandidates({
    required String roomId,
    required String classId,
  }) async => (await _academicApi.allocateExamCandidates(
    id: roomId,
    allocateExamCandidatesRequest: academic.AllocateExamCandidatesRequest(
      classId: classId,
    ),
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> examCandidates(
    String periodId,
    String scheduleId,
  ) async => _list(
    await _dio.get(
      '/exam-periods/$periodId/candidates',
      queryParameters: {'scheduleId': scheduleId},
    ),
  );

  Future<List<Map<String, dynamic>>> eligibleExamGraders(
    String scheduleId,
  ) async => (await _academicApi.listEligibleExamGraders(
    id: scheduleId,
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> examGraders(String scheduleId) async =>
      (await _academicApi.listExamGraders(
        id: scheduleId,
      )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> saveExamGrader({
    required String scheduleId,
    required String classId,
    required String teacherId,
  }) async => (await _academicApi.saveExamGrader(
    id: scheduleId,
    saveExamGraderRequest: academic.SaveExamGraderRequest(
      classId: classId,
      teacherId: teacherId,
    ),
  )).data!.toJson();

  Future<List<Map<String, dynamic>>> examAgenda({String? childId}) async =>
      _list(
        await _dio.get(
          childId == null
              ? '/exam-periods/me/schedule'
              : '/exam-periods/students/$childId/schedule',
        ),
      );

  Future<List<Map<String, dynamic>>> examResults() async =>
      _examGradeResults(await grades());

  Future<List<Map<String, dynamic>>> childExamResults(String studentId) async =>
      _examGradeResults(await grades(studentId: studentId));

  List<Map<String, dynamic>> _examGradeResults(
    List<Map<String, dynamic>> rows,
  ) => rows
      .where((row) => const {'MID', 'FINAL'}.contains('${row['category']}'))
      .map(
        (row) => <String, dynamic>{
          ...row,
          'resultId': row['id'],
          'status': 'PUBLISHED',
          'examName': row['categoryName'] ?? row['category'],
        },
      )
      .toList(growable: false);

  Future<Map<String, dynamic>> lockExamScores(String periodId) async =>
      (await _academicApi.lockExamScores(id: periodId)).data!.toJson();

  Future<Map<String, dynamic>> unlockExamScores(String periodId) async =>
      (await _academicApi.unlockExamScores(id: periodId)).data!.toJson();

  Future<Map<String, dynamic>> confirmExamPeriod(String periodId) async =>
      (await _academicApi.confirmExamPeriod(id: periodId)).data!.toJson();

  Future<List<Map<String, dynamic>>> examPeriodResults(
    String periodId, {
    String? scheduleId,
    String? studentId,
  }) async => (await _academicApi.listExamResults(
    id: periodId,
    scheduleId: scheduleId,
    studentId: studentId,
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> examPeriodReviews(
    String periodId, {
    String? status,
  }) async => (await _academicApi.listExamReviews(
    id: periodId,
    status: status,
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> examScoreAdjustments(
    String periodId,
  ) async => (await _academicApi.listExamScoreAdjustments(
    id: periodId,
  )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> promotionPreview(String yearId) async =>
      (await _academicApi.getPromotionPreview(
        id: yearId,
      )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> yearRolloverPreview(String yearId) async =>
      (await _academicApi.getYearRolloverPreview(id: yearId)).data!.toJson();

  Future<Map<String, dynamic>> rolloverAcademicYear({
    required String yearId,
    required String nextYearCode,
    String? nextYearName,
    required DateTime startDate,
    required DateTime endDate,
    bool createIntakeClasses = true,
    bool activateNextYear = true,
  }) async => (await _academicApi.rolloverAcademicYear(
    id: yearId,
    yearRolloverRequest: academic.YearRolloverRequest(
      nextYearCode: nextYearCode,
      nextYearName: nextYearName,
      startDate: startDate,
      endDate: endDate,
      createIntakeClasses: createIntakeClasses,
      activateNextYear: activateNextYear,
    ),
  )).data!.toJson();

  Future<List<Map<String, dynamic>>> homeroomYearlySummaries(
    String yearId,
  ) async => (await _academicApi.getHomeroomYearlySummaries(
    id: yearId,
  )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> setStudentConduct({
    required String yearId,
    required String studentId,
    required String conductGrade,
  }) async => (await _academicApi.setStudentConduct(
    id: yearId,
    studentId: studentId,
    conductRequest: academic.ConductRequest(
      conductGrade: academic.ConductRequestConductGradeEnum.values.firstWhere(
        (item) => item.value == conductGrade,
      ),
    ),
  )).data!.toJson();

  Future<Map<String, dynamic>> myYearlySummary(String yearId) async =>
      (await _academicApi.getMyYearlySummary(id: yearId)).data!.toJson();

  Future<Map<String, dynamic>> childYearlySummary(
    String yearId,
    String studentId,
  ) async => (await _academicApi.getChildYearlySummary(
    id: yearId,
    studentId: studentId,
  )).data!.toJson();
}
