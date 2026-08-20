import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/parent/presentation/pages/invoice_detail.dart';

void main() {
  testWidgets('payment sheet exposes the Web bank-transfer flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InvoiceDetailPage(
          invoiceId: 'invoice-1',
          invoiceCode: 'INV-1',
          childName: 'Học sinh A',
          semester: 'Học phí tháng 8',
          dueDate: '2026-08-31',
          items: [InvoiceLineItem('Học phí', 500000)],
          status: 'UNPAID',
        ),
      ),
    );

    await tester.tap(find.textContaining('Thanh toán'));
    await tester.pumpAndSettle();

    expect(find.text('Chuyển khoản ngân hàng'), findsOneWidget);
    expect(find.text('Thanh toán trực tuyến'), findsNothing);
    expect(find.byIcon(Icons.open_in_browser_rounded), findsNothing);
  });
}
