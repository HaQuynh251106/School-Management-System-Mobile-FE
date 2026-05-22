import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class TeacherClassSlotDetail extends StatelessWidget {
  const TeacherClassSlotDetail({
    super.key,
    required this.subject,
    required this.period,
    required this.className,
    required this.room,
    required this.time,
    required this.dayLabel,
  });

  final String subject;
  final String period;
  final String className;
  final String room;
  final String time;
  final String dayLabel;

  // Mock danh sách HS của lớp
  static const _students = [
    ('1', 'Phạm Hoài An', '23A1001'),
    ('2', 'Nguyễn Minh Châu', '23A1002'),
    ('3', 'Trần Thị Dung', '23A1003'),
    ('4', 'Lê Quang Huy', '23A1004'),
    ('5', 'Võ Thị Kim', '23A1005'),
    ('6', 'Đỗ Văn Long', '23A1006'),
    ('7', 'Hoàng Thị Mai', '23A1007'),
    ('8', 'Bùi Ngọc Nam', '23A1008'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lớp $className'),
        backgroundColor: AppColors.teacherAccent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.teacherAccent,
                  Color(0xFF7C3AED),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        className,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(period,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('$dayLabel • $time',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(room,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.fact_check_rounded,
                        label: 'Điểm danh',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mở tab Điểm danh từ menu dưới'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.grade_rounded,
                        label: 'Nhập điểm',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mở tab Điểm số từ menu dưới'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionHeader(title: 'Sĩ số: ${_students.length}'),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Xuất danh sách',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _students.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final (no, name, code) = _students[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        AppColors.teacherAccent.withOpacity(0.12),
                    child: Text(
                      no,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.teacherAccent),
                    ),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text('Mã HS: $code',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: AppColors.teacherAccent),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
