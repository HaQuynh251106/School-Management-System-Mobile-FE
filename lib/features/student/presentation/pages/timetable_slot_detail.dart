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
    this.teacherName,
  });

  final String subject;
  final String period;
  final String time;
  final String room;
  final String dayLabel;
  final String? teacherName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chi tiết tiết học'),
      backgroundColor: AppColors.studentAccent,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.studentAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$dayLabel · $period · $time',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                room.trim().isEmpty ? 'Chưa có phòng học' : 'Phòng $room',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(title: 'Giáo viên phụ trách'),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person_outline_rounded),
            ),
            title: Text(
              teacherName == null || teacherName!.trim().isEmpty
                  ? 'Chưa có thông tin giáo viên'
                  : teacherName!,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nội dung bài học và học liệu sẽ hiển thị sau khi giáo viên cập nhật tiến độ thực dạy.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
