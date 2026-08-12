import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  test(
    'ApiService reads core academic data through generated client',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.httpClientAdapter = _AcademicAdapter(requests);
      final api = ApiService(dio);

      final years = await api.academicYears();
      final semesters = await api.semesters();
      final classes = await api.classes();
      final subjects = await api.subjects();
      final rooms = await api.rooms();
      final timetable = await api.timetableSlots(
        classId: 'c-10a1',
        semesterId: 'sm-1',
      );
      final mine = await api.myTimetable();

      expect(years.single['status'], 'ACTIVE');
      expect(semesters.single['sequence'], 1);
      expect(classes.single['studentCount'], 2);
      expect(subjects.single['coefficient'], 1.0);
      expect(rooms.single['supportsMorning'], isTrue);
      expect(timetable.single['dayOfWeek'], 'MON');
      expect(mine.single['periodNo'], 1);
      expect(requests.map((request) => request.path), [
        '/academicYears',
        '/semesters',
        '/classes',
        '/subjects',
        '/rooms',
        '/timetableSlots',
        '/me/timetable',
      ]);
      expect(requests[5].queryParameters, {
        'classId': 'c-10a1',
        'semesterId': 'sm-1',
      });
    },
  );

  test('ApiService sends typed academic mutations', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);
    final api = ApiService(dio);

    await api.createClass({
      'code': '11A1',
      'name': 'Lop 11A1',
      'gradeLevel': 'K11',
      'academicYearId': 'ay-1',
      'studyShift': 'MORNING',
      'capacity': 40,
    });
    await api.createSubject({
      'code': 'CHEM',
      'name': 'Hoa hoc',
      'coefficient': 1.0,
    });
    await api.createRoom({
      'code': 'P301',
      'name': 'Phong 301',
      'capacity': 45,
      'supportsMorning': true,
      'supportsAfternoon': false,
    });
    await api.createTeachingAssignment({
      'classId': 'c-11a1',
      'subjectId': 'sj-chem',
      'teacherId': 'u-teacher-1',
      'semesterId': 'sm-1',
      'weeklyPeriods': 2,
    });
    await api.createTimetableSlot({
      'classId': 'c-11a1',
      'subjectId': 'sj-chem',
      'teacherId': 'u-teacher-1',
      'roomCode': 'P301',
      'dayOfWeek': 'MON',
      'periodNo': 1,
      'startTime': '07:00',
      'endTime': '07:45',
      'semesterId': 'sm-1',
    });

    expect(requests.map((request) => request.path), [
      '/classes',
      '/subjects',
      '/rooms',
      '/teaching-assignments',
      '/timetableSlots',
    ]);
    expect(_body(requests[0])['studyShift'], 'MORNING');
    expect(_body(requests[3])['weeklyPeriods'], 2);
    expect(_body(requests[4])['periodNo'], 1);
  });

  test(
    'ApiService uses typed attendance reads, states and bulk marks',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.httpClientAdapter = _AcademicAdapter(requests);
      final api = ApiService(dio);
      final date = DateTime(2026, 8, 12);

      final rows = await api.attendance(
        studentId: 'u-student-1',
        slotId: 'tt-1',
        date: '2026-08-12',
      );
      final day = await api.attendanceDayStatus(date);
      final session = await api.attendanceSessionStatus(
        slotId: 'tt-1',
        date: date,
      );
      final leaves = await api.approvedLeavesForAttendance(
        slotId: 'tt-1',
        date: date,
      );
      final saved = await api.bulkAttendance(
        slotId: 'tt-1',
        classId: 'c-10a1',
        date: '2026-08-12',
        subjectName: 'Toan',
        periodNo: 1,
        marks: [
          {'studentId': 'u-student-1', 'status': 'PRESENT', 'note': 'Dung gio'},
        ],
      );
      final unlocked = await api.unlockLateAttendance(
        slotId: 'tt-1',
        date: date,
        reason: 'Can dieu chinh ban ghi diem danh',
      );

      expect(rows.single['status'], 'PRESENT');
      expect(day['attendanceRequired'], isTrue);
      expect(session['canMark'], isTrue);
      expect(leaves.single['status'], 'APPROVED');
      expect(saved.single['studentId'], 'u-student-1');
      expect(unlocked['state'], 'UNLOCKED');
      expect(requests.map((request) => request.path).skip(0), [
        '/attendance',
        '/attendance/day-status',
        '/attendance/session-status',
        '/attendance/approved-leaves',
        '/attendance/bulk',
        '/attendance/unlock',
      ]);
      expect(_body(requests[4])['marks'][0]['status'], 'PRESENT');
      expect(_body(requests[5])['reason'], 'Can dieu chinh ban ghi diem danh');
    },
  );

  test('ApiService rejects attendance status outside the contract', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);

    expect(
      () => ApiService(dio).bulkAttendance(
        slotId: 'tt-1',
        date: '2026-08-12',
        marks: [
          {'studentId': 'u-student-1', 'status': 'UNKNOWN'},
        ],
      ),
      throwsArgumentError,
    );
  });

  test('ApiService uses typed gradebook, grade mutations and audit', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);
    final api = ApiService(dio);

    final categories = await api.examCategories();
    final context = await api.teacherGradebookContext(
      classId: 'c-10a1',
      semesterId: 'sm-1',
    );
    final grades = await api.grades(
      classId: 'c-10a1',
      subjectId: 'sj-math',
      semesterId: 'sm-1',
      category: 'ORAL',
    );
    await api.bulkGrades(
      classId: 'c-10a1',
      subjectId: 'sj-math',
      semesterId: 'sm-1',
      category: 'ORAL',
      assessmentIndex: 1,
      reason: 'Nhap diem dot 1',
      entries: [
        {
          'studentId': 'u-student-1',
          'score': 8.5,
          'note': 'Dat',
          'expectedVersion': 0,
        },
      ],
    );
    await api.createGrade(
      studentId: 'u-student-1',
      subjectId: 'sj-math',
      semesterId: 'sm-1',
      category: '15M',
      score: 9,
    );
    await api.updateGrade(
      id: 'g-1',
      score: 9,
      note: 'Da doi chieu',
      reason: 'Sua theo bai kiem tra',
      expectedVersion: 0,
    );
    final logs = await api.gradeChangeLogs('g-1');
    await api.saveExamCategory(
      code: 'QUIZ',
      name: 'Kiem tra nhanh',
      weight: 1,
      requiredCount: 2,
    );
    await api.saveExamCategory(
      id: 'ec-quiz',
      code: 'QUIZ',
      name: 'Kiem tra nhanh',
      weight: 1.5,
      requiredCount: 2,
    );
    await api.deleteExamCategory('ec-quiz');

    expect(categories.single['code'], 'ORAL');
    expect(context['subjects'][0]['editable'], isTrue);
    expect(grades.single['score'], 8.5);
    expect(logs.single['reason'], 'Sua theo bai kiem tra');
    expect(_body(requests[3])['entries'][0]['expectedVersion'], 0);
    expect(_body(requests[5])['reason'], 'Sua theo bai kiem tra');
    expect(requests.last.method, 'DELETE');
    expect(requests.last.path, '/exam-categories/ec-quiz');
  });

  test('ApiService uses typed exam agenda, results and reviews', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);
    final api = ApiService(dio);

    final periods = await api.examPeriods();
    final agenda = await api.examAgenda(childId: 'u-student-1');
    final grading = await api.examGradingTasks();
    final results = await api.examResults();
    final reviews = await api.examReviews(status: 'PENDING');
    final created = await api.requestExamReview(
      'ep-1',
      resultId: 'er-1',
      reason: 'De nghi kiem tra lai diem bai thi',
    );

    expect(periods.single['period']['code'], 'HK1-2026');
    expect(agenda.single['subjectName'], 'Toan');
    expect(grading.single['candidates'][0]['studentCode'], 'HS2025001');
    expect(results.single['score'], 8.5);
    expect(reviews.single['status'], 'PENDING');
    expect(created['resultId'], 'er-1');
    expect(requests.map((request) => request.path).skip(requests.length - 6), [
      '/exam-periods',
      '/me/exam-agenda',
      '/me/exam-grading',
      '/me/exam-results',
      '/me/exam-reviews',
      '/exam-periods/ep-1/reviews',
    ]);
    expect(requests[1].queryParameters['childId'], 'u-student-1');
    expect(requests[4].queryParameters['status'], 'PENDING');
    expect(_body(requests[5]), {
      'resultId': 'er-1',
      'reason': 'De nghi kiem tra lai diem bai thi',
    });
  });

  test(
    'ApiService manages exam periods and schedules with typed requests',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.httpClientAdapter = _AcademicAdapter(requests);
      final api = ApiService(dio);

      await api.saveExamPeriod(
        code: 'HK1-2026',
        name: 'Thi hoc ky 1',
        academicYearId: 'ay-1',
        semesterId: 'sm-1',
        gradeLevel: 'K10',
        startDate: DateTime(2026, 12, 15),
        endDate: DateTime(2026, 12, 20),
      );
      final schedules = await api.examSchedules('ep-1');
      await api.saveExamSchedule(
        periodId: 'ep-1',
        subjectId: 'sj-math',
        classIds: ['c-10a1'],
        examDate: DateTime(2026, 12, 15),
        startTime: '07:30',
        durationMinutes: 90,
        notes: 'Mang theo but',
      );
      final published = await api.publishExamSchedule('ep-1');
      await api.deleteExamSchedule('es-1');
      await api.deleteExamPeriod('ep-1');

      expect(schedules.single['subjectName'], 'Toan');
      expect(published['schedulePublished'], isTrue);
      expect(_body(requests[0])['academicYearId'], 'ay-1');
      expect(_body(requests[2])['classIds'], ['c-10a1']);
      expect(requests.map((request) => request.path), [
        '/exam-periods',
        '/exam-periods/ep-1/schedules',
        '/exam-periods/ep-1/schedules',
        '/exam-periods/ep-1/publish-schedule',
        '/exam-schedules/es-1',
        '/exam-periods/ep-1',
      ]);
    },
  );

  test('ApiService prepares exam rooms, candidates and graders', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);
    final api = ApiService(dio);

    final rooms = await api.examRooms('es-1');
    await api.createExamRoom(
      scheduleId: 'es-1',
      roomCode: 'P201',
      capacity: 40,
      proctorOneId: 'u-teacher-1',
    );
    final candidates = await api.allocateExamCandidates(
      roomId: 'er-room-1',
      classId: 'c-10a1',
    );
    final eligible = await api.eligibleExamGraders('es-1');
    final graders = await api.examGraders('es-1');
    await api.saveExamGrader(
      scheduleId: 'es-1',
      classId: 'c-10a1',
      teacherId: 'u-teacher-1',
    );

    expect(rooms.single['roomCode'], 'P201');
    expect(candidates.single['candidateNo'], 'C001');
    expect(eligible.single['teacherName'], 'Nguyen Duc Minh');
    expect(graders.single['classCode'], '10A1');
    expect(_body(requests[1])['capacity'], 40);
    expect(_body(requests[2])['classId'], 'c-10a1');
    expect(_body(requests[5])['teacherId'], 'u-teacher-1');
  });

  test('ApiService uses typed year-end contracts for every role', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = _AcademicAdapter(requests);
    final api = ApiService(dio);

    final preview = await api.yearRolloverPreview('ay-1');
    final students = await api.promotionPreview('ay-1');
    final homeroom = await api.homeroomYearlySummaries('ay-1');
    final mine = await api.myYearlySummary('ay-1');
    final child = await api.childYearlySummary('ay-1', 'u-student-1');
    await api.setStudentConduct(
      yearId: 'ay-1',
      studentId: 'u-student-1',
      conductGrade: 'GOOD',
    );

    expect(preview['incompleteCount'], 1);
    expect(students.single['promotionStatus'], 'INCOMPLETE');
    expect(homeroom.single['studentId'], 'u-student-1');
    expect(mine['studentName'], 'Nguyen Minh An');
    expect(child['academicYearId'], 'ay-1');
    expect(requests.map((request) => request.path), [
      '/academic-years/ay-1/rollover-preview',
      '/academic-years/ay-1/promotion-preview',
      '/academic-years/ay-1/homeroom-summaries',
      '/academic-years/ay-1/my-summary',
      '/academic-years/ay-1/children/u-student-1/summary',
      '/academic-years/ay-1/students/u-student-1/conduct',
    ]);
    expect(_body(requests.last)['conductGrade'], 'GOOD');
  });
}

