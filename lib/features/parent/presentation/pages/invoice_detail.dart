import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class InvoiceLineItem {
  const InvoiceLineItem(this.name, this.amount);
  final String name;
  final int amount;
}

class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({
    super.key,
    required this.invoiceCode,
    required this.childName,
    required this.semester,
    required this.dueDate,
    required this.items,
    required this.status,
    this.paidAt,
  });

  final String invoiceCode;
  final String childName;
  final String semester;
  final String dueDate;
  final List<InvoiceLineItem> items;
  final String status; // PENDING, PAID, OVERDUE
  final String? paidAt;

  int get _total => items.fold(0, (s, i) => s + i.amount);

  String _formatVnd(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  Color get _statusColor => switch (status) {
        'PAID' => AppColors.success,
        'OVERDUE' => AppColors.error,
        _ => AppColors.warning,
      };

  String get _statusLabel => switch (status) {
        'PAID' => 'Đã thanh toán',
        'OVERDUE' => 'Quá hạn',
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
                const SizedBox(height: 16),
                const SectionHeader(title: 'Các khoản'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ...items.map((it) => ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.parentAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_outlined,
                                  size: 18, color: AppColors.parentAccent),
                            ),
                            title: Text(it.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                            trailing: Text(_formatVnd(it.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          )),
                      const Divider(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Text('Tổng cộng',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            Text(
                              _formatVnd(_total),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: AppColors.parentAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == 'PAID' && paidAt != null) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Thông tin thanh toán'),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _InfoRow(
                            icon: Icons.event_available_rounded,
                            label: 'Ngày thanh toán',
                            value: paidAt!),
                        const Divider(height: 0),
                        const _InfoRow(
                            icon: Icons.payment_rounded,
                            label: 'Phương thức',
                            value: 'VNPAY'),
                        const Divider(height: 0),
                        const _InfoRow(
                            icon: Icons.tag_rounded,
                            label: 'Mã giao dịch',
                            value: 'VN20250215143025'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status != 'PAID')
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                      top: BorderSide(color: AppColors.divider, width: 0.5)),
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
                    label: Text('Thanh toán ${_formatVnd(_total)}'),
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
        color: _statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text('Mã: $invoiceCode',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(semester,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Học sinh: $childName',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.event_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                status == 'PAID'
                    ? 'Đã thanh toán ngày $paidAt'
                    : 'Hạn thanh toán: $dueDate',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
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
            const Text('Chọn phương thức',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _PaymentMethodTile(
              icon: Icons.account_balance_rounded,
              name: 'VNPAY',
              subtitle: 'ATM nội địa, Visa/Master, QR Pay',
              color: const Color(0xFF005BAA),
              onTap: () => _processPayment(context, 'VNPAY'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Icons.qr_code_rounded,
              name: 'Ví MoMo',
              subtitle: 'Quét QR hoặc đăng nhập ứng dụng',
              color: const Color(0xFFA50064),
              onTap: () => _processPayment(context, 'MoMo'),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, String provider) {
    Navigator.pop(context); // close sheet
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // close loader
      Navigator.pop(context); // back to list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thanh toán $provider thành công!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
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
      title: Text(label,
          style:
              const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
