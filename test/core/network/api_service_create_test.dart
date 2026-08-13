import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/api_service.dart';

void main() {
  late Dio dio;
  late ApiService api;
  late List<RequestOptions> requests;

  setUp(() {
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: options.path.endsWith('/timetable') ||
                    (options.method == 'GET' &&
                        (options.path.endsWith('/assignments') ||
                            options.path.endsWith('/submissions') ||
                            options.path.endsWith('/attempts'))) ||
                    options.path == '/grades/bulk' ||
                    options.path == '/attendance/bulk' ||
                    (options.path.contains('/exam-periods/') &&
                        options.path.endsWith('/results')) ||
                    options.path.contains('/exam-results')
                ? <dynamic>[]
                : options.path == '/chat/messages/page' ||
                        options.path == '/notifications/page'
                    ? <String, dynamic>{
                        'items': <dynamic>[],
                        'page': 0,
                        'size': 100,
                      }
                    : <String, dynamic>{'id': 'created-id'},
          ));
        },
      ),
    );
    api = ApiService(dio);
  });

  test('creates a user through the real backend contract', () async {
    await api.createUser({
      'username': 'hs.test',
      'password': 'Password123@',
      'fullName': 'Học sinh kiểm thử',
      'role': 'STUDENT',
      'email': 'student.test@example.test',
      'phone': '0901234567',
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/users');
    expect((requests.single.data as Map)['role'], 'STUDENT');
    expect((requests.single.data as Map)['email'], 'student.test@example.test');
    expect((requests.single.data as Map)['phone'], '0901234567');
    expect((requests.single.data as Map).containsKey('studentCode'), isFalse);
  });

  test('creates and publishes an assignment with its class and subject',
      () async {
    await api.createAssignment({
      'classId': 'class-10a1',
      'subjectId': 'subject-math',
      'title': 'Bài tập chương 1',
      'publishNow': true,
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/assignments');
    expect((requests.single.data as Map)['classId'], 'class-10a1');
    expect((requests.single.data as Map)['publishNow'], isTrue);
  });

  test('submits and grades an assignment through shared endpoints', () async {
    await api.submitAssignment(
      'assignment-1',
      content: 'Bài làm thật',
      attachmentFileId: 'file-1',
    );
    await api.gradeSubmission(
      'submission-1',
      score: 8.5,
      feedback: 'Đạt yêu cầu',
    );

    expect(requests[0].path, '/assignments/assignment-1/submit');
    expect((requests[0].data as Map)['attachmentFileId'], 'file-1');
    expect(requests[1].path, '/submissions/submission-1/grade');
    expect((requests[1].data as Map)['score'], 8.5);
  });

  test('parent and teacher reuse the canonical assignment submission APIs',
      () async {
    await api.childAssignments('student-1');
    await api.childSubmissions('student-1');
    await api.submissionAttempts('submission-1');

    expect(requests[0].path, '/children/student-1/assignments');
    expect(requests[1].path, '/children/student-1/submissions');
    expect(requests[2].path, '/submissions/submission-1/attempts');
  });

  test('payment initiation never invokes the backend sandbox callback',
      () async {
    await api.pay('invoice-1');

    expect(requests, hasLength(1));
    expect(requests.single.path, '/payments');
  });

  test('uses the shared Web contract when previewing a grade timetable',
      () async {
    await api.autoPlanTimetable(
      'semester-1',
      false,
      scopeGradeLevel: 'K10',
      draftName: 'TKB khối 10',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/timetableSlots/auto-plan');
    expect((requests.single.data as Map)['semesterId'], 'semester-1');
    expect((requests.single.data as Map)['apply'], isFalse);
    expect((requests.single.data as Map)['scopeGradeLevel'], 'K10');
    expect((requests.single.data as Map)['draftName'], 'TKB khối 10');
  });

  test('sends assessment index and expected version when updating a grade',
      () async {
    await api.bulkGrades(
      classId: 'class-10a1',
      subjectId: 'subject-math',
      semesterId: 'semester-1',
      category: '15M',
      assessmentIndex: 2,
      reason: 'Sửa sau đối chiếu bài',
      entries: [
        {'studentId': 'student-1', 'score': 8.5, 'expectedVersion': 3},
      ],
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/grades/bulk');
    final body = requests.single.data as Map;
    expect(body['assessmentIndex'], 2);
    expect(body['reason'], 'Sửa sau đối chiếu bài');
    expect((body['entries'] as List).single['expectedVersion'], 3);
  });

  test('uses one shared exam result contract with optimistic version',
      () async {
    await api.saveExamResults(
      'period-1',
      scheduleId: 'schedule-1',
      entries: [
        {
          'studentId': 'student-1',
          'score': 9.0,
          'note': 'Đã đối chiếu',
          'expectedVersion': 4,
        },
      ],
    );

    expect(requests.single.method, 'PUT');
    expect(requests.single.path, '/exam-periods/period-1/results');
    final body = requests.single.data as Map;
    expect(body['scheduleId'], 'schedule-1');
    expect((body['entries'] as List).single['expectedVersion'], 4);
  });

  test('sends attendance expected version when updating an existing mark',
      () async {
    await api.bulkAttendance(
      slotId: 'slot-1',
      date: '2026-08-12',
      marks: [
        {
          'studentId': 'student-1',
          'status': 'PRESENT',
          'expectedVersion': 2,
        },
      ],
    );

    expect(requests.single.path, '/attendance/bulk');
    expect(
        ((requests.single.data as Map)['marks'] as List)
            .single['expectedVersion'],
        2);
  });

  test('parent reads the selected child exam result contract', () async {
    await api.childExamResults('student-1');

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/children/student-1/exam-results');
  });

  test('parent reads the selected child published timetable contract',
      () async {
    await api.childTimetable('student-1');

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/children/student-1/timetable');
  });

  test('student requests and teacher resolves an exam review', () async {
    await api.requestExamReview(
      'period-1',
      resultId: 'result-1',
      reason: 'Cần kiểm tra lại phần tự luận',
    );
    await api.resolveExamReview(
      'review-1',
      status: 'APPROVED',
      resolution: 'Đã đối chiếu lại đáp án',
      resolvedScore: 9.25,
    );

    expect(requests[0].path, '/exam-periods/period-1/reviews');
    expect(requests[1].path, '/exam-reviews/review-1/resolve');
    expect((requests[1].data as Map)['resolvedScore'], 9.25);
  });

  test('uses pageable canonical contracts for chat and notification inbox',
      () async {
    await api.chatMessages('teacher-1');
    await api.notifications();

    expect(requests[0].path, '/chat/messages/page');
    expect(requests[0].queryParameters['withUserId'], 'teacher-1');
    expect(requests[1].path, '/notifications/page');
    expect(requests[1].queryParameters['size'], 100);
  });
}
