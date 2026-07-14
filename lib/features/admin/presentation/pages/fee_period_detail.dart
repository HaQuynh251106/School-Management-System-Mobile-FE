import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class AdminFeePeriodDetail extends StatelessWidget {
  const AdminFeePeriodDetail({
    super.key,
    required this.code,
    required this.title,
    required this.status,
  });

  final String code;
  final String title;
  final String status;

  String _formatVnd(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  @override
  Widget build(BuildContext context) {
    const totalIssued = 1248;
    const totalPaid = 982;
    const totalAmount = 5616000000;
    const paidAmount = 4419000000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đợt thu'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
              icon: const Icon(Icons.file_download_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.adminAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.adminAccent.withValues(alpha: 0.3)),
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
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Text(code,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Phát hành: 01/02/2026 — Hạn: 15/06/2026',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Tổng quan công nợ'),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: _StatBox(
                  label: 'Đã thu',
                  value: '$totalPaid/$totalIssued HS',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  label: 'Tỉ lệ',
                  value:
                      '${(totalPaid * 100 / totalIssued).toStringAsFixed(0)}%',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng tiền đã phát hành',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(_formatVnd(totalAmount),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.adminAccent)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: paidAmount / totalAmount,
                      color: AppColors.success,
                      backgroundColor: AppColors.divider,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đã thu',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          Text(_formatVnd(paidAmount),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Còn lại',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          Text(_formatVnd(totalAmount - paidAmount),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Định mức theo khối'),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                _FeeRow(
                    name: 'Học phí', grades: 'K10/K11/K12', amount: 3500000),
                Divider(height: 0),
                _FeeRow(name: 'Tiền ăn trưa', grades: 'Tất cả', amount: 800000),
                Divider(height: 0),
                _FeeRow(name: 'Bảo hiểm', grades: 'Tất cả', amount: 200000),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Top 5 HS nợ học phí'),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                _DebtorRow(name: 'Nguyễn Văn Hùng', cls: '10A2', days: 12),
                Divider(height: 0),
                _DebtorRow(name: 'Trần Thị Lan', cls: '11B1', days: 8),
                Divider(height: 0),
                _DebtorRow(name: 'Phạm Quốc Khánh', cls: '10A3', days: 5),
                Divider(height: 0),
                _DebtorRow(name: 'Đỗ Văn Tài', cls: '12A1', days: 3),
                Divider(height: 0),
                _DebtorRow(name: 'Lê Hoài Vy', cls: '11B2', days: 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Nhắc nợ'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.adminAccent,
                  ),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Đóng đợt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.name,
    required this.grades,
    required this.amount,
  });
  final String name;
  final String grades;
  final int amount;

  String _formatVnd(int a) {
    final s = a.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_outlined, color: AppColors.adminAccent),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(grades,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: Text(_formatVnd(amount),
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.adminAccent)),
    );
  }
}

class _DebtorRow extends StatelessWidget {
  const _DebtorRow({
    required this.name,
    required this.cls,
    required this.days,
  });
  final String name;
  final String cls;
  final int days;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.error.withValues(alpha: 0.12),
        child: const Icon(Icons.priority_high_rounded,
            color: AppColors.error, size: 16),
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text('Lớp $cls',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('Trễ $days ngày',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.error)),
      ),
    );
  }
}
