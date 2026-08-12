import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sse_mobile/app.dart';
import 'package:sse_mobile/core/config/env.dart';
import 'package:sse_mobile/core/di/service_locator.dart';
import 'package:sse_mobile/core/storage/token_storage.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sse_mobile/features/auth/presentation/bloc/auth_event.dart';

const _adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');
const _accountantPassword = String.fromEnvironment('E2E_ACCOUNTANT_PASSWORD');
const _parentPassword = String.fromEnvironment('E2E_PARENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'F17 UI Parent creates VietQR and Accountant reconciles it',
    (tester) async {
      expect(
        [_adminPassword, _accountantPassword, _parentPassword]
            .every((value) => value.isNotEmpty),
        isTrue,
        reason: 'Thiếu biến E2E_ADMIN/ACCOUNTANT/PARENT_PASSWORD',
      );

      final dio = Dio(BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final adminToken = await _loginApi(dio, 'admin', _adminPassword);
      final parentToken =
          await _loginApi(dio, 'ph.nguyenvanhung', _parentPassword);
      final accountantToken =
          await _loginApi(dio, 'ketoan', _accountantPassword);
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final fixture = await _createInvoice(dio, adminToken, suffix);

      await initializeDateFormatting('vi_VN');
      FlutterSecureStorage.setMockInitialValues({});
      if (!sl.isRegistered<AuthBloc>()) await setupServiceLocator();
      await sl<TokenStorage>().clearAll();
      final authBloc = sl<AuthBloc>()..add(const AuthStarted());
      addTearDown(authBloc.close);

      await tester.pumpWidget(
        BlocProvider.value(value: authBloc, child: const SseApp()),
      );
      await _waitFor(tester, find.text('Đăng nhập'));
      await _loginUi(
        tester,
        username: 'ph.nguyenvanhung',
        password: _parentPassword,
        expectedText: 'Tài chính',
      );

      await tester.tap(find.text('Tài chính').last);
      await _waitFor(tester, find.textContaining('Hóa đơn —'));
      await _waitFor(tester, find.byType(Scrollable));
      final invoiceCode = find.text(fixture.invoiceCode);
      if (invoiceCode.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          invoiceCode,
          500,
          scrollable: find.byType(Scrollable).last,
        );
      }
      final invoiceCard = find.ancestor(
        of: invoiceCode,
        matching: find.byType(Card),
      );
      expect(invoiceCard, findsOneWidget);
      await tester.tap(find.descendant(
        of: invoiceCard,
        matching: find.text('Tạo VietQR'),
      ));

      await _waitFor(tester, find.text(fixture.invoiceCode));
      final createQrButton = find.textContaining('Tạo mã VietQR');
      await _waitFor(tester, createQrButton);
      await tester.tap(createQrButton);
      await _waitFor(tester, find.text('VietQR - Techcombank'));
      await tester.tap(find.text('VietQR - Techcombank'));
      await _waitFor(
        tester,
        find.text('Tôi đã chuyển khoản'),
        timeout: const Duration(seconds: 20),
      );
      await tester.tap(find.text('Tôi đã chuyển khoản'));
      await tester.pump(const Duration(seconds: 2));

      final pending = await dio.get<List<dynamic>>(
        '/payments/vietqr/pending',
        options: _auth(accountantToken),
      );
      final pendingItem = pending.data!.cast<Map>().firstWhere(
            (item) => (item['invoice'] as Map)['id'] == fixture.invoiceId,
          );
      final paymentId = (pendingItem['payment'] as Map)['id'].toString();
      final transferContent = pendingItem['transferContent'].toString();

      authBloc.add(const AuthLogoutRequested());
      await _waitFor(tester, find.text('Đăng nhập'));
      await _loginUi(
        tester,
        username: 'ketoan',
        password: _accountantPassword,
        expectedText: 'Trung tâm Kế toán',
      );
      await tester.tap(find.text('Đối soát').last);
      await _waitFor(tester, find.text('Đối soát VietQR'));
      final transferFinder = find.text('Nội dung: $transferContent');
      await _waitFor(tester, transferFinder);
      final reconciliationCard = find.ancestor(
        of: transferFinder,
        matching: find.byType(Card),
      );
      await tester.tap(find.descendant(
        of: reconciliationCard,
        matching: find.text('Xác nhận'),
      ));
      await _waitFor(tester, find.text('Xác nhận giao dịch VietQR'));
      await tester.enterText(
        find.byType(TextField).last,
        'F17UI$suffix',
      );
      await tester.tap(find.text('Xác nhận đã nhận'));
      await _waitUntilAbsent(tester, transferFinder);

      final detail = await dio.get<Map<String, dynamic>>(
        '/invoices/${fixture.invoiceId}',
        options: _auth(parentToken),
      );
      final invoice = (detail.data!['invoice'] as Map).cast<String, dynamic>();
      expect(invoice['status'], 'PAID');
      expect(invoice['paidAmount'], fixture.amount);

      final pendingAfter = await dio.get<List<dynamic>>(
        '/payments/vietqr/pending',
        options: _auth(accountantToken),
      );
      expect(
        pendingAfter.data!.cast<Map>().any(
              (item) => (item['payment'] as Map)['id'] == paymentId,
            ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

class _InvoiceFixture {
  const _InvoiceFixture({
    required this.invoiceId,
    required this.invoiceCode,
    required this.amount,
  });

  final String invoiceId;
  final String invoiceCode;
  final int amount;
}

Future<_InvoiceFixture> _createInvoice(
  Dio dio,
  String adminToken,
  int suffix,
) async {
  const amount = 149000;
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
      'code': 'F17-UI-$suffix',
      'name': 'F17 UI automated E2E $suffix',
      'academicYearId': activeYear['id'],
      'scopeType': 'CLASS',
      'scopeClassId': targetClass['id'],
      'dueDate': '2026-09-30',
    },
    options: _auth(adminToken),
  );
  final periodId = period.data!['id'].toString();
  await dio.post<Map<String, dynamic>>(
    '/fee-periods/$periodId/items',
    data: {'name': 'Khoản kiểm thử UI VietQR', 'amount': amount},
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
  final invoice = (generated.data!.single as Map).cast<String, dynamic>();
  return _InvoiceFixture(
    invoiceId: invoice['id'].toString(),
    invoiceCode: invoice['code'].toString(),
    amount: amount,
  );
}

Future<void> _loginUi(
  WidgetTester tester, {
  required String username,
  required String password,
  required String expectedText,
}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(2));
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
  await _waitFor(
    tester,
    find.text(expectedText),
    timeout: const Duration(seconds: 20),
  );
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final attempts = timeout.inMilliseconds ~/ 250;
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

Future<void> _waitUntilAbsent(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final attempts = timeout.inMilliseconds ~/ 250;
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isEmpty) return;
  }
  expect(finder, findsNothing);
}

Future<String> _loginApi(Dio dio, String username, String password) async {
  final response = await dio.post<Map<String, dynamic>>(
    '/auth/login',
    data: {'username': username, 'password': password},
  );
  return response.data!['accessToken'].toString();
}

Options _auth(String token) => Options(
      headers: {'Authorization': 'Bearer $token'},
    );
