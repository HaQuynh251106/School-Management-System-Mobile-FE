import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/widgets/invoice_state_indicator.dart';

void main() {
  const states = <String, String>{
    'UNPAID': 'Chờ thanh toán',
    'OVERDUE': 'Đã quá hạn',
    'PARTIAL': 'Đã thanh toán một phần',
    'PAID': 'Đã thanh toán đủ',
    'PARTIALLY_REFUNDED': 'Đã hoàn một phần',
    'REFUNDED': 'Đã hoàn toàn bộ',
    'CANCELLED': 'Đã hủy',
  };

  for (final entry in states.entries) {
    testWidgets('shows ${entry.key} invoice state in Vietnamese', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceStateIndicator(
              status: entry.key,
              remainingAmount: 750000,
              refundedAmount: 250000,
              formatAmount: (amount) => '$amount đ',
            ),
          ),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
    });
  }
}
