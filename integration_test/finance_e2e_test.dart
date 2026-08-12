import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sse_mobile/core/config/env.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const _accountantPassword = String.fromEnvironment('E2E_ACCOUNTANT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'F17 Parent VietQR -> Accountant reconcile is idempotent',
    (tester) async {
      expect(
        [
          _adminPassword,
          _accountantPassword,
          _parentPassword,
        ].every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến E2E_ADMIN/ACCOUNTANT/PARENT_PASSWORD',
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final admin = await _login(dio, 'admin', _adminPassword);
      final parent = await _login(dio, 'ph.nguyenvanhung', _parentPassword);
      final accountant = await _login(dio, 'ketoan', _accountantPassword);
      final suffix = DateTime.now().millisecondsSinceEpoch;

      final years = await dio.get<List<dynamic>>(
        '/academicYears',
        options: _auth(admin),
      );
      final activeYear = years.data!.cast<Map>().firstWhere(
        (year) => year['status'] == 'ACTIVE',
        orElse: () => years.data!.cast<Map>().first,
      );
      final classes = await dio.get<List<dynamic>>(
        '/classes',
        options: _auth(admin),
      );
      final targetClass = classes.data!.cast<Map>().firstWhere(
        (item) => item['code'] == '10A1',
      );

      final periodResponse = await dio.post<Map<String, dynamic>>(
        '/fee-periods',
        data: {
          'code': 'F17-E2E-$suffix',
          'name': 'F17 Android automated E2E $suffix',
          'academicYearId': activeYear['id'],
          'scopeType': 'CLASS',
          'scopeClassId': targetClass['id'],
          'dueDate': '2026-09-30',
        },
        options: _auth(admin),
      );
      final periodId = periodResponse.data!['id'].toString();

      await dio.post<Map<String, dynamic>>(
        '/fee-periods/$periodId/items',
        data: {'name': 'Khoản kiểm thử VietQR', 'amount': 137000},
        options: _auth(admin),
      );
      await dio.post<Map<String, dynamic>>(
        '/fee-periods/$periodId/open',
        options: _auth(admin),
      );
      final generated = await dio.post<List<dynamic>>(
        '/fee-periods/$periodId/generate-invoices',
        options: _auth(admin),
      );
      expect(generated.data, hasLength(1));
      final invoice = (generated.data!.single as Map).cast<String, dynamic>();
      final invoiceId = invoice['id'].toString();
      expect(invoice['status'], 'UNPAID');
      expect(invoice['totalAmount'], 137000);

      final initiated = await dio.post<Map<String, dynamic>>(
        '/payments',
        data: {'invoiceId': invoiceId, 'method': 'VIETQR'},
        options: _auth(parent),
      );
      final payment = (initiated.data!['payment'] as Map)
          .cast<String, dynamic>();
      final paymentId = payment['id'].toString();
      expect(initiated.data!['transferContent'], isNotEmpty);
      expect(initiated.data!['qrImageUrl'], isNotEmpty);

      final submitted = await dio.post<Map<String, dynamic>>(
        '/payments/$paymentId/submitted',
        options: _auth(parent),
      );
      expect(submitted.data!['gatewayStatus'], 'AWAITING_CONFIRMATION');

      final submittedAgain = await dio.post<Map<String, dynamic>>(
        '/payments/$paymentId/submitted',
        options: _auth(parent),
      );
      expect((submittedAgain.data!['payment'] as Map)['id'], paymentId);

      final pending = await dio.get<List<dynamic>>(
        '/payments/vietqr/pending',
        options: _auth(accountant),
      );
      expect(
        pending.data!.cast<Map>().any(
          (item) => (item['payment'] as Map)['id'] == paymentId,
        ),
        isTrue,
      );

      final bankReference = 'F17AUTO$suffix';
      final confirmed = await dio.post<Map<String, dynamic>>(
        '/payments/$paymentId/confirm-vietqr',
        data: {'bankTransactionRef': bankReference},
        options: _auth(accountant),
      );
      final firstPayment = (confirmed.data!['payment'] as Map)
          .cast<String, dynamic>();
      final firstInvoice = (confirmed.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect(firstPayment['status'], 'SUCCESS');
      expect(firstPayment['receiptCode'], isNotEmpty);
      expect(firstInvoice['status'], 'PAID');
      expect(firstInvoice['paidAmount'], 137000);

      final confirmedAgain = await dio.post<Map<String, dynamic>>(
        '/payments/$paymentId/confirm-vietqr',
        data: {'bankTransactionRef': bankReference},
        options: _auth(accountant),
      );
      final repeatedPayment = (confirmedAgain.data!['payment'] as Map)
          .cast<String, dynamic>();
      final repeatedInvoice = (confirmedAgain.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect(repeatedPayment['receiptCode'], firstPayment['receiptCode']);
      expect(repeatedInvoice['paidAmount'], 137000);
      expect(repeatedInvoice['version'], firstInvoice['version']);

      final pendingAfter = await dio.get<List<dynamic>>(
        '/payments/vietqr/pending',
        options: _auth(accountant),
      );
      expect(
        pendingAfter.data!.cast<Map>().any(
          (item) => (item['payment'] as Map)['id'] == paymentId,
        ),
        isFalse,
      );

      final detail = await dio.get<Map<String, dynamic>>(
        '/invoices/$invoiceId',
        options: _auth(parent),
      );
      final persistedInvoice = (detail.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect(persistedInvoice['status'], 'PAID');
      expect(persistedInvoice['paidAmount'], 137000);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'S01 cash and refund follow every invoice state on Android',
    (tester) async {
      expect(
        [
          _adminPassword,
          _accountantPassword,
        ].every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến E2E_ADMIN_PASSWORD hoặc E2E_ACCOUNTANT_PASSWORD',
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final admin = await _login(dio, 'admin', _adminPassword);
      final accountant = await _login(dio, 'ketoan', _accountantPassword);
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final invoice = await _createStateMachineInvoice(dio, admin, suffix);
      final invoiceId = invoice['id'].toString();

      expect(invoice['status'], 'UNPAID');
      expect(invoice['totalAmount'], 1000000);

      final partial = await _recordCash(
        dio,
        accountant,
        invoiceId,
        amount: 250000,
        note: 'S01 Android E2E partial $suffix',
      );
      expect(partial.statusCode, 200);
      expect(_invoiceOf(partial)['status'], 'PARTIAL');
      expect(_invoiceOf(partial)['paidAmount'], 250000);

      final paid = await _recordCash(
        dio,
        accountant,
        invoiceId,
        amount: 750000,
        note: 'S01 Android E2E paid $suffix',
      );
      expect(paid.statusCode, 200);
      expect(_invoiceOf(paid)['status'], 'PAID');
      expect(_invoiceOf(paid)['paidAmount'], 1000000);

      final collectAfterPaid = await _recordCash(
        dio,
        accountant,
        invoiceId,
        amount: 1,
        note: 'S01 Android E2E must be blocked',
      );
      expect(collectAfterPaid.statusCode, 409);

      final partialRefund = await _refund(
        dio,
        accountant,
        invoiceId,
        amount: 300000,
        reason: 'S01 Android E2E partial refund $suffix',
      );
      expect(partialRefund.statusCode, 200);
      expect(_invoiceOf(partialRefund)['status'], 'PARTIALLY_REFUNDED');
      expect(_invoiceOf(partialRefund)['refundedAmount'], 300000);

      final fullRefund = await _refund(
        dio,
        accountant,
        invoiceId,
        amount: 700000,
        reason: 'S01 Android E2E full refund $suffix',
      );
      expect(fullRefund.statusCode, 200);
      expect(_invoiceOf(fullRefund)['status'], 'REFUNDED');
      expect(_invoiceOf(fullRefund)['refundedAmount'], 1000000);

      final refundAfterTerminal = await _refund(
        dio,
        accountant,
        invoiceId,
        amount: 1,
        reason: 'S01 Android E2E must be blocked',
      );
      expect(refundAfterTerminal.statusCode, 409);

      final detail = await dio.get<Map<String, dynamic>>(
        '/invoices/$invoiceId',
        options: _auth(accountant),
      );
      expect(detail.statusCode, 200);
      final persisted = (detail.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect(persisted['status'], 'REFUNDED');
      expect(persisted['paidAmount'], 1000000);
      expect(persisted['refundedAmount'], 1000000);
      expect((detail.data!['payments'] as List), hasLength(2));
      expect((detail.data!['refunds'] as List), hasLength(2));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'Q02 payment callback is authenticated and idempotent on Android',
    (tester) async {
      expect(_adminPassword, isNotEmpty, reason: 'Thiếu E2E_ADMIN_PASSWORD');
      final dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final admin = await _login(dio, 'admin', _adminPassword);
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final invoice = await _createStateMachineInvoice(dio, admin, suffix);
      final invoiceId = invoice['id'].toString();
      final idempotencyKey = 'q02-android-$suffix';

      Future<Map<String, dynamic>> createPayment() async {
        final response = await dio.post<Map<String, dynamic>>(
          '/payments',
          data: {
            'invoiceId': invoiceId,
            'method': 'SANDBOX',
            'idempotencyKey': idempotencyKey,
          },
          options: _auth(admin),
        );
        return response.data!;
      }

      final initiated = await createPayment();
      final repeatedInitiation = await createPayment();
      final payment = (initiated['payment'] as Map).cast<String, dynamic>();
      final paymentId = payment['id'].toString();
      final txnRef = payment['txnRef'].toString();
      expect((repeatedInitiation['payment'] as Map)['id'], paymentId);
      expect(initiated['paymentUrl'], contains(txnRef));

      final beforeCallback = await dio.get<Map<String, dynamic>>(
        '/payments/$paymentId/status',
        options: _auth(admin),
      );
      expect((beforeCallback.data!['payment'] as Map)['status'], 'PENDING');

      Future<void> completeCheckout() async {
        await dio.post<String>(
          '/payments/sandbox/checkout/complete',
          data: {'txnRef': txnRef, 'outcome': 'SUCCESS'},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
          ),
        );
      }

      await completeCheckout();
      final completed = await dio.get<Map<String, dynamic>>(
        '/payments/$paymentId/status',
        options: _auth(admin),
      );
      final paidInvoice = (completed.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect((completed.data!['payment'] as Map)['status'], 'SUCCESS');
      expect(paidInvoice['status'], 'PAID');
      expect(paidInvoice['paidAmount'], 1000000);
      final versionAfterFirstCallback = paidInvoice['version'];

      await completeCheckout();
      final repeatedCallback = await dio.get<Map<String, dynamic>>(
        '/payments/$paymentId/status',
        options: _auth(admin),
      );
      final invoiceAfterRepeat = (repeatedCallback.data!['invoice'] as Map)
          .cast<String, dynamic>();
      expect(invoiceAfterRepeat['paidAmount'], 1000000);
      expect(invoiceAfterRepeat['version'], versionAfterFirstCallback);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<Map<String, dynamic>> _createStateMachineInvoice(
  Dio dio,
  String adminToken,
  int suffix,
) async {
  final years = await dio.get<List<dynamic>>(
    '/academicYears',
    options: _auth(adminToken),
  );
  final activeYear = years.data!.cast<Map>().firstWhere(
    (year) => year['status'] == 'ACTIVE',
    orElse: () => years.data!.cast<Map>().first,
  );
  final classes = await dio.get<List<dynamic>>(
    '/classes',
    options: _auth(adminToken),
  );
  final targetClass = classes.data!.cast<Map>().firstWhere(
    (item) => item['code'] == '10A1',
  );
  final period = await dio.post<Map<String, dynamic>>(
    '/fee-periods',
    data: {
      'code': 'S01-ANDROID-$suffix',
      'name': 'S01 Android state machine $suffix',
      'academicYearId': activeYear['id'],
      'scopeType': 'CLASS',
      'scopeClassId': targetClass['id'],
      'dueDate': '2026-09-30',
    },
    options: _auth(adminToken),
  );
  expect(period.statusCode, 200);
  final periodId = period.data!['id'].toString();
  await dio.post<Map<String, dynamic>>(
    '/fee-periods/$periodId/items',
    data: {'name': 'S01 Android cash and refund', 'amount': 1000000},
    options: _auth(adminToken),
  );
  await dio.post<Map<String, dynamic>>(
    '/fee-periods/$periodId/open',
    options: _auth(adminToken),
  );
  final generated = await dio.post<List<dynamic>>(
    '/fee-periods/$periodId/generate-invoices',
    options: _auth(adminToken),
  );
  expect(generated.statusCode, 200);
  expect(generated.data, hasLength(1));
  return (generated.data!.single as Map).cast<String, dynamic>();
}

Future<Response<Map<String, dynamic>>> _recordCash(
  Dio dio,
  String token,
  String invoiceId, {
  required int amount,
  required String note,
}) => dio.post<Map<String, dynamic>>(
  '/payments/cash',
  data: {'invoiceId': invoiceId, 'amount': amount, 'note': note},
  options: _auth(token),
);

Future<Response<Map<String, dynamic>>> _refund(
  Dio dio,
  String token,
  String invoiceId, {
  required int amount,
  required String reason,
}) => dio.post<Map<String, dynamic>>(
  '/invoices/$invoiceId/refund',
  data: {'amount': amount, 'reason': reason},
  options: _auth(token),
);

Map<String, dynamic> _invoiceOf(Response<Map<String, dynamic>> response) =>
    (response.data!['invoice'] as Map).cast<String, dynamic>();

Future<String> _login(Dio dio, String username, String password) async {
  final response = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': username, 'password': password},
  );
  return response.data!['accessToken'].toString();
}

Options _auth(String token) =>
    Options(headers: {'Authorization': 'Bearer $token'});
