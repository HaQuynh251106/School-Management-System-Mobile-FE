import 'package:dio/dio.dart';
import 'dart:typed_data';

import '../../features/timetable/data/timetable_slot.dart';

/// Lớp gọi API SSE backend (Spring Boot, :4000) dùng Dio đã gắn interceptor JWT.
/// Trả JSON thô (List/Map dynamic) để các trang đọc field trực tiếp — gọn, ít model.
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  List<Map<String, dynamic>> _list(Response r) =>
      (r.data as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _map(Response r) =>
      (r.data as Map).cast<String, dynamic>();

  Future<Map<String, dynamic>> dashboard({String? childId}) async =>
      _map(await _dio.get('/dashboard', queryParameters: {
        if (childId != null) 'childId': childId,
      }));

  Future<Map<String, dynamic>> auditLogsPage({
    String? query,
    int page = 0,
    int size = 50,
  }) async =>
      _map(await _dio.get('/audit-logs/page', queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'page': page,
        'size': size,
      }));

  Future<Map<String, dynamic>> personalReport({String? childId}) async =>
      _map(await _dio.get('/me/reports', queryParameters: {
        if (childId != null) 'childId': childId,
      }));

  Future<Map<String, dynamic>> updateProfile(
          Map<String, dynamic> profile) async =>
      _map(await _dio.put('/me/profile', data: profile));

  Future<void> changePassword(
          String currentPassword, String newPassword) async =>
      _dio.put('/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  // ---------- Admin: users ----------
  Future<List<Map<String, dynamic>>> users(
      {String? role, String? q, String? classId}) async {
    final p = <String, dynamic>{};
    if (role != null) p['role'] = role;
    if (q != null) p['q'] = q;
    if (classId != null) p['classId'] = classId;
    return _list(await _dio.get('/users', queryParameters: p));
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async =>
      _map(await _dio.post('/users', data: data));

  Future<void> lockUser(String id) async => _dio.post('/users/$id/lock');
  Future<void> unlockUser(String id) async => _dio.post('/users/$id/unlock');
  Future<Map<String, dynamic>> user(String id) async =>
      (await _dio.get('/users/$id')).data.cast<String, dynamic>();
  Future<Map<String, dynamic>> resetUserPassword(String id) async =>
      (await _dio.post('/users/$id/reset-password'))
          .data
          .cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> loginHistory(String id) async =>
      _list(await _dio.get('/users/$id/login-history'));
  Future<List<Map<String, dynamic>>> userChildren(String id) async =>
      _list(await _dio.get('/users/$id/children'));

  Future<Map<String, dynamic>> previewUserImport(
          Uint8List bytes, String filename) async =>
      _map(await _dio.post('/users/import/preview',
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes(bytes, filename: filename),
          })));

  Future<Map<String, dynamic>> commitUserImport(
    Uint8List bytes,
    String filename,
    String token, {
    String strategy = 'ALL_OR_NOTHING',
  }) async =>
      _map(await _dio.post('/users/import/commit',
          queryParameters: {'token': token, 'strategy': strategy},
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes(bytes, filename: filename),
          })));

  Future<Uint8List> userImportTemplate() async {
    final response = await _dio.get<List<int>>('/users/import-template',
        options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(response.data ?? const []);
  }

  // ---------- Admin: structure extras ----------
  Future<List<Map<String, dynamic>>> academicYears() async =>
      _list(await _dio.get('/academicYears'));
  Future<List<Map<String, dynamic>>> rooms() async =>
      _list(await _dio.get('/rooms'));
  Future<List<Map<String, dynamic>>> promotionPreview(String yearId) async =>
      _list(await _dio.get('/academic-years/$yearId/promotion-preview'));
  Future<void> setConduct(
          String yearId, String studentId, String conductGrade) async =>
      _dio.put('/academic-years/$yearId/students/$studentId/conduct',
          data: {'conductGrade': conductGrade});
  Future<List<Map<String, dynamic>>> finalizeYear(String yearId) async =>
      _list(await _dio.post('/academic-years/$yearId/finalize'));

  // ---------- Admin: finance / templates ----------
  Future<List<Map<String, dynamic>>> feePeriods() async =>
      _list(await _dio.get('/fee-periods'));
  Future<Map<String, dynamic>> createFeePeriod(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/fee-periods', data: data));
  Future<Map<String, dynamic>> financeOverview(
          {String? grade, String? classId, String? feePeriodId}) async =>
      _map(await _dio.get('/finance/overview', queryParameters: {
        if (grade != null) 'grade': grade,
        if (classId != null) 'classId': classId,
        if (feePeriodId != null) 'feePeriodId': feePeriodId,
      }));
  Future<List<Map<String, dynamic>>> generateInvoices(
          String feePeriodId) async =>
      _list(await _dio.post('/fee-periods/$feePeriodId/generate-invoices'));
  Future<List<Map<String, dynamic>>> notificationTemplates() async =>
      _list(await _dio.get('/notification-templates'));
  Future<Map<String, dynamic>> saveNotificationTemplate(
          Map<String, dynamic> data) async =>
      data['id'] == null
          ? _map(await _dio.post('/notification-templates', data: data))
          : _map(await _dio.put('/notification-templates/${data['id']}',
              data: data));

  // ---------- Academic structure ----------
  Future<List<Map<String, dynamic>>> classes() async =>
      _list(await _dio.get('/classes'));
  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async =>
      _map(await _dio.post('/classes', data: data));
  Future<List<Map<String, dynamic>>> subjects() async =>
      _list(await _dio.get('/subjects'));
  Future<Map<String, dynamic>> createSubject(Map<String, dynamic> data) async =>
      _map(await _dio.post('/subjects', data: data));
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data) async =>
      _map(await _dio.post('/rooms', data: data));
  Future<List<Map<String, dynamic>>> semesters() async =>
      _list(await _dio.get('/semesters'));
  Future<List<Map<String, dynamic>>> examCategories() async =>
      _list(await _dio.get('/exam-categories'));
  Future<Map<String, dynamic>> createExamCategory(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/exam-categories', data: data));
  Future<Map<String, dynamic>> updateExamCategory(
          String id, Map<String, dynamic> data) async =>
      _map(await _dio.put('/exam-categories/$id', data: data));
  Future<void> deleteExamCategory(String id) async =>
      _dio.delete('/exam-categories/$id');
  Future<List<Map<String, dynamic>>> classStudents(String classId) async =>
      _list(await _dio.get('/classes/$classId/students'));

  Future<Map<String, dynamic>> createAcademicYear(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/academicYears', data: data));
  Future<Map<String, dynamic>> createSemester(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/semesters', data: data));
  Future<List<Map<String, dynamic>>> intakeCandidates(
          String academicYearId, String gradeLevel) async =>
      _list(await _dio
          .get('/intake-class-placement/candidates', queryParameters: {
        'academicYearId': academicYearId,
        'gradeLevel': gradeLevel,
      }));
  Future<Map<String, dynamic>> previewIntakePlacement(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/intake-class-placement/preview', data: data));
  Future<Map<String, dynamic>> applyIntakePlacement(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/intake-class-placement/apply', data: data));

  // ---------- F04: kế hoạch đào tạo dùng resource định mức hiện có ----------
  Future<List<Map<String, dynamic>>> curriculumRequirements(
          String semesterId) async =>
      _list(await _dio.get('/curriculum-requirements',
          queryParameters: {'semesterId': semesterId}));
  Future<Map<String, dynamic>> saveCurriculumRequirement(
          Map<String, dynamic> data) async =>
      _map(await _dio.put('/curriculum-requirements', data: data));
  Future<void> deleteCurriculumRequirement(String id) async =>
      _dio.delete('/curriculum-requirements/$id');

  // ---------- Timetable ----------
  Future<List<Map<String, dynamic>>> myTimetable() async =>
      _list(await _dio.get('/me/timetable'));
  Future<List<TimetableSlot>> childTimetable(String studentId) async {
    final response =
        await _dio.get<List<dynamic>>('/children/$studentId/timetable');
    return (response.data ?? const <dynamic>[])
        .map((item) => TimetableSlot.fromJson(
              (item as Map).cast<String, dynamic>(),
            ))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> timetableOfClass(String classId) async =>
      _list(await _dio
          .get('/timetableSlots', queryParameters: {'classId': classId}));

  Future<List<Map<String, dynamic>>> timetableSlots({
    String? classId,
    required String semesterId,
  }) async =>
      _list(await _dio.get('/timetableSlots', queryParameters: {
        if (classId != null) 'classId': classId,
        'semesterId': semesterId,
      }));

  Future<Map<String, dynamic>> createTimetableSlot(
      Map<String, dynamic> data) async {
    final response = await _dio.post('/timetableSlots', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateTimetableSlot(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/timetableSlots/$id', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteTimetableSlot(String id) async =>
      _dio.delete('/timetableSlots/$id');

  Future<List<Map<String, dynamic>>> timetableVersions(
          String semesterId) async =>
      _list(await _dio.get('/timetable-versions',
          queryParameters: {'semesterId': semesterId}));

  Future<List<Map<String, dynamic>>> timetableVersionSlots(String id) async =>
      _list(await _dio.get('/timetable-versions/$id/slots'));

  Future<Map<String, dynamic>> createTimetableVersion(
          String semesterId, String name) async =>
      _map(await _dio.post('/timetable-versions',
          data: {'semesterId': semesterId, 'name': name}));

  Future<Map<String, dynamic>> publishTimetableVersion(String id) async =>
      _map(await _dio.post('/timetable-versions/$id/publish'));

  Future<void> deleteTimetableVersion(String id) async =>
      _dio.delete('/timetable-versions/$id');

  Future<Map<String, dynamic>> autoPlanTimetable(String semesterId, bool apply,
          {bool allowPartial = false,
          String? scopeGradeLevel,
          String? draftName}) async =>
      _map(await _dio.post('/timetableSlots/auto-plan', data: {
        'semesterId': semesterId,
        'apply': apply,
        'allowPartial': allowPartial,
        if (scopeGradeLevel != null) 'scopeGradeLevel': scopeGradeLevel,
        if (draftName != null) 'draftName': draftName,
      }));

  Future<List<Map<String, dynamic>>> teacherLoadRegistrations(
          String semesterId) async =>
      _list(await _dio.get('/teacher-load-registrations',
          queryParameters: {'semesterId': semesterId}));

  Future<List<Map<String, dynamic>>> teachingAssignments({
    String? classId,
    String? subjectId,
    String? teacherId,
    String? semesterId,
    String? dayOfWeek,
    int? periodNo,
  }) async =>
      _list(await _dio.get('/teaching-assignments', queryParameters: {
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
        if (teacherId != null) 'teacherId': teacherId,
        if (semesterId != null) 'semesterId': semesterId,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
        if (periodNo != null) 'periodNo': periodNo,
      }));

  Future<List<Map<String, dynamic>>> myTeachingAssignments() async =>
      _list(await _dio.get('/me/teaching-assignments'));

  Future<Map<String, dynamic>> createTeachingAssignment(
      Map<String, dynamic> data) async {
    final response = await _dio.post('/teaching-assignments', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> teacherWorkloads(
          {String? semesterId}) async =>
      _list(await _dio.get('/teaching-assignments/workloads', queryParameters: {
        if (semesterId != null) 'semesterId': semesterId,
      }));

  Future<Map<String, dynamic>> updateTeachingAssignment(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/teaching-assignments/$id', data: data);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteTeachingAssignment(String id) async =>
      _dio.delete('/teaching-assignments/$id');

  // ---------- F06/F07: ngoại lệ, lịch bù và tiến độ thực dạy ----------
  Future<List<Map<String, dynamic>>> teachingProgress({
    required String semesterId,
    String? classId,
    String? subjectId,
  }) async =>
      _list(await _dio.get('/teaching-progress', queryParameters: {
        'semesterId': semesterId,
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      }));

  Future<Map<String, dynamic>> saveTeachingProgress(
          Map<String, dynamic> data) async =>
      _map(await _dio.put('/teaching-progress', data: data));

  Future<Map<String, dynamic>> reviewMakeup(
          String id, String status, String? reviewNote) async =>
      _map(await _dio.put('/teaching-progress/$id/makeup', data: {
        'status': status,
        'reviewNote': reviewNote,
      }));

  // ---------- Attendance ----------
  Future<List<Map<String, dynamic>>> attendance(
      {String? studentId,
      String? classId,
      String? slotId,
      String? date}) async {
    final q = <String, dynamic>{};
    if (studentId != null) q['studentId'] = studentId;
    if (classId != null) q['classId'] = classId;
    if (slotId != null) q['slotId'] = slotId;
    if (date != null) q['date'] = date;
    return _list(await _dio.get('/attendance', queryParameters: q));
  }

  Future<Map<String, dynamic>> attendanceSessionStatus(
          String slotId, String date) async =>
      _map(await _dio.get('/attendance/session-status',
          queryParameters: {'slotId': slotId, 'date': date}));

  Future<Map<String, dynamic>> unlockAttendance(
          String slotId, String date, String reason) async =>
      _map(await _dio.post('/attendance/unlock', data: {
        'slotId': slotId,
        'date': date,
        'reason': reason,
      }));

  Future<List<Map<String, dynamic>>> bulkAttendance({
    required String slotId,
    required String date,
    required List<Map<String, dynamic>> marks,
  }) async =>
      _list(await _dio.post('/attendance/bulk',
          data: {'slotId': slotId, 'date': date, 'marks': marks}));

  // ---------- Grades ----------
  Future<List<Map<String, dynamic>>> grades({
    String? studentId,
    String? classId,
    String? subjectId,
    String? semesterId,
    String? category,
  }) async {
    final q = <String, dynamic>{};
    if (studentId != null) q['studentId'] = studentId;
    if (classId != null) q['classId'] = classId;
    if (subjectId != null) q['subjectId'] = subjectId;
    if (semesterId != null) q['semesterId'] = semesterId;
    if (category != null) q['category'] = category;
    return _list(await _dio.get('/grades', queryParameters: q));
  }

  Future<Map<String, dynamic>> teacherGradebookContext({
    required String classId,
    required String semesterId,
  }) async {
    final response = await _dio.get('/me/gradebook-context',
        queryParameters: {'classId': classId, 'semesterId': semesterId});
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> gradeChangeLogs(String gradeId) async =>
      _list(await _dio.get('/grades/$gradeId/change-logs'));

  Future<List<Map<String, dynamic>>> bulkGrades({
    required String classId,
    required String subjectId,
    required String semesterId,
    required String category,
    required int assessmentIndex,
    String? reason,
    required List<Map<String, dynamic>> entries,
  }) async =>
      _list(await _dio.post('/grades/bulk', data: {
        'classId': classId,
        'subjectId': subjectId,
        'semesterId': semesterId,
        'category': category,
        'assessmentIndex': assessmentIndex,
        'reason': reason,
        'entries': entries,
      }));

  Future<List<Map<String, dynamic>>> gradeSummaries({
    String? studentId,
    String? semesterId,
  }) async =>
      _list(await _dio.get('/grades/summary', queryParameters: {
        if (studentId != null) 'studentId': studentId,
        if (semesterId != null) 'semesterId': semesterId,
      }));

  Future<Map<String, dynamic>> assignHomeroomTeacher(
      String classId, String teacherId) async {
    final response = await _dio.put('/classes/$classId/homeroom-teacher',
        data: {'teacherId': teacherId});
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> clearHomeroomTeacher(String classId) async {
    final response = await _dio.delete('/classes/$classId/homeroom-teacher');
    return (response.data as Map).cast<String, dynamic>();
  }

  // ---------- Parent ----------
  Future<List<Map<String, dynamic>>> children() async =>
      _list(await _dio.get('/me/children'));

  Future<List<Map<String, dynamic>>> invoices({
    String? studentId,
    String? status,
    String? feePeriodId,
    String? classId,
    String? gradeLevel,
    String? query,
  }) async {
    final q = <String, dynamic>{};
    if (studentId != null) q['studentId'] = studentId;
    if (status != null) q['status'] = status;
    if (feePeriodId != null) q['periodId'] = feePeriodId;
    if (classId != null) q['classId'] = classId;
    if (gradeLevel != null) q['gradeLevel'] = gradeLevel;
    if (query != null) q['q'] = query;
    return _list(await _dio.get('/invoices', queryParameters: q));
  }

  Future<Map<String, dynamic>> invoiceDetail(String id) async {
    final response = await _dio.get('/invoices/$id');
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> pay(String invoiceId,
      {String method = 'VIETQR'}) async {
    final r = await _dio
        .post('/payments', data: {'invoiceId': invoiceId, 'method': method});
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> markVietQrSubmitted(String paymentId) async =>
      _map(await _dio.post('/payments/$paymentId/submitted'));

  Future<List<Map<String, dynamic>>> pendingVietQrPayments() async =>
      _list(await _dio.get('/payments/vietqr/pending'));

  Future<Map<String, dynamic>> confirmVietQrPayment(
          String paymentId, String bankTransactionRef) async =>
      _map(await _dio.post('/payments/$paymentId/confirm-vietqr',
          data: {'bankTransactionRef': bankTransactionRef}));

  Future<Map<String, dynamic>> rejectVietQrPayment(String paymentId) async =>
      _map(await _dio.post('/payments/$paymentId/reject-vietqr'));

  // ---------- Notifications / Announcements ----------
  Future<List<Map<String, dynamic>>> notifications() async {
    final page = _map(await _dio.get('/notifications/page', queryParameters: {
      'page': 0,
      'size': 100,
    }));
    return (page['items'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<int> notificationUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotiRead(String id) async =>
      _dio.post('/notifications/$id/read');
  Future<List<Map<String, dynamic>>> notificationPreferences() async =>
      _list(await _dio.get('/notification-preferences'));
  Future<void> updateNotificationPreference(
          String channel, bool enabled) async =>
      _dio.put('/notification-preferences',
          data: {'channel': channel, 'enabled': enabled});
  Future<List<Map<String, dynamic>>> announcements() async =>
      _list(await _dio.get('/announcements'));
  Future<List<Map<String, dynamic>>> teacherAnnouncementScopes() async =>
      _list(await _dio.get('/teacher/announcements/scopes'));
  Future<List<Map<String, dynamic>>> teacherAnnouncements() async =>
      _list(await _dio.get('/teacher/announcements'));
  Future<Map<String, dynamic>> createAnnouncement(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/announcements', data: data));
  Future<Map<String, dynamic>> sendTeacherAnnouncement({
    required String classId,
    required String target,
    required String category,
    required String priority,
    required String title,
    required String body,
  }) async {
    final response = await _dio.post('/announcements', data: {
      'audience': '$target:$classId',
      'category': category,
      'priority': priority,
      'title': title,
      'body': body,
    });
    return (response.data as Map).cast<String, dynamic>();
  }

  // ---------- Chat (B6/D3) ----------
  Future<List<Map<String, dynamic>>> chatThreads() async =>
      _list(await _dio.get('/chat/threads'));
  Future<int> chatUnreadCount() async =>
      ((_map(await _dio.get('/chat/unread-count'))['count'] as num?)?.toInt() ??
          0);
  Future<List<Map<String, dynamic>>> chatContacts() async =>
      _list(await _dio.get('/chat/contacts'));
  Future<List<Map<String, dynamic>>> teachingClasses() async =>
      _list(await _dio.get('/me/teaching-classes'));
  Future<void> broadcastToClass(
          String classId, String title, String body) async =>
      sendTeacherAnnouncement(
        classId: classId,
        target: 'CLASS_ALL',
        category: 'STUDENT_STATUS',
        priority: 'NORMAL',
        title: title,
        body: body,
      );
  Future<List<Map<String, dynamic>>> chatMessages(String withUserId) async {
    final page = _map(await _dio.get('/chat/messages/page', queryParameters: {
      'withUserId': withUserId,
      'page': 0,
      'size': 100,
    }));
    final items = (page['items'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    items.sort((a, b) =>
        '${a['createdAt'] ?? ''}'.compareTo('${b['createdAt'] ?? ''}'));
    return items;
  }

  Future<Map<String, dynamic>> sendChat(String toUserId, String body) async {
    final r = await _dio
        .post('/chat/messages', data: {'toUserId': toUserId, 'body': body});
    return (r.data as Map).cast<String, dynamic>();
  }

  // ---------- Assignments ----------
  Future<List<Map<String, dynamic>>> myAssignments() async =>
      _list(await _dio.get('/me/assignments'));
  Future<List<Map<String, dynamic>>> childAssignments(String studentId) async =>
      _list(await _dio.get('/children/$studentId/assignments'));
  Future<List<Map<String, dynamic>>> childSubmissions(String studentId) async =>
      _list(await _dio.get('/children/$studentId/submissions'));
  Future<List<Map<String, dynamic>>> teacherAssignments() async =>
      _list(await _dio.get('/assignments'));
  Future<Map<String, dynamic>> createAssignment(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/assignments', data: data));
  Future<Map<String, dynamic>> publishAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/publish'));
  Future<Map<String, dynamic>> closeAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/close'));
  Future<Map<String, dynamic>> reopenAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/reopen'));
  Future<List<Map<String, dynamic>>> assignmentSubmissions(String id) async =>
      _list(await _dio.get('/assignments/$id/submissions'));
  Future<List<Map<String, dynamic>>> mySubmissions() async =>
      _list(await _dio.get('/me/submissions'));
  Future<Map<String, dynamic>> submitAssignment(
    String id, {
    String? content,
    String? attachmentFileId,
  }) async =>
      _map(await _dio.post('/assignments/$id/submit', data: {
        'content': content,
        'attachmentFileId': attachmentFileId,
      }));
  Future<Map<String, dynamic>> gradeSubmission(
    String id, {
    required double score,
    String? feedback,
  }) async =>
      _map(await _dio.post('/submissions/$id/grade', data: {
        'score': score,
        'feedback': feedback,
      }));
  Future<Map<String, dynamic>> allowSubmissionResubmit(String id) async =>
      _map(await _dio.post('/submissions/$id/allow-resubmit'));
  Future<List<Map<String, dynamic>>> submissionAttempts(String id) async =>
      _list(await _dio.get('/submissions/$id/attempts'));

  Future<Map<String, dynamic>> uploadFile(
    Uint8List bytes,
    String filename,
  ) async =>
      _map(await _dio.post('/files',
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes(bytes, filename: filename),
          })));

  // ---------- Xin nghỉ học ----------
  Future<List<Map<String, dynamic>>> leaveRequests() async =>
      _list(await _dio.get('/leave-requests'));

  Future<Map<String, dynamic>> createLeaveRequest({
    required String startDate,
    required String endDate,
    required String reason,
  }) async =>
      _map(await _dio.post('/leave-requests', data: {
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
      }));

  Future<Map<String, dynamic>> decideLeaveRequest(
    String id,
    String action, {
    String? note,
  }) async =>
      _map(await _dio.post('/leave-requests/$id/$action',
          data: {if (note != null) 'note': note}));

  // ---------- Khảo thí ----------
  Future<List<Map<String, dynamic>>> examPeriods() async =>
      _list(await _dio.get('/exam-periods'));

  Future<Map<String, dynamic>> createExamPeriod(
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/exam-periods', data: data));
  Future<Map<String, dynamic>> autoPlanExam(
    String periodId, {
    required List<String> subjectIds,
    required String startTime,
    required int durationMinutes,
    required bool apply,
    required String idempotencyKey,
  }) async =>
      _map(await _dio.post('/exam-periods/$periodId/auto-plan', data: {
        'subjectIds': subjectIds,
        'startTime': startTime,
        'durationMinutes': durationMinutes,
        'apply': apply,
        'idempotencyKey': idempotencyKey,
      }));
  Future<List<Map<String, dynamic>>> examSchedules(String periodId) async =>
      _list(await _dio.get('/exam-periods/$periodId/schedules'));
  Future<Map<String, dynamic>> createExamSchedule(
          String periodId, Map<String, dynamic> data) async =>
      _map(await _dio.post('/exam-periods/$periodId/schedules', data: data));
  Future<Map<String, dynamic>> updateExamSchedule(
          String id, Map<String, dynamic> data) async =>
      _map(await _dio.put('/exam-schedules/$id', data: data));
  Future<void> deleteExamSchedule(String id) async =>
      _dio.delete('/exam-schedules/$id');
  Future<List<Map<String, dynamic>>> examRooms(String scheduleId) async =>
      _list(await _dio.get('/exam-schedules/$scheduleId/rooms'));
  Future<Map<String, dynamic>> saveExamRoom(
          String scheduleId, Map<String, dynamic> data) async =>
      _map(await _dio.post('/exam-schedules/$scheduleId/rooms', data: data));
  Future<List<Map<String, dynamic>>> allocateExamCandidates(
          String examRoomId, String classId) async =>
      _list(await _dio.post('/exam-rooms/$examRoomId/allocate',
          data: {'classId': classId}));
  Future<List<Map<String, dynamic>>> examCandidates(
          String periodId, String scheduleId) async =>
      _list(await _dio.get('/exam-periods/$periodId/candidates',
          queryParameters: {'scheduleId': scheduleId}));
  Future<List<Map<String, dynamic>>> eligibleExamGraders(
          String scheduleId) async =>
      _list(await _dio.get('/exam-schedules/$scheduleId/eligible-graders'));
  Future<Map<String, dynamic>> saveExamGrader(
          String scheduleId, String classId, String teacherId) async =>
      _map(await _dio.put('/exam-schedules/$scheduleId/graders',
          data: {'classId': classId, 'teacherId': teacherId}));
  Future<Map<String, dynamic>> publishExamSchedule(String periodId) async =>
      _map(await _dio.post('/exam-periods/$periodId/publish-schedule'));
  Future<Map<String, dynamic>> lockExamScores(String periodId) async =>
      _map(await _dio.post('/exam-periods/$periodId/lock-scores'));
  Future<Map<String, dynamic>> unlockExamScores(String periodId) async =>
      _map(await _dio.post('/exam-periods/$periodId/unlock-scores'));
  Future<Map<String, dynamic>> confirmExamPeriod(String periodId) async =>
      _map(await _dio.post('/exam-periods/$periodId/confirm'));

  Future<List<Map<String, dynamic>>> examAgenda({String? childId}) async =>
      _list(await _dio.get('/me/exam-agenda', queryParameters: {
        if (childId != null) 'childId': childId,
      }));

  Future<List<Map<String, dynamic>>> examGradingTasks() async =>
      _list(await _dio.get('/me/exam-grading'));

  Future<List<Map<String, dynamic>>> examResults() async =>
      _list(await _dio.get('/me/exam-results'));

  Future<List<Map<String, dynamic>>> childExamResults(String studentId) async =>
      _list(await _dio.get('/children/$studentId/exam-results'));

  Future<List<Map<String, dynamic>>> saveExamResults(
    String periodId, {
    required String scheduleId,
    required List<Map<String, dynamic>> entries,
  }) async =>
      _list(await _dio.put('/exam-periods/$periodId/results', data: {
        'scheduleId': scheduleId,
        'entries': entries,
      }));

  Future<List<Map<String, dynamic>>> examReviews({String? status}) async =>
      _list(await _dio.get('/me/exam-reviews', queryParameters: {
        if (status != null) 'status': status,
      }));

  Future<Map<String, dynamic>> requestExamReview(
    String periodId, {
    required String resultId,
    required String reason,
  }) async =>
      _map(await _dio.post('/exam-periods/$periodId/reviews',
          data: {'resultId': resultId, 'reason': reason}));

  Future<Map<String, dynamic>> resolveExamReview(
    String reviewId, {
    required String status,
    required String resolution,
    double? resolvedScore,
  }) async =>
      _map(await _dio.put('/exam-reviews/$reviewId/resolve', data: {
        'status': status,
        'resolution': resolution,
        if (resolvedScore != null) 'resolvedScore': resolvedScore,
      }));
}
