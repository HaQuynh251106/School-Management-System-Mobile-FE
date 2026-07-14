import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/section_header.dart';

class TeacherAttendanceSessionDetail extends StatelessWidget {
  const TeacherAttendanceSessionDetail({
    super.key,
    required this.className,
    required this.subject,
    required this.date,
    required this.period,
  });

  final String className;
  final String subject;
  final String date;
  final String period;

  static const _records = [
    ('Phạm Hoài An', 'PRESENT', null),
    ('Nguyễn Minh Châu', 'PRESENT', null),
    ('Trần Thị Dung', 'ABSENT_EXCUSED', 'Đơn xin nghỉ ốm'),
    ('Lê Quang Huy', 'LATE', 'Muộn 10 phút'),
    ('Võ Thị Kim', 'PRESENT', null),
    ('Đỗ Văn Long', 'ABSENT_UNEXCUSED', null),
    ('Hoàng Thị Mai', 'PRESENT', null),
    ('Bùi Ngọc Nam', 'PRESENT', null),
  ];

  @override
  Widget build(BuildContext context) {
    final present = _records.where((r) => r.$2 == 'PRESENT').length;
    final excused = _records.where((r) => r.$2 == 'ABSENT_EXCUSED').length;
    final unexcused = _records.where((r) => r.$2 == 'ABSENT_UNEXCUSED').length;
    final late = _records.where((r) => r.$2 == 'LATE').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết điểm danh'),
        backgroundColor: AppColors.teacherAccent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.teacherAccent.withValues(alpha: 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$className — $subject',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('$date • $period',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    const Icon(Icons.verified_outlined,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    const Text('Đã chốt',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            value: present,
                            label: 'Có mặt',
                            color: AppColors.present)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            value: excused,
                            label: 'Vắng phép',
                            color: AppColors.absentExcused)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            value: unexcused,
                            label: 'Vắng KP',
                            color: AppColors.absentUnexcused)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            value: late, label: 'Muộn', color: AppColors.late)),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                SectionHeader(title: 'Danh sách học sinh'),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final (name, status, note) = _records[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        AppColors.teacherAccent.withValues(alpha: 0.12),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.teacherAccent),
                    ),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: note != null
                      ? Text(note,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic))
                      : null,
                  trailing: AttendanceBadge(status),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
