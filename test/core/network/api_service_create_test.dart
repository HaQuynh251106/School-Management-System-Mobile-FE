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
            data: <String, dynamic>{'id': 'created-id'},
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
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/users');
    expect((requests.single.data as Map)['role'], 'STUDENT');
  });

  test('loads a parent dashboard with the selected child scope', () async {
    await api.dashboard(childId: 'u-student-1');

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/dashboard');
    expect(requests.single.queryParameters['childId'], 'u-student-1');
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

  test('submits assignment content with a private attachment id', () async {
    await api.submitAssignment(
      'assignment-1',
      content: 'Bài làm của học sinh',
      attachmentFileId: 'file-1',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/assignments/assignment-1/submit');
    expect((requests.single.data as Map)['content'], 'Bài làm của học sinh');
    expect((requests.single.data as Map)['attachmentFileId'], 'file-1');
  });

  test('grades a submission with score and feedback', () async {
    await api.gradeSubmission(
      'submission-1',
      score: 8.5,
      feedback: 'Hoàn thành tốt',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/submissions/submission-1/grade');
    expect((requests.single.data as Map)['score'], 8.5);
    expect((requests.single.data as Map)['feedback'], 'Hoàn thành tốt');
  });

  test('uploads a text attachment with the MIME type required by backend',
      () async {
    await api.uploadFile(
      bytes: 'F11 attachment'.codeUnits,
      fileName: 'bai-nop.txt',
    );

    final form = requests.single.data as FormData;
    final file = form.files.single.value;
    expect(requests.single.path, '/files');
    expect(file.filename, 'bai-nop.txt');
    expect(file.contentType.toString(), 'text/plain');
  });

  test('closes and reopens assignment through lifecycle endpoints', () async {
    await api.closeAssignment('assignment-1');
    await api.reopenAssignment('assignment-1');

    expect(requests[0].path, '/assignments/assignment-1/close');
    expect(requests[1].path, '/assignments/assignment-1/reopen');
  });

  test('updates late policy and extends assignment deadline', () async {
    await api.updateAssignment('assignment-1', {'allowLate': true});
    final deadline = DateTime.utc(2026, 8, 20, 23, 59);
    await api.extendAssignment('assignment-1', deadline);

    expect(requests[0].method, 'PUT');
    expect((requests[0].data as Map)['allowLate'], isTrue);
    expect(requests[1].path, '/assignments/assignment-1/extend');
    expect((requests[1].data as Map)['deadline'], deadline.toIso8601String());
  });

  test('records partial cash payment through finance contract', () async {
    await api.recordCashPayment(
      'invoice-1',
      amount: 250000,
      payerName: 'Nguyễn Văn Hùng',
      note: 'Thu tại văn phòng',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/payments/cash');
    expect((requests.single.data as Map)['invoiceId'], 'invoice-1');
    expect((requests.single.data as Map)['amount'], 250000);
    expect((requests.single.data as Map)['payerName'], 'Nguyễn Văn Hùng');
    expect((requests.single.data as Map)['note'], 'Thu tại văn phòng');
  });

  test('refunds an invoice with amount and audit reason', () async {
    await api.refundInvoice('invoice-1', 100000, 'Điều chỉnh khoản thu');

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/invoices/invoice-1/refund');
    expect((requests.single.data as Map)['amount'], 100000);
    expect((requests.single.data as Map)['reason'], 'Điều chỉnh khoản thu');
  });

  test('previews the exact teacher announcement audience', () async {
    await api.previewTeacherAnnouncement(
      classId: 'c-10a1',
      target: 'CLASS_ALL',
      category: 'STUDENT_STATUS',
    );

    expect(requests.single.path, '/announcements/preview');
    expect((requests.single.data as Map)['audience'], 'CLASS_ALL:c-10a1');
    expect((requests.single.data as Map)['category'], 'STUDENT_STATUS');
  });

  test('sends teacher announcement with a stable idempotency key', () async {
    await api.sendTeacherAnnouncement(
      classId: 'c-10a1',
      target: 'CLASS_PARENTS',
      category: 'STUDENT_STATUS',
      priority: 'IMPORTANT',
      title: 'Thông báo lớp',
      body: 'Nội dung kiểm thử',
      idempotencyKey: 'mobile-f12-test',
    );

    expect(requests.single.path, '/announcements');
    expect((requests.single.data as Map)['audience'], 'CLASS_PARENTS:c-10a1');
    expect((requests.single.data as Map)['idempotencyKey'], 'mobile-f12-test');
  });

  test('registers a selected child for a club', () async {
    await api.registerClub('club-robotics', studentId: 'u-student-2');

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/clubs/club-robotics/registrations');
    expect((requests.single.data as Map)['studentId'], 'u-student-2');
  });

  test('creates a club with capacity fee approval and registration window',
      () async {
    await api.createClub({
      'code': 'F13-MOBILE',
      'name': 'CLB Mobile',
      'schedule': 'Thứ Bảy 08:00',
      'capacity': 20,
      'feeAmount': 150000,
      'approvalRequired': true,
      'registrationStart': '2026-08-01',
      'registrationEnd': '2026-08-31',
    });

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/clubs');
    expect((requests.single.data as Map)['capacity'], 20);
    expect((requests.single.data as Map)['approvalRequired'], isTrue);
  });

  test('approves and rejects club registrations through admin contracts',
      () async {
    await api.approveClubRegistration('registration-1', note: 'Đủ điều kiện');
    await api.rejectClubRegistration('registration-2', note: 'Không phù hợp');

    expect(requests[0].path, '/club-registrations/registration-1/approve');
    expect((requests[0].data as Map)['note'], 'Đủ điều kiện');
    expect(requests[1].path, '/club-registrations/registration-2/reject');
    expect((requests[1].data as Map)['note'], 'Không phù hợp');
  });

  test('exports the filtered admin report as bytes', () async {
    final exportRequests = <RequestOptions>[];
    final exportDio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'));
    exportDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          exportRequests.add(options);
          handler.resolve(Response<List<int>>(
            requestOptions: options,
            statusCode: 200,
            data: const [0x50, 0x4b, 0x03, 0x04],
          ));
        },
      ),
    );

    final bytes = await ApiService(exportDio).exportReport(
      type: 'grades',
      format: 'xlsx',
      semesterId: 'semester-1',
      classId: 'class-10a1',
      subjectId: 'subject-math',
    );

    expect(bytes, const [0x50, 0x4b, 0x03, 0x04]);
    expect(exportRequests.single.path, '/reports/export');
    expect(exportRequests.single.responseType, ResponseType.bytes);
    expect(
        exportRequests.single.queryParameters, containsPair('type', 'grades'));
    expect(
        exportRequests.single.queryParameters, containsPair('format', 'xlsx'));
    expect(exportRequests.single.queryParameters,
        containsPair('semesterId', 'semester-1'));
    expect(exportRequests.single.queryParameters,
        containsPair('classId', 'class-10a1'));
    expect(exportRequests.single.queryParameters,
        containsPair('subjectId', 'subject-math'));
  });

  test('updates an F16 fee period with an explicit class scope', () async {
    await api.updateFeePeriod('fee-period-1', {
      'name': 'Hoc phi thang 9',
      'scopeType': 'CLASS',
      'scopeClassId': 'class-10a1',
      'studentIds': <String>[],
    });

    expect(requests.single.method, 'PUT');
    expect(requests.single.path, '/fee-periods/fee-period-1');
    expect((requests.single.data as Map)['scopeType'], 'CLASS');
    expect((requests.single.data as Map)['scopeClassId'], 'class-10a1');
  });

  test('calls the F16 preview and approval endpoints in order', () async {
    await api.feePeriodPreview('fee-period-1');
    await api.openFeePeriod('fee-period-1');

    expect(requests[0].method, 'GET');
    expect(requests[0].path, '/fee-periods/fee-period-1/preview');
    expect(requests[1].method, 'POST');
    expect(requests[1].path, '/fee-periods/fee-period-1/open');
  });

  test('adds a fee item and student discount through F16 contracts', () async {
    await api.addFeePeriodItem('fee-period-1', {
      'name': 'Hoc phi',
      'amount': 1000000,
    });
    await api.saveFeePeriodAdjustment('fee-period-1', {
      'studentId': 'u-student-1',
      'type': 'DISCOUNT',
      'amount': 100000,
      'reason': 'Khuyen hoc',
    });

    expect(requests[0].path, '/fee-periods/fee-period-1/items');
    expect((requests[0].data as Map)['amount'], 1000000);
    expect(requests[1].path, '/fee-periods/fee-period-1/adjustments');
    expect((requests[1].data as Map)['type'], 'DISCOUNT');
  });

  test('cancels a club registration with a reason', () async {
    await api.cancelClubRegistration('registration-1', reason: 'Trùng lịch');

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/club-registrations/registration-1/cancel');
    expect((requests.single.data as Map)['reason'], 'Trùng lịch');
  });
}
