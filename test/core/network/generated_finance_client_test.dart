import 'package:flutter_test/flutter_test.dart';
import 'package:sse_finance_api/sse_finance_api.dart';

void main() {
  test('generated PayRequest serializes the VIETQR enum from the contract', () {
    final request = PayRequest(invoiceId: 'invoice-1');

    expect(request.toJson(), {'invoiceId': 'invoice-1', 'method': 'VIETQR'});
    expect(
      PayRequest.fromJson(request.toJson()).method,
      PayRequestMethodEnum.VIETQR,
    );
  });

  test('generated VietQR result preserves bank account fields', () {
    final result = VietQrPaymentResult.fromJson({
      'payment': {
        'id': 'payment-1',
        'invoiceId': 'invoice-1',
        'method': 'VIETQR',
        'amount': 100000,
        'status': 'PENDING',
        'txnRef': 'TXN-1',
        'createdAt': '2026-08-12T00:00:00Z',
      },
      'invoice': {
        'id': 'invoice-1',
        'code': 'INV-1',
        'studentId': 'student-1',
        'totalAmount': 100000,
        'paidAmount': 0,
        'refundedAmount': 0,
        'status': 'UNPAID',
        'version': 0,
      },
      'gateway': 'VIETQR',
      'gatewayStatus': 'PENDING',
      'qrImageUrl': 'https://example.test/qr.png',
      'bankId': 'TCB',
      'accountNo': '123456789',
      'accountName': 'SSE SCHOOL',
      'transferContent': 'INV-1',
    });

    expect(result.bankId, 'TCB');
    expect(result.accountNo, '123456789');
    expect(result.accountName, 'SSE SCHOOL');
  });
}
