import 'package:dio/dio.dart';

/// Lớp gọi API SSE backend (Spring Boot, :4000) dùng Dio đã gắn interceptor JWT.
/// Trả JSON thô (List/Map dynamic) để các trang đọc field trực tiếp — gọn, ít model.
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  List<Map<String, dynamic>> _list(Response r) =>
      (r.data as List).cast<Map<String, dynamic>>();

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
  Future<List<Map<String, dynamic>>> generateInvoices(
          String feePeriodId) async =>
      _list(await _dio.post('/fee-periods/$feePeriodId/generate-invoices'));
  Future<List<Map<String, dynamic>>> notificationTemplates() async =>
      _list(await _dio.get('/notification-templates'));

  // ---------- Academic structure ----------
  Future<List<Map<String, dynamic>>> classes() async =>
      _list(await _dio.get('/classes'));
  Future<List<Map<String, dynamic>>> subjects() async =>
      _list(await _dio.get('/subjects'));
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

  Future<List<Map<String, dynamic>>> invoices({String? studentId}) async {
    final q = <String, dynamic>{};
    if (studentId != null) q['studentId'] = studentId;
    return _list(await _dio.get('/invoices', queryParameters: q));
  }

  Future<Map<String, dynamic>> invoiceDetail(String id) async {
    final response = await _dio.get('/invoices/$id');
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> pay(String invoiceId,
      {String method = 'VNPAY'}) async {
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
  Future<List<Map<String, dynamic>>> teacherAssignments() async =>
      _list(await _dio.get('/assignments'));
  Future<Map<String, dynamic>> submitAssignment(
      String id, String content) async {
    final r =
        await _dio.post('/assignments/$id/submit', data: {'content': content});
    return (r.data as Map).cast<String, dynamic>();
  }

  // ---------- Extracurricular ----------
  Future<List<Map<String, dynamic>>> clubs() async =>
      _list(await _dio.get('/clubs'));
  Future<Map<String, dynamic>> registerClub(String clubId,
      {String? studentId}) async {
    final r = await _dio.post('/clubs/$clubId/register',
        data: studentId != null ? {'studentId': studentId} : {});
    return (r.data as Map).cast<String, dynamic>();
  }
}