class _AcademicAdapter implements HttpClientAdapter {
  _AcademicAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch ((options.method, options.path)) {
      ('POST', '/classes') => _classroom,
      ('POST', '/subjects') => _subject,
      ('POST', '/rooms') => _room,
      ('POST', '/teaching-assignments') => _assignment,
      ('POST', '/timetableSlots') => _slot,
      ('POST', '/attendance/bulk') => [_attendanceRecord],
      ('POST', '/attendance/unlock') => _unlockedSession,
      ('POST', '/grades/bulk') => [_grade],
      ('POST', '/grades') => {..._grade, 'category': '15M'},
      ('PUT', '/grades/g-1') => {..._grade, 'score': 9.0, 'version': 1},
      ('POST', '/exam-categories') => _quizCategory,
      ('PUT', '/exam-categories/ec-quiz') => {..._quizCategory, 'weight': 1.5},
      ('DELETE', '/exam-categories/ec-quiz') => null,
      ('POST', '/exam-periods/ep-1/reviews') => _examReview,
      ('POST', '/exam-periods') => _examPeriod,
      ('POST', '/exam-periods/ep-1/schedules') => _examSchedule,
      ('POST', '/exam-periods/ep-1/publish-schedule') => {
        ..._examPeriod,
        'schedulePublished': true,
        'scheduleRevision': 1,
      },
      ('DELETE', '/exam-schedules/es-1') => null,
      ('DELETE', '/exam-periods/ep-1') => null,
      ('POST', '/exam-schedules/es-1/rooms') => _examRoom,
      ('POST', '/exam-rooms/er-room-1/allocate') => [_examCandidateEntity],
      ('PUT', '/exam-schedules/es-1/graders') => _examGrader,
      ('PUT', '/academic-years/ay-1/students/u-student-1/conduct') => {
        ..._yearlySummary,
        'conductGrade': 'GOOD',
      },
      (_, '/attendance') => [_attendanceRecord],
      (_, '/attendance/day-status') => _dayStatus,
      (_, '/attendance/session-status') => _sessionStatus,
      (_, '/attendance/approved-leaves') => [_approvedLeave],
      (_, '/exam-categories') => [_oralCategory],
      (_, '/me/gradebook-context') => _gradebookContext,
      (_, '/grades/g-1/change-logs') => [_gradeLog],
      (_, '/grades') => [_grade],
      (_, '/exam-periods') => [_examPeriodSummary],
      (_, '/exam-periods/ep-1/schedules') => [_examSchedule],
      (_, '/me/exam-agenda') => [_examAgenda],
      (_, '/me/exam-grading') => [_examGradingTask],
      (_, '/me/exam-results') => [_examResult],
      (_, '/me/exam-reviews') => [_examReview],
      (_, '/exam-schedules/es-1/rooms') => [_examRoom],
      (_, '/exam-schedules/es-1/eligible-graders') => [_eligibleGrader],
      (_, '/exam-schedules/es-1/graders') => [_examGrader],
      (_, '/academicYears') => [_year],
      (_, '/academic-years/ay-1/rollover-preview') => _rolloverPreview,
      (_, '/academic-years/ay-1/promotion-preview') => [_yearlySummary],
      (_, '/academic-years/ay-1/homeroom-summaries') => [_yearlySummary],
      (_, '/academic-years/ay-1/my-summary') => _yearlySummary,
      (_, '/academic-years/ay-1/children/u-student-1/summary') =>
        _yearlySummary,
      (_, '/semesters') => [_semester],
      (_, '/classes') => [_classroom],
      (_, '/subjects') => [_subject],
      (_, '/rooms') => [_room],
      (_, '/timetableSlots') || (_, '/me/timetable') => [_slot],
      _ => throw StateError('Unexpected request ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _body(RequestOptions request) =>
    (jsonDecode(request.data as String) as Map).cast<String, dynamic>();

const _year = {
  'id': 'ay-1',
  'code': '2026-2027',
  'name': 'Nam hoc 2026-2027',
  'startDate': '2026-08-17',
  'endDate': '2027-05-31',
  'status': 'ACTIVE',
};
const _yearlySummary = {
  'id': 'ys-1',
  'academicYearId': 'ay-1',
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'classId': 'c-10a1',
  'semesterOneAverage': 8.0,
  'semesterTwoAverage': null,
  'averageScore': null,
  'conductGrade': null,
  'promotionStatus': 'INCOMPLETE',
  'missingRequirements': 'Thieu diem hoc ky 2 va hanh kiem',
  'updatedAt': '2026-08-12T08:00:00Z',
};
const _rolloverPreview = {
  'academicYearId': 'ay-1',
  'academicYearCode': '2026-2027',
  'status': 'ACTIVE',
  'semesterCount': 2,
  'classCount': 1,
  'studentCount': 1,
  'readyCount': 0,
  'incompleteCount': 1,
  'expectedPromoted': 0,
  'expectedRetained': 0,
  'expectedGraduated': 0,
  'classPlan': [],
  'blockers': ['Con hoc sinh thieu du lieu'],
};
const _semester = {
  'id': 'sm-1',
  'academicYearId': 'ay-1',
  'code': 'HK1',
  'name': 'Hoc ky 1',
  'sequence': 1,
  'startDate': '2026-08-17',
  'endDate': '2027-01-15',
  'status': 'ACTIVE',
};
const _classroom = {
  'id': 'c-10a1',
  'code': '10A1',
  'name': 'Lop 10A1',
  'gradeLevel': 'K10',
  'studyShift': 'MORNING',
  'capacity': 38,
  'studentCount': 2,
};
const _subject = {
  'id': 'sj-math',
  'code': 'MATH',
  'name': 'Toan',
  'coefficient': 1.0,
};
const _room = {
  'id': 'rm-201',
  'code': 'P201',
  'name': 'Phong 201',
  'capacity': 45,
  'supportsMorning': true,
  'supportsAfternoon': true,
};
const _slot = {
  'id': 'tt-1',
  'classId': 'c-10a1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'teacherId': 'u-teacher-1',
  'teacherName': 'Giao vien',
  'roomCode': 'P201',
  'dayOfWeek': 'MON',
  'periodNo': 1,
  'startTime': '07:00',
  'endTime': '07:45',
  'locked': false,
};
const _assignment = {
  'id': 'ta-1',
  'classId': 'c-11a1',
  'subjectId': 'sj-chem',
  'teacherId': 'u-teacher-1',
  'semesterId': 'sm-1',
  'weeklyPeriods': 2,
  'scheduledPeriods': 1,
  'remainingPeriods': 1,
  'teacherClassCount': 1,
  'teacherWeeklyPeriods': 2,
  'teacherScheduledPeriods': 1,
  'fullyScheduled': false,
  'teacherBusy': false,
  'canSchedule': true,
};
const _attendanceRecord = {
  'id': 'att-1',
  'studentId': 'u-student-1',
  'classId': 'c-10a1',
  'slotId': 'tt-1',
  'date': '2026-08-12',
  'status': 'PRESENT',
  'note': 'Dung gio',
  'subjectName': 'Toan',
  'periodNo': 1,
};
const _dayStatus = {
  'attendanceRequired': true,
  'title': 'Ngay hoc binh thuong',
};
const _sessionStatus = {
  'state': 'OPEN',
  'canMark': true,
  'requiresUnlockReason': false,
  'message': 'Co the diem danh',
  'date': '2026-08-12',
  'startTime': '07:00',
  'endTime': '07:45',
};
const _unlockedSession = {
  'state': 'UNLOCKED',
  'canMark': true,
  'requiresUnlockReason': false,
  'message': 'Da mo khoa',
  'date': '2026-08-12',
  'startTime': '07:00',
  'endTime': '07:45',
  'unlockReason': 'Can dieu chinh ban ghi diem danh',
  'unlockedAt': '2026-08-12T08:00:00Z',
};
const _approvedLeave = {
  'id': 'leave-1',
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'classId': 'c-10a1',
  'classCode': '10A1',
  'startDate': '2026-08-12',
  'endDate': '2026-08-12',
  'reason': 'Kham benh',
  'status': 'APPROVED',
  'createdAt': '2026-08-11T08:00:00Z',
};
const _oralCategory = {
  'id': 'ec-oral',
  'code': 'ORAL',
  'name': 'Mieng',
  'weight': 1.0,
  'requiredCount': 1,
};
const _quizCategory = {
  'id': 'ec-quiz',
  'code': 'QUIZ',
  'name': 'Kiem tra nhanh',
  'weight': 1.0,
  'requiredCount': 2,
};
const _gradebookContext = {
  'classId': 'c-10a1',
  'semesterId': 'sm-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'homeroomTeacher': true,
  'canEdit': true,
  'subjects': [
    {
      'subjectId': 'sj-math',
      'subjectName': 'Toan',
      'teacherName': 'Nguyen Duc Minh',
      'editable': true,
    },
  ],
};
const _grade = {
  'id': 'g-1',
  'studentId': 'u-student-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'semesterId': 'sm-1',
  'category': 'ORAL',
  'categoryName': 'Mieng',
  'assessmentIndex': 1,
  'score': 8.5,
  'note': 'Dat',
  'recordedAt': '2026-08-12T08:00:00Z',
  'createdAt': '2026-08-12T08:00:00Z',
  'createdBy': 'u-teacher-1',
  'updatedAt': '2026-08-12T08:00:00Z',
  'updatedBy': 'u-teacher-1',
  'version': 0,
};
const _gradeLog = {
  'id': 'gcl-1',
  'gradeId': 'g-1',
  'action': 'UPDATE',
  'oldScore': 8.5,
  'newScore': 9.0,
  'oldNote': 'Dat',
  'newNote': 'Da doi chieu',
  'changedBy': 'u-teacher-1',
  'reason': 'Sua theo bai kiem tra',
  'changedAt': '2026-08-12T09:00:00Z',
};
const _examPeriod = {
  'id': 'ep-1',
  'code': 'HK1-2026',
  'name': 'Thi hoc ky 1',
  'academicYearId': 'ay-1',
  'semesterId': 'sm-1',
  'gradeLevel': 'K10',
  'startDate': '2026-12-15',
  'endDate': '2026-12-20',
  'status': 'PUBLISHED',
  'scoreEntryLocked': false,
  'schedulePublished': true,
  'scheduleRevision': 1,
  'createdAt': '2026-08-12T08:00:00Z',
  'updatedAt': '2026-08-12T08:00:00Z',
};
const _examPeriodSummary = {
  'period': _examPeriod,
  'scheduleCount': 1,
  'roomCount': 1,
  'candidateCount': 2,
  'resultCount': 1,
  'pendingReviewCount': 1,
};
const _examSchedule = {
  'id': 'es-1',
  'examPeriodId': 'ep-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'examDate': '2026-12-15',
  'startTime': '07:30',
  'durationMinutes': 90,
  'notes': 'Mang theo but',
  'classIds': ['c-10a1'],
};
const _examRoom = {
  'id': 'er-room-1',
  'scheduleId': 'es-1',
  'roomCode': 'P201',
  'capacity': 40,
  'proctorOneId': 'u-teacher-1',
  'proctorOneName': 'Nguyen Duc Minh',
};
const _examCandidateEntity = {
  'id': 'ec-1',
  'examPeriodId': 'ep-1',
  'scheduleId': 'es-1',
  'examRoomId': 'er-room-1',
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'studentCode': 'HS2025001',
  'classId': 'c-10a1',
  'classCode': '10A1',
  'candidateNo': 'C001',
  'seatNo': 1,
};
const _eligibleGrader = {
  'teacherId': 'u-teacher-1',
  'teacherCode': 'GV001',
  'teacherName': 'Nguyen Duc Minh',
};
const _examGrader = {
  'id': 'ega-1',
  'examPeriodId': 'ep-1',
  'scheduleId': 'es-1',
  'classId': 'c-10a1',
  'classCode': '10A1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'teacherId': 'u-teacher-1',
  'teacherName': 'Nguyen Duc Minh',
  'assignedAt': '2026-08-12T09:00:00Z',
  'assignedBy': 'u-academic-staff-1',
};
const _examAgenda = {
  'id': 'ea-1',
  'taskType': 'CANDIDATE',
  'taskLabel': 'Lich thi',
  'examPeriodId': 'ep-1',
  'examPeriodName': 'Thi hoc ky 1',
  'scheduleRevision': 1,
  'scheduleId': 'es-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'examDate': '2026-12-15',
  'startTime': '07:30',
  'durationMinutes': 90,
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'classCode': '10A1',
  'candidateNo': 'C001',
  'seatNo': 1,
  'roomCode': 'P201',
  'status': 'PUBLISHED',
};
const _examCandidate = {
  'candidateId': 'ec-1',
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'studentCode': 'HS2025001',
  'candidateNo': 'C001',
  'seatNo': 1,
  'roomCode': 'P201',
  'resultId': 'er-1',
  'score': 8.5,
  'resultStatus': 'PUBLISHED',
  'version': 0,
};
const _examGradingTask = {
  'examPeriodId': 'ep-1',
  'examPeriodName': 'Thi hoc ky 1',
  'scheduleId': 'es-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'classId': 'c-10a1',
  'classCode': '10A1',
  'examDate': '2026-12-15',
  'startTime': '07:30',
  'scoreEntryAvailable': true,
  'scoreEntryLocked': false,
  'candidates': [_examCandidate],
};
const _examResult = {
  'resultId': 'er-1',
  'examPeriodId': 'ep-1',
  'examPeriodName': 'Thi hoc ky 1',
  'scheduleId': 'es-1',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'score': 8.5,
  'resultStatus': 'PUBLISHED',
};
const _examReview = {
  'id': 'erv-1',
  'examPeriodId': 'ep-1',
  'resultId': 'er-1',
  'studentId': 'u-student-1',
  'studentName': 'Nguyen Minh An',
  'subjectId': 'sj-math',
  'subjectName': 'Toan',
  'originalScore': 8.5,
  'reason': 'De nghi kiem tra lai diem bai thi',
  'status': 'PENDING',
  'requestedAt': '2026-12-21T08:00:00Z',
  'requestedBy': 'u-student-1',
};
