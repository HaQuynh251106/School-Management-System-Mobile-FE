import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class TeacherClassSlotDetail extends StatefulWidget {
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
  // Lưu ý: từ TKB live, `className` mang giá trị classId của tiết học,
  // dùng để gọi /classes/{id}/students.
  final String className;
  final String room;
  final String time;
  final String dayLabel;

  @override
  State<TeacherClassSlotDetail> createState() => _TeacherClassSlotDetailState();
}

class _TeacherClassSlotDetailState extends State<TeacherClassSlotDetail> {
  late final Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().classStudents(widget.className);

  String get subject => widget.subject;
  String get period => widget.period;
  String get className => widget.className;
  String get room => widget.room;
  String get time => widget.time;
  String get dayLabel => widget.dayLabel;

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
                        color: Colors.white.withValues(alpha: 0.2),
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
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                      child: Text('Không thể tải danh sách học sinh.',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)));
                }
                final students = snap.data ?? [];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionHeader(title: 'Sĩ số: ${students.length}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: students.isEmpty
                          ? Center(
                              child: Text('Lớp chưa có học sinh',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)))
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: students.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 0),
                              itemBuilder: (_, i) {
                                final s = students[i];
                                final name = (s['fullName'] ?? '').toString();
                                final code =
                                    (s['studentCode'] ?? '').toString();
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.teacherAccent
                                        .withValues(alpha: 0.12),
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
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                  subtitle: Text('Mã HS: $code',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
