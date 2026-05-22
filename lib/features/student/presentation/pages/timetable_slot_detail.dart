import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class StudentTimetableSlotDetail extends StatelessWidget {
  const StudentTimetableSlotDetail({
    super.key,
    required this.subject,
    required this.period,
    required this.time,
    required this.room,
    required this.dayLabel,
  });

  final String subject;
  final String period;
  final String time;
  final String room;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tiết học'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.studentAccent,
                  AppColors.studentAccent.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('$dayLabel • $period • $time',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(room,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Giáo viên'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.studentAccent.withOpacity(0.15),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.studentAccent),
              ),
              title: const Text('Trần Thị Bình',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Giáo viên bộ môn • binh.tt@sse.edu.vn'),
              trailing: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.studentAccent, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Nội dung bài học'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LessonRow(
                    icon: Icons.menu_book_rounded,
                    label: 'Chương',
                    value: 'Chương 3 — Hàm số bậc hai',
                  ),
                  _LessonRow(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Bài',
                    value: 'Bài 6 — Đồ thị parabol',
                  ),
                  _LessonRow(
                    icon: Icons.notes_rounded,
                    label: 'Ghi chú GV',
                    value: 'Mang theo máy tính cầm tay. Ôn lại đỉnh parabol.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Học liệu'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                _AttachmentTile(
                  icon: Icons.picture_as_pdf_rounded,
                  name: 'Slide_HamSoBacHai.pdf',
                  size: '1.2 MB',
                ),
                Divider(height: 0),
                _AttachmentTile(
                  icon: Icons.description_rounded,
                  name: 'BaiTap_Tuan10.docx',
                  size: '320 KB',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã ghi nhớ vào lịch học của bạn'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.alarm_add_rounded),
            label: const Text('Thêm vào nhắc nhở'),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.studentAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.icon,
    required this.name,
    required this.size,
  });

  final IconData icon;
  final String name;
  final String size;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.studentAccent),
      title:
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(size,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.download_rounded, size: 20),
      onTap: () {},
    );
  }
}
