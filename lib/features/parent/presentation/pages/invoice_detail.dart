import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/invoice_state_indicator.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/utils/vi_date_format.dart';

class InvoiceLineItem {
  const InvoiceLineItem(this.name, this.amount);
  final String name;
  final int amount;
}

class InvoiceRefundItem {
  const InvoiceRefundItem(this.amount, this.reason, this.createdAt);
  final int amount;
  final String reason;
  final String createdAt;
}

class InvoicePaymentItem {
  const InvoicePaymentItem({
    required this.amount,
    required this.method,
    required this.paidAt,
    required this.receiptCode,
    this.payerName,
    this.note,
  });

  final int amount;
  final String method;
  final String paidAt;
  final String receiptCode;
  final String? payerName;
  final String? note;
}

class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({
    super.key,
    required this.invoiceCode,
    this.invoiceId,
    required this.childName,
    required this.semester,
    required this.dueDate,
    required this.items,
    required this.status,
    this.paidAmount = 0,
    this.refundedAmount = 0,
    this.refunds = const [],
    this.payments = const [],
    this.paidAt,
    this.paidMethod,
    this.transactionRef,
  });

  final String invoiceCode;
  final String? invoiceId;
  final String childName;
  final String semester;
  final String dueDate;
  final List<InvoiceLineItem> items;
  final String status;
  final int paidAmount;
  final int refundedAmount;
  final List<InvoiceRefundItem> refunds;
  final List<InvoicePaymentItem> payments;
  final String? paidAt;
  final String? paidMethod;
  final String? transactionRef;

  int get _total => items.fold(0, (s, i) => s + i.amount);
  int get _remaining {
    final value = _total - paidAmount;
    return value < 0 ? 0 : value;
  }

  bool get _canPay =>
      const {'UNPAID', 'PARTIAL', 'OVERDUE'}.contains(status) && _remaining > 0;

  String _formatVnd(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  String _formatTime(String value) => formatViDateTime(value);

  String _paymentMethodLabel(String? method) => switch (method) {
    'CASH' => 'Tiền mặt',
    'VNPAY' => 'VNPAY',
    'MOMO' => 'MoMo',
    'MB_BANK_TRANSFER' => 'Chuyển khoản ngân hàng',
    _ => 'Thanh toán điện tử',
  };

  Color get _statusColor => switch (status) {
    'PAID' => AppColors.success,
    'OVERDUE' => AppColors.error,
    'PARTIAL' || 'PARTIALLY_REFUNDED' => AppColors.warning,
    'REFUNDED' || 'CANCELLED' => AppColors.textSecondary,
    _ => AppColors.warning,
  };

  String get _statusLabel => switch (status) {
    'PAID' => 'Đã thanh toán',
    'OVERDUE' => 'Quá hạn',
    'PARTIAL' => 'Đã thanh toán một phần',
    'PARTIALLY_REFUNDED' => 'Đã hoàn một phần',
    'REFUNDED' => 'Đã hoàn toàn bộ',
    'CANCELLED' => 'Đã hủy',
    'UNPAID' => 'Chưa thanh toán',
    _ => 'Chưa thanh toán',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hóa đơn'),
        backgroundColor: AppColors.parentAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                InvoiceStateIndicator(
                  status: status,
                  remainingAmount: _remaining,
                  refundedAmount: refundedAmount,
                  formatAmount: _formatVnd,
                ),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Các khoản'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ...items.map(
                        (it) => ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.parentAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_outlined,
                              size: 18,
                              color: AppColors.parentAccent,
                            ),
                          ),
                          title: Text(
                            it.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            _formatVnd(it.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Tổng cộng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatVnd(_total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppColors.parentAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Đã thanh toán',
                        value: _formatVnd(paidAmount),
                      ),
                      const Divider(height: 0),
                      _InfoRow(
                        icon: Icons.undo_rounded,
                        label: 'Đã hoàn',
                        value: _formatVnd(refundedAmount),
                      ),
                      const Divider(height: 0),
                      _InfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Còn phải trả',
                        value: _formatVnd(_remaining),
                      ),
                    ],
                  ),
                ),
                if (status == 'CANCELLED') ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hóa đơn đã hủy nên không thể tạo mã thanh toán.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (payments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Lịch sử thanh toán'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: payments
                          .map(
                            (payment) => ListTile(
                              leading: Icon(
                                payment.method == 'CASH'
                                    ? Icons.payments_rounded
                                    : Icons.qr_code_2_rounded,
                              ),
                              title: Text(_formatVnd(payment.amount)),
                              subtitle: Text(
                                [
                                  payment.method == 'CASH'
                                      ? 'Tiền mặt'
                                      : _paymentMethodLabel(payment.method),
                                  _formatTime(payment.paidAt),
                                  if (payment.payerName?.isNotEmpty == true)
                                    'Người nộp: ${payment.payerName}',
                                  if (payment.note?.isNotEmpty == true)
                                    payment.note!,
                                ].join(' • '),
                              ),
                              trailing: Text(
                                payment.receiptCode.isEmpty
                                    ? 'Đã xác nhận'
                                    : payment.receiptCode,
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ] else if (paidAmount > 0 && paidAt != null) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Thông tin thanh toán'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.event_available_rounded,
                          label: 'Ngày thanh toán',
                          value: _formatTime(paidAt!),
                        ),
                        const Divider(height: 0),
                        _InfoRow(
                          icon: Icons.payment_rounded,
                          label: 'Phương thức',
                          value: _paymentMethodLabel(paidMethod),
                        ),
                        const Divider(height: 0),
                        _InfoRow(
                          icon: Icons.tag_rounded,
                          label: 'Mã giao dịch',
                          value: transactionRef ?? 'Đã xác nhận',
                        ),
                      ],
                    ),
                  ),
                ],
                if (refunds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Lịch sử hoàn tiền'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: refunds
                          .map(
                            (refund) => ListTile(
                              leading: const Icon(Icons.undo_rounded),
                              title: Text(_formatVnd(refund.amount)),
                              subtitle: Text(refund.reason),
                              trailing: Text(
                                _formatTime(refund.createdAt),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_canPay)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showPaymentSheet(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.parentAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.payment_rounded),
                    label: Text('Thanh toán ${_formatVnd(_remaining)}'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Mã: $invoiceCode',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            semester,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Học sinh: $childName',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.event_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                const {
                      'PAID',
                      'PARTIALLY_REFUNDED',
                      'REFUNDED',
                    }.contains(status)
                    ? 'Đã thanh toán ngày ${formatViDate(paidAt)}'
                    : 'Hạn thanh toán: '
                          '${formatViDate(dueDate, fallback: 'Chưa đặt')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn phương thức',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _PaymentMethodTile(
              icon: Icons.qr_code_rounded,
              name: 'Chuyển khoản ngân hàng',
              subtitle:
                  'Quét mã bằng ứng dụng ngân hàng và chờ nhà trường đối soát',
              color: AppColors.accountantAccent,
              onTap: () => _processPayment(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    Navigator.pop(context); // close sheet
    if (invoiceId == null || invoiceId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn này chưa được đồng bộ mã thanh toán.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final result = await sl<ApiService>().pay(
        invoiceId!,
        method: 'MB_BANK_TRANSFER',
      );
      if (!context.mounted) return;
      Navigator.pop(context); // close loader
      final payment = result['payment'] is Map
          ? (result['payment'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final paymentId = (payment['id'] ?? result['paymentId'] ?? '').toString();
      final bankTransfer = result['bankTransfer'] is Map
          ? (result['bankTransfer'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.qr_code_2_rounded),
              SizedBox(width: 8),
              Text('Thông tin chuyển khoản'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((bankTransfer['qrImageUrl'] ?? '').toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      (bankTransfer['qrImageUrl']).toString(),
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 12),
                _QrLine(
                  'Ngân hàng',
                  (bankTransfer['bankName'] ?? bankTransfer['bankId'] ?? '')
                      .toString(),
                ),
                _QrLine(
                  'Số tài khoản',
                  (bankTransfer['accountNumber'] ?? '').toString(),
                ),
                _QrLine(
                  'Chủ tài khoản',
                  (bankTransfer['accountName'] ?? '').toString(),
                ),
                _QrLine(
                  'Nội dung',
                  (bankTransfer['transferContent'] ?? '').toString(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hóa đơn chỉ được ghi nhận đã thanh toán sau khi Admin nhà trường xác nhận tiền về.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Để sau'),
            ),
            FilledButton.icon(
              onPressed: paymentId.isEmpty
                  ? null
                  : () async {
                      try {
                        final picked = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: const ['jpg', 'jpeg', 'png'],
                          withData: true,
                        );
                        final file = picked?.files.singleOrNull;
                        if (file == null) return;
                        if (file.bytes == null || file.size <= 0) {
                          throw StateError(
                            'Không đọc được ảnh biên lai đã chọn',
                          );
                        }
                        if (file.size > 5 * 1024 * 1024) {
                          throw StateError(
                            'Ảnh biên lai không được vượt quá 5MB',
                          );
                        }
                        await sl<ApiService>().submitPaymentProof(
                          paymentId: paymentId,
                          bytes: file.bytes!,
                          fileName: file.name,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã gửi biên lai, vui lòng chờ nhà trường đối chiếu.',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              apiErrorMessage(
                                error,
                                fallback:
                                    'Không thể gửi xác nhận chuyển khoản. Vui lòng thử lại.',
                              ),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Gửi ảnh biên lai'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback:
                  'Không thể tạo giao dịch chuyển khoản. Vui lòng thử lại.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _QrLine extends StatelessWidget {
  const _QrLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String name;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
