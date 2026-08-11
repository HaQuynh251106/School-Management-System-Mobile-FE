import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class InvoiceStateIndicator extends StatelessWidget {
  const InvoiceStateIndicator({
    super.key,
    required this.status,
    required this.remainingAmount,
    required this.refundedAmount,
    required this.formatAmount,
  });

  final String status;
  final int remainingAmount;
  final int refundedAmount;
  final String Function(int amount) formatAmount;

  @override
  Widget build(BuildContext context) {
    final state =
        _invoiceState(status, remainingAmount, refundedAmount, formatAmount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: state.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(state.icon, color: state.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.label,
                  style: TextStyle(
                    color: state.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(state.description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

({String label, String description, IconData icon, Color color}) _invoiceState(
  String status,
  int remaining,
  int refunded,
  String Function(int amount) money,
) =>
    switch (status) {
      'UNPAID' => (
          label: 'Chờ thanh toán',
          description: 'Còn phải trả ${money(remaining)}.',
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
        ),
      'OVERDUE' => (
          label: 'Đã quá hạn',
          description:
              'Còn phải trả ${money(remaining)}. Hóa đơn vẫn có thể thanh toán.',
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        ),
      'PARTIAL' => (
          label: 'Đã thanh toán một phần',
          description: 'Còn phải trả ${money(remaining)} để hoàn tất hóa đơn.',
          icon: Icons.timelapse_rounded,
          color: AppColors.warning,
        ),
      'PAID' => (
          label: 'Đã thanh toán đủ',
          description: 'Hóa đơn đã hoàn tất và không còn công nợ.',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
      'PARTIALLY_REFUNDED' => (
          label: 'Đã hoàn một phần',
          description:
              'Đã hoàn ${money(refunded)}. Phần còn lại có thể tiếp tục được hoàn.',
          icon: Icons.undo_rounded,
          color: AppColors.warning,
        ),
      'REFUNDED' => (
          label: 'Đã hoàn toàn bộ',
          description: 'Toàn bộ số tiền đã thu đã được hoàn lại.',
          icon: Icons.assignment_return_rounded,
          color: AppColors.textSecondary,
        ),
      'CANCELLED' => (
          label: 'Đã hủy',
          description: 'Hóa đơn đã đóng và không thể thanh toán.',
          icon: Icons.cancel_outlined,
          color: AppColors.textSecondary,
        ),
      _ => (
          label: 'Chưa xác định',
          description: 'Ứng dụng chưa nhận diện được trạng thái $status.',
          icon: Icons.help_outline_rounded,
          color: AppColors.textSecondary,
        ),
    };
