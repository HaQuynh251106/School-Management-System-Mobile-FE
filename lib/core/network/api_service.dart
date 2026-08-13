import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sse_finance_api/sse_finance_api.dart';
import 'package:sse_identity_api/sse_identity_api.dart' as identity;
import 'package:sse_academic_api/sse_academic_api.dart' as academic;
import 'package:sse_report_api/sse_report_api.dart' as report;

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

  academic.AttendanceStatus _attendanceStatus(Object? value) =>
      academic.AttendanceStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => throw ArgumentError.value(
          value,
          'status',
          'Trang thai diem danh khong hop le',
        ),
      );

  Future<Map<String, dynamic>> dashboard({String? childId}) async {
    final response = await _reportApi.getDashboard(childId: childId);
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> personalReport({String? childId}) async {
    final response = await _reportApi.getPersonalReport(childId: childId);
    return response.data!.toJson();
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
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        teacherCode: data['teacherCode'] as String?,
        mainSubject: data['mainSubject'] as String?,
        studentCode: data['studentCode'] as String?,
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

  // ---------- Timetable ----------
  Future<List<Map<String, dynamic>>> myTimetable() async =>
      (await _academicApi.getMyTimetable()).data!
          .map((item) => item.toJson())
          .toList();
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
    List<String>? allowedDays,
  }) async => _map(
    await _dio.post(
      '/timetableSlots/auto-plan',
      data: {
        'semesterId': semesterId,
        'apply': apply,
        'allowPartial': false,
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

  // ---------- Attendance ----------
  Future<List<Map<String, dynamic>>> attendance({
    String? studentId,
    String? classId,
    String? slotId,
    String? date,
  }) async {
    final response = await _academicApi.listAttendance(
      studentId: studentId,
      classId: classId,
      slotId: slotId,
      date: date == null ? null : DateTime.parse(date),
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> bulkAttendance({
    required String slotId,
    required String date,
    required List<Map<String, dynamic>> marks,
    String? classId,
    String? subjectName,
    int? periodNo,
  }) async {
    final response = await _academicApi.bulkMarkAttendance(
      bulkAttendanceRequest: academic.BulkAttendanceRequest(
        slotId: slotId,
        classId: classId,
        date: DateTime.parse(date),
        subjectName: subjectName,
        periodNo: periodNo,
        marks: marks
            .map(
              (mark) => academic.AttendanceMark(
                studentId: mark['studentId'] as String,
                status: _attendanceStatus(mark['status']),
                note: mark['note'] as String?,
              ),
            )
            .toList(),
      ),
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<Map<String, dynamic>> attendanceDayStatus(DateTime date) async {
    final response = await _academicApi.getAttendanceDayStatus(date: date);
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> attendanceSessionStatus({
    required String slotId,
    required DateTime date,
  }) async {
    final response = await _academicApi.getAttendanceSessionStatus(
      slotId: slotId,
      date: date,
    );
    return response.data!.toJson();
  }

  Future<List<Map<String, dynamic>>> approvedLeavesForAttendance({
    required String slotId,
    required DateTime date,
  }) async {
    final response = await _academicApi.listApprovedLeavesForAttendance(
      slotId: slotId,
      date: date,
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
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

  // ---------- Grades ----------
  Future<List<Map<String, dynamic>>> grades({
    String? studentId,
    String? classId,
    String? subjectId,
    String? semesterId,
    String? category,
  }) async {
    final response = await _academicApi.listGrades(
      studentId: studentId,
      classId: classId,
      subjectId: subjectId,
      semesterId: semesterId,
      category: category,
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<Map<String, dynamic>> teacherGradebookContext({
    required String classId,
    required String semesterId,
  }) async {
    final response = await _academicApi.getTeacherGradebookContext(
      classId: classId,
      semesterId: semesterId,
    );
    return response.data!.toJson();
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
    final response = await _academicApi.bulkUpsertGrades(
      bulkGradeRequest: academic.BulkGradeRequest(
        classId: classId,
        subjectId: subjectId,
        semesterId: semesterId,
        category: category,
        assessmentIndex: assessmentIndex,
        reason: reason,
        entries: entries
            .map(
              (entry) => academic.GradeEntry(
                studentId: entry['studentId'] as String,
                score: entry['score'] as num,
                note: entry['note'] as String?,
                expectedVersion: entry['expectedVersion'] as int?,
              ),
            )
            .toList(),
      ),
    );
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

  Future<Map<String, dynamic>> createGrade({
    required String studentId,
    String? subjectId,
    required String semesterId,
    required String category,
    int? assessmentIndex,
    required num score,
    String? note,
  }) async {
    final response = await _academicApi.createGrade(
      createGradeRequest: academic.CreateGradeRequest(
        studentId: studentId,
        subjectId: subjectId,
        semesterId: semesterId,
        category: category,
        assessmentIndex: assessmentIndex,
        score: score,
        note: note,
      ),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> updateGrade({
    required String id,
    required num score,
    String? note,
    required String reason,
    int? expectedVersion,
  }) async {
    final response = await _academicApi.updateGrade(
      id: id,
      updateGradeRequest: academic.UpdateGradeRequest(
        score: score,
        note: note,
        reason: reason,
        expectedVersion: expectedVersion,
      ),
    );
    return response.data!.toJson();
  }

  Future<List<Map<String, dynamic>>> gradeChangeLogs(String id) async {
    final response = await _academicApi.listGradeChangeLogs(id: id);
    return (response.data ?? const []).map((item) => item.toJson()).toList();
  }

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
  ) async => _list(await _dio.get('/children/$studentId/club-registrations'));

  Future<Map<String, dynamic>> registerClub(
    String clubId, {
    String? studentId,
  }) async {
    return _map(
      await _dio.post(
        '/clubs/$clubId/registrations',
        data: studentId == null
            ? <String, dynamic>{}
            : {'studentId': studentId},
      ),
    );
  }

  Future<Map<String, dynamic>> cancelClubRegistration(
    String registrationId, {
    String? reason,
  }) async => _map(
    await _dio.post(
      '/club-registrations/$registrationId/cancel',
      data: {'reason': reason ?? 'Hủy từ ứng dụng mobile'},
    ),
  );

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
    String method = 'VIETQR',
  }) async {
    if (method != 'VIETQR') {
      throw ArgumentError.value(method, 'method', 'Chỉ hỗ trợ VIETQR');
    }
    final response = await _financeApi.createVietQrPayment(
      payRequest: PayRequest(invoiceId: invoiceId),
    );
    return response.data!.toJson();
  }

  Future<Map<String, dynamic>> createSandboxPayment(
    String invoiceId,
    String idempotencyKey,
  ) async {
    final result = _map(
      await _dio.post(
        '/payments',
        data: {
          'invoiceId': invoiceId,
          'method': 'SANDBOX',
          'idempotencyKey': idempotencyKey,
        },
      ),
    );
    final gatewayUri = Uri.tryParse((result['paymentUrl'] ?? '').toString());
    final apiUri = Uri.tryParse(_dio.options.baseUrl);
    if (gatewayUri != null && apiUri != null && apiUri.host.isNotEmpty) {
      result['paymentUrl'] = gatewayUri
          .replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.hasPort ? apiUri.port : null,
          )
          .toString();
    }
    return result;
  }

  Future<Map<String, dynamic>> sandboxPaymentStatus(String paymentId) async =>
      _map(await _dio.get('/payments/$paymentId/status'));

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

  Future<Map<String, dynamic>> markVietQrSubmitted(String paymentId) async {
    final response = await _financeApi.markVietQrSubmitted(
      paymentId: paymentId,
    );
    return response.data!.toJson();
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
  Future<List<Map<String, dynamic>>> notifications() async =>
      _list(await _dio.get('/notifications'));
  Future<int> notificationUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotiRead(String id) async =>
      _dio.post('/notifications/$id/read');
  Future<List<Map<String, dynamic>>> notificationPreferences() async =>
      _list(await _dio.get('/notification-preferences'));
  Future<void> updateNotificationPreference(
    String channel,
    bool enabled,
  ) async => _dio.put(
    '/notification-preferences',
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
  Future<List<Map<String, dynamic>>> chatMessages(String withUserId) async =>
      _list(
        await _dio.get(
          '/chat/messages',
          queryParameters: {'withUserId': withUserId},
        ),
      );
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
      _list(await _dio.get('/children/$studentId/assignments'));
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

  Future<Map<String, dynamic>> allowResubmit(String id) async =>
      _map(await _dio.post('/submissions/$id/allow-resubmit'));

  Future<Map<String, dynamic>> publishAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/publish'));

  Future<Map<String, dynamic>> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async => _map(await _dio.put('/assignments/$id', data: data));

  Future<Map<String, dynamic>> extendAssignment(
    String id,
    DateTime deadline,
  ) async => _map(
    await _dio.post(
      '/assignments/$id/extend',
      data: {'deadline': deadline.toUtc().toIso8601String()},
    ),
  );

  Future<Map<String, dynamic>> closeAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/close'));

  Future<Map<String, dynamic>> reopenAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/reopen'));

  Future<Map<String, dynamic>> uploadFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final data = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: _fileMediaType(fileName),
      ),
    });
    return _map(await _dio.post('/files', data: data));
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
    final response = await _dio.get<List<int>>(
      '/files/$id/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  // ---------- Xin nghỉ học ----------
  Future<List<Map<String, dynamic>>> leaveRequests() async =>
      _list(await _dio.get('/leave-requests'));

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
      '/leave-requests/$id/$action',
      data: {if (note != null) 'note': note},
    ),
  );

  // ---------- Khảo thí ----------
  Future<List<Map<String, dynamic>>> examPeriods() async =>
      (await _academicApi.listExamPeriods()).data!
          .map((item) => item.toJson())
          .toList();

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

  Future<List<Map<String, dynamic>>> allocateExamCandidates({
    required String roomId,
    required String classId,
  }) async => (await _academicApi.allocateExamCandidates(
    id: roomId,
    allocateExamCandidatesRequest: academic.AllocateExamCandidatesRequest(
      classId: classId,
    ),
  )).data!.map((item) => item.toJson()).toList();

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
      (await _academicApi.getMyExamAgenda(
        childId: childId,
      )).data!.map((item) => item.toJson()).toList();

  Future<List<Map<String, dynamic>>> examGradingTasks() async =>
      (await _academicApi.getMyExamGradingTasks()).data!
          .map((item) => item.toJson())
          .toList();

  Future<List<Map<String, dynamic>>> examResults() async =>
      (await _academicApi.getMyExamResults()).data!
          .map((item) => item.toJson())
          .toList();

  Future<List<Map<String, dynamic>>> examReviews({String? status}) async =>
      (await _academicApi.getMyExamReviews(
        status: status,
      )).data!.map((item) => item.toJson()).toList();

  Future<Map<String, dynamic>> requestExamReview(
    String periodId, {
    required String resultId,
    required String reason,
  }) async => (await _academicApi.requestExamReview(
    id: periodId,
    createExamReviewRequest: academic.CreateExamReviewRequest(
      resultId: resultId,
      reason: reason,
    ),
  )).data!.toJson();

  Future<List<Map<String, dynamic>>> saveExamResults({
    required String periodId,
    required String scheduleId,
    required List<Map<String, dynamic>> entries,
  }) async => (await _academicApi.saveExamResults(
    id: periodId,
    saveExamResultsRequest: academic.SaveExamResultsRequest(
      scheduleId: scheduleId,
      entries: entries
          .map(
            (entry) => academic.ExamResultEntry(
              studentId: entry['studentId'].toString(),
              score: entry['score'] as num?,
              note: entry['note']?.toString(),
              expectedVersion: entry['expectedVersion'] as int?,
            ),
          )
          .toList(),
    ),
  )).data!.map((item) => item.toJson()).toList();

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

  Future<Map<String, dynamic>> resolveExamReview(
    String reviewId, {
    required bool approved,
    required String resolution,
    double? resolvedScore,
  }) async => (await _academicApi.resolveExamReview(
    id: reviewId,
    resolveExamReviewRequest: academic.ResolveExamReviewRequest(
      status: approved
          ? academic.ResolveExamReviewRequestStatusEnum.APPROVED
          : academic.ResolveExamReviewRequestStatusEnum.REJECTED,
      resolution: resolution,
      resolvedScore: resolvedScore,
    ),
  )).data!.toJson();

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
