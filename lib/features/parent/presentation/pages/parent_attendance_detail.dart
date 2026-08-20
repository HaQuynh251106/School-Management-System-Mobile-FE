import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/section_header.dart';

class ParentAttendanceDetail extends StatelessWidget {
  const ParentAttendanceDetail({
    super.key,
    required this.childName,
    required this.subject,
    required this.date,
    required this.status,
    this.note,
    this.periodNo,
  });

  final String childName;
  final String subject;
  final String date;
  final String status;
  final String? note;
  final int? periodNo;

  String get _statusLabel => switch (status) {
    'PRESENT' => 'Có mặt',
    'ABSENT_EXCUSED' => 'Vắng có phép',
    'ABSENT_UNEXCUSED' => 'Vắng không phép',
    'LATE' => 'Muộn',
    _ => status,
  };

  Color _statusColor(BuildContext context) => switch (status) {
    'PRESENT' => AppColors.present,
    'ABSENT_EXCUSED' => AppColors.absentExcused,
    'ABSENT_UNEXCUSED' => AppColors.absentUnexcused,
    'LATE' => AppColors.late,
    _ => Theme.of(context).colorScheme.onSurfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết điểm danh'),
        backgroundColor: AppColors.parentAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _statusColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _statusColor(context).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == 'PRESENT'
                        ? Icons.check_circle_rounded
                        : status == 'LATE'
                        ? Icons.access_time_filled_rounded
                        : Icons.cancel_rounded,
                    color: _statusColor(context),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  childName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Thông tin tiết học'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _InfoRow(icon: Icons.event_rounded, label: 'Ngày', value: date),
                const Divider(height: 0),
                _InfoRow(
                  icon: Icons.book_rounded,
                  label: 'Môn học',
                  value: subject,
                ),
                const Divider(height: 0),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Tiết',
                  value: periodNo == null ? '—' : 'Tiết $periodNo',
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  title: Text(
                    'Trạng thái',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
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
                    const Icon(
                      Icons.format_quote_rounded,
                      color: AppColors.parentAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        note!,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
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
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
