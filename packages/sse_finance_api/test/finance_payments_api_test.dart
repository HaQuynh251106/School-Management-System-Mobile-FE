import 'package:test/test.dart';
import 'package:sse_finance_api/sse_finance_api.dart';


/// tests for FinancePaymentsApi
void main() {
  final instance = SseFinanceApi().getFinancePaymentsApi();

  group(FinancePaymentsApi, () {
    // Reconcile a VietQR transfer and issue a receipt
    //
    //Future<VietQrCallbackResult> confirmVietQrPayment(String paymentId, { VietQrConfirmationRequest vietQrConfirmationRequest }) async
    test('test confirmVietQrPayment', () async {
      // TODO
    });

    // Create or reuse a pending VietQR transaction
    //
    //Future<VietQrPaymentResult> createVietQrPayment(PayRequest payRequest) async
    test('test createVietQrPayment', () async {
      // TODO
    });

    // Get an invoice with items, payments and refunds
    //
    //Future<InvoiceDetail> getInvoiceDetail(String invoiceId) async
    test('test getInvoiceDetail', () async {
      // TODO
    });

    // List payments of one invoice
    //
    //Future<List<Payment>> listInvoicePayments(String invoiceId) async
    test('test listInvoicePayments', () async {
      // TODO
    });

    // List invoices visible to the current role
    //
    //Future<List<Invoice>> listInvoices({ String studentId, String parentId, InvoiceStatus status, String periodId, String q, String classId, String gradeLevel }) async
    test('test listInvoices', () async {
      // TODO
    });

    // List VietQR transfers awaiting reconciliation
    //
    //Future<List<VietQrPaymentResult>> listPendingVietQrPayments() async
    test('test listPendingVietQrPayments', () async {
      // TODO
    });

    // Mark that the payer has submitted a VietQR transfer
    //
    //Future<VietQrCallbackResult> markVietQrSubmitted(String paymentId) async
    test('test markVietQrSubmitted', () async {
      // TODO
    });

    // Record a cash payment and issue a receipt
    //
    //Future<PaymentMutationResult> recordCashPayment(CashPaymentRequest cashPaymentRequest) async
    test('test recordCashPayment', () async {
      // TODO
    });

    // Refund part or all of a paid invoice
    //
    //Future<RefundMutationResult> refundInvoice(String invoiceId, RefundInvoiceRequest refundInvoiceRequest) async
    test('test refundInvoice', () async {
      // TODO
    });

    // Reject an invalid pending VietQR transfer
    //
    //Future<VietQrCallbackResult> rejectVietQrPayment(String paymentId) async
    test('test rejectVietQrPayment', () async {
      // TODO
    });

  });
}
