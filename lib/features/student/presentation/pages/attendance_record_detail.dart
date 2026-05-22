import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/section_header.dart';

class AttendanceRecordDetail extends StatelessWidget {
  const AttendanceRecordDetail({
    super.key,
    required this.subject,
    required this.date,
    required this.status,
    this.note,
  });

  final String subject;
  final String date;
  final String status;
  final String? note;

  String get _statusLabel {
    switch (status) {
      case 'PRESENT':
        return 'Có mặt';
      case 'ABSENT_EXCUSED':
        return 'Vắng có phép';
      case 'ABSENT_UNEXCUSED':
        return 'Vắng không phép';
      case 'LATE':
        return 'Muộn';
    }
    return status;
  }

  Color get _statusColor {
    switch (status) {
      case 'PRESENT':
        return AppColors.present;
      case 'ABSENT_EXCUSED':
        return AppColors.absentExcused;
      case 'ABSENT_UNEXCUSED':
        return AppColors.absentUnexcused;
      case 'LATE':
        return AppColors.late;
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết điểm danh'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _statusColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == 'PRESENT'
                        ? Icons.check_circle_rounded
                        : status == 'LATE'
                            ? Icons.access_time_filled_rounded
                            : Icons.cancel_rounded,
                    color: _statusColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusLabel,
                  style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Thông tin'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _InfoRow(icon: Icons.event_rounded, label: 'Ngày', value: date),
                const Divider(height: 0),
                _InfoRow(
                    icon: Icons.book_rounded, label: 'Môn học', value: subject),
                const Divider(height: 0),
                _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Tiết',
                    value: 'Tiết 2 • 07:50–08:35'),
                const Divider(height: 0),
                _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Giáo viên',
                    value: 'Trần Thị Bình'),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.flag_outlined,
                      color: AppColors.textSecondary, size: 20),
                  title: const Text('Trạng thái',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: AttendanceBadge(status),
                ),
              ],
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'Ghi chú từ giáo viên'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: AppColors.studentAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(note!,
                          style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (status == 'ABSENT_UNEXCUSED') ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Đã gửi yêu cầu PH cung cấp đơn xin phép cho GV.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.assignment_late_outlined),
              label: const Text('Yêu cầu PH gửi đơn xin phép'),
            ),
          ],
        ],
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
