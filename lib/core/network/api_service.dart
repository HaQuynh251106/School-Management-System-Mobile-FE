import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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

  Future<Map<String, dynamic>> personalReport({String? childId}) async =>
      _map(await _dio.get('/me/reports', queryParameters: {
        if (childId != null) 'childId': childId,
      }));

  Future<Map<String, dynamic>> reportOverview() async =>
      _map(await _dio.get('/reports/overview'));

  Future<List<Map<String, dynamic>>> reportGradeDistribution({
    String? semesterId,
    String? classId,
    String? subjectId,
  }) async =>
      _list(await _dio.get('/reports/grade-distribution', queryParameters: {
        if (semesterId != null) 'semesterId': semesterId,
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
      }));

  Future<Map<String, dynamic>> reportAttendance({
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      _map(await _dio.get('/reports/attendance-summary', queryParameters: {
        if (classId != null) 'classId': classId,
        if (startDate != null)
          'startDate': startDate.toIso8601String().substring(0, 10),
        if (endDate != null)
          'endDate': endDate.toIso8601String().substring(0, 10),
      }));

  Future<Map<String, dynamic>> reportRevenue({
    String? periodId,
    String? classId,
  }) async =>
      _map(await _dio.get('/reports/revenue', queryParameters: {
        if (periodId != null) 'periodId': periodId,
        if (classId != null) 'classId': classId,
      }));

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
    final response = await _dio.get<List<int>>(
      '/reports/export',
      queryParameters: {
        'type': type,
        'format': format,
        if (semesterId != null) 'semesterId': semesterId,
        if (classId != null) 'classId': classId,
        if (subjectId != null) 'subjectId': subjectId,
        if (startDate != null)
          'startDate': startDate.toIso8601String().substring(0, 10),
        if (endDate != null)
          'endDate': endDate.toIso8601String().substring(0, 10),
        if (periodId != null) 'periodId': periodId,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  Future<List<int>> exportPersonalReport({String? childId}) async {
    final response = await _dio.get<List<int>>(
      '/me/reports/export',
      queryParameters: {if (childId != null) 'childId': childId},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

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
  Future<Map<String, dynamic>> resetUserPassword(String id,
          {String? newPassword}) async =>
      (await _dio.post('/users/$id/reset-password',
              data: {'newPassword': newPassword}))
          .data
          .cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> loginHistory(String id) async =>
      _list(await _dio.get('/users/$id/login-history'));
  Future<List<Map<String, dynamic>>> userChildren(String id) async =>
      _list(await _dio.get('/users/$id/children'));

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
  Future<Map<String, dynamic>> feePeriodDetail(String id) async =>
      _map(await _dio.get('/fee-periods/$id'));
  Future<Map<String, dynamic>> updateFeePeriod(
          String id, Map<String, dynamic> data) async =>
      _map(await _dio.put('/fee-periods/$id', data: data));
  Future<Map<String, dynamic>> feePeriodPreview(String id) async =>
      _map(await _dio.get('/fee-periods/$id/preview'));
  Future<Map<String, dynamic>> addFeePeriodItem(
          String id, Map<String, dynamic> data) async =>
      _map(await _dio.post('/fee-periods/$id/items', data: data));
  Future<void> deleteFeePeriodItem(String periodId, String itemId) async =>
      _dio.delete('/fee-periods/$periodId/items/$itemId');
  Future<Map<String, dynamic>> saveFeePeriodAdjustment(
          String id, Map<String, dynamic> data) async =>
      _map(await _dio.post('/fee-periods/$id/adjustments', data: data));
  Future<void> deleteFeePeriodAdjustment(
          String periodId, String adjustmentId) async =>
      _dio.delete('/fee-periods/$periodId/adjustments/$adjustmentId');
  Future<Map<String, dynamic>> openFeePeriod(String id) async =>
      _map(await _dio.post('/fee-periods/$id/open'));
  Future<Map<String, dynamic>> closeFeePeriod(String id) async =>
      _map(await _dio.post('/fee-periods/$id/close'));
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
  Future<List<Map<String, dynamic>>> classStudents(String classId) async =>
      _list(await _dio.get('/classes/$classId/students'));

  // ---------- Timetable ----------
  Future<List<Map<String, dynamic>>> myTimetable() async =>
      _list(await _dio.get('/me/timetable'));
  Future<List<Map<String, dynamic>>> timetableOfClass(String classId) async =>
      _list(await _dio
          .get('/timetableSlots', queryParameters: {'classId': classId}));

  Future<List<Map<String, dynamic>>> timetableSlots({
    required String classId,
    required String semesterId,
  }) async =>
      _list(await _dio.get('/timetableSlots', queryParameters: {
        'classId': classId,
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

  Future<Map<String, dynamic>> createTimetableVersion(
          String semesterId, String name) async =>
      _map(await _dio.post('/timetable-versions',
          data: {'semesterId': semesterId, 'name': name}));

  Future<Map<String, dynamic>> publishTimetableVersion(String id) async =>
      _map(await _dio.post('/timetable-versions/$id/publish'));

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

  // ---------- Attendance ----------
  Future<List<Map<String, dynamic>>> attendance(
      {String? studentId, String? classId, String? date}) async {
    final q = <String, dynamic>{};
    if (studentId != null) q['studentId'] = studentId;
    if (classId != null) q['classId'] = classId;
    if (date != null) q['date'] = date;
    return _list(await _dio.get('/attendance', queryParameters: q));
  }

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

  Future<List<Map<String, dynamic>>> bulkGrades({
    required String classId,
    required String subjectId,
    required String semesterId,
    required String category,
    String? reason,
    required List<Map<String, dynamic>> entries,
  }) async =>
      _list(await _dio.post('/grades/bulk', data: {
        'classId': classId,
        'subjectId': subjectId,
        'semesterId': semesterId,
        'category': category,
        'reason': reason,
        'entries': entries,
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
        await _dio.get('/admin/club-registrations', queryParameters: query));
  }

  Future<Map<String, dynamic>> approveClubRegistration(String registrationId,
          {String? note}) async =>
      _map(await _dio.post('/club-registrations/$registrationId/approve',
          data: {'note': note ?? 'Duyệt từ ứng dụng mobile'}));

  Future<Map<String, dynamic>> rejectClubRegistration(String registrationId,
          {String? note}) async =>
      _map(await _dio.post('/club-registrations/$registrationId/reject',
          data: {'note': note ?? 'Từ chối từ ứng dụng mobile'}));

  Future<List<Map<String, dynamic>>> myClubRegistrations() async =>
      _list(await _dio.get('/me/club-registrations'));

  Future<List<Map<String, dynamic>>> childClubRegistrations(
          String studentId) async =>
      _list(await _dio.get('/children/$studentId/club-registrations'));

  Future<Map<String, dynamic>> registerClub(String clubId,
      {String? studentId}) async {
    return _map(await _dio.post('/clubs/$clubId/registrations',
        data: studentId == null
            ? <String, dynamic>{}
            : {'studentId': studentId}));
  }

  Future<Map<String, dynamic>> cancelClubRegistration(String registrationId,
          {String? reason}) async =>
      _map(await _dio.post('/club-registrations/$registrationId/cancel',
          data: {'reason': reason ?? 'Hủy từ ứng dụng mobile'}));

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
    final initiated = (r.data as Map).cast<String, dynamic>();
    final callbackUrl = initiated['callbackUrl'] as String?;
    final callback = initiated['sandboxCallback'];
    if (callbackUrl != null && callback is Map) {
      final completed = await _dio.post(callbackUrl, data: callback);
      return (completed.data as Map).cast<String, dynamic>();
    }
    return initiated;
  }

  Future<Map<String, dynamic>> recordCashPayment(
    String invoiceId, {
    int? amount,
    String? payerName,
    String? note,
  }) async =>
      _map(await _dio.post('/payments/cash', data: {
        'invoiceId': invoiceId,
        if (amount != null) 'amount': amount,
        if (payerName != null && payerName.trim().isNotEmpty)
          'payerName': payerName.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      }));

  Future<Map<String, dynamic>> refundInvoice(
          String invoiceId, int amount, String reason) async =>
      _map(await _dio.post('/invoices/$invoiceId/refund',
          data: {'amount': amount, 'reason': reason}));

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
    String? idempotencyKey,
  }) async {
    final response = await _dio.post('/announcements', data: {
      'audience': '$target:$classId',
      'category': category,
      'priority': priority,
      'title': title,
      'body': body,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    });
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> previewTeacherAnnouncement({
    required String classId,
    required String target,
    required String category,
  }) async {
    final response = await _dio.post('/announcements/preview', data: {
      'audience': '$target:$classId',
      'category': category,
    });
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
          String classId, String title, String body) async =>
      sendTeacherAnnouncement(
        classId: classId,
        target: 'CLASS_ALL',
        category: 'STUDENT_STATUS',
        priority: 'NORMAL',
        title: title,
        body: body,
        idempotencyKey:
            'class-$classId-${DateTime.now().microsecondsSinceEpoch}',
      );
  Future<List<Map<String, dynamic>>> chatMessages(String withUserId) async =>
      _list(await _dio
          .get('/chat/messages', queryParameters: {'withUserId': withUserId}));
  Future<Map<String, dynamic>> sendChat(String toUserId, String body) async {
    final r = await _dio
        .post('/chat/messages', data: {'toUserId': toUserId, 'body': body});
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
          Map<String, dynamic> data) async =>
      _map(await _dio.post('/assignments', data: data));
  Future<List<Map<String, dynamic>>> assignmentSubmissions(String id) async =>
      _list(await _dio.get('/assignments/$id/submissions'));
  Future<Map<String, dynamic>> submitAssignment(
    String id, {
    String? content,
    String? attachmentFileId,
  }) async {
    final r = await _dio.post('/assignments/$id/submit', data: {
      'content': content,
      'attachmentFileId': attachmentFileId,
    });
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> gradeSubmission(
    String id, {
    required double score,
    String? feedback,
  }) async =>
      _map(await _dio.post('/submissions/$id/grade', data: {
        'score': score,
        'feedback': feedback,
      }));

  Future<Map<String, dynamic>> allowResubmit(String id) async =>
      _map(await _dio.post('/submissions/$id/allow-resubmit'));

  Future<Map<String, dynamic>> publishAssignment(String id) async =>
      _map(await _dio.post('/assignments/$id/publish'));

  Future<Map<String, dynamic>> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async =>
      _map(await _dio.put('/assignments/$id', data: data));

  Future<Map<String, dynamic>> extendAssignment(
    String id,
    DateTime deadline,
  ) async =>
      _map(await _dio.post('/assignments/$id/extend', data: {
        'deadline': deadline.toUtc().toIso8601String(),
      }));

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
      return MediaType('application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document');
    }
    if (lower.endsWith('.xls')) {
      return MediaType('application', 'vnd.ms-excel');
    }
    if (lower.endsWith('.xlsx')) {
      return MediaType('application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
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

  Future<List<Map<String, dynamic>>> examAgenda({String? childId}) async =>
      _list(await _dio.get('/me/exam-agenda', queryParameters: {
        if (childId != null) 'childId': childId,
      }));

  Future<List<Map<String, dynamic>>> examGradingTasks() async =>
      _list(await _dio.get('/me/exam-grading'));

  Future<List<Map<String, dynamic>>> examResults() async =>
      _list(await _dio.get('/me/exam-results'));

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
}
