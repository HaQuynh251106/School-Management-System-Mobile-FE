import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/section_header.dart';

class TeacherAttendanceSessionDetail extends StatefulWidget {
  const TeacherAttendanceSessionDetail({
    super.key,
    required this.slotId,
    required this.classId,
    required this.className,
    required this.subject,
    required this.date,
    required this.periodNo,
  });

  final String slotId;
  final String classId;
  final String className;
  final String subject;
  final DateTime date;
  final int periodNo;

  @override
  State<TeacherAttendanceSessionDetail> createState() =>
      _TeacherAttendanceSessionDetailState();
}

class _TeacherAttendanceSessionDetailState
    extends State<TeacherAttendanceSessionDetail> {
  late Future<_SessionDetailData> _future = _load();

  Future<_SessionDetailData> _load() async {
    final api = sl<ApiService>();
    final date = DateFormat('yyyy-MM-dd').format(widget.date);
    final results = await Future.wait<dynamic>([
      api.classStudents(widget.classId),
      api.attendance(slotId: widget.slotId, date: date),
      api.attendanceSessionStatus(slotId: widget.slotId, date: widget.date),
    ]);
    final students = (results[0] as List).cast<Map<String, dynamic>>();
    final records = (results[1] as List).cast<Map<String, dynamic>>();
    final recordsByStudent = {
      for (final record in records) record['studentId'].toString(): record,
    };
    return _SessionDetailData(
      rows: students
          .map(
            (student) => _AttendanceDetailRow(
              name: student['fullName']?.toString() ?? '',
              status:
                  recordsByStudent[student['id'].toString()]?['status']
                      ?.toString() ??
                  'PRESENT',
              note: recordsByStudent[student['id'].toString()]?['note']
                  ?.toString(),
              hasRecord: recordsByStudent.containsKey(student['id'].toString()),
            ),
          )
          .toList(),
      sessionStatus: (results[2] as Map).cast<String, dynamic>(),
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết điểm danh'),
        backgroundColor: AppColors.teacherAccent,
      ),
      body: FutureBuilder<_SessionDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    apiErrorMessage(
                      snapshot.error,
                      fallback: 'Không thể tải chi tiết điểm danh.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data!;
          final sessionState = data.sessionStatus['state']?.toString() ?? '';
          final completed =
              sessionState == 'COMPLETED' || sessionState == 'COMPLETED_LATE';
          final recorded = data.rows.where((row) => row.hasRecord).toList();
          final present = recorded
              .where((row) => row.status == 'PRESENT')
              .length;
          final excused = recorded
              .where((row) => row.status == 'ABSENT_EXCUSED')
              .length;
          final unexcused = recorded
              .where((row) => row.status == 'ABSENT_UNEXCUSED')
              .length;
          final late = recorded.where((row) => row.status == 'LATE').length;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.teacherAccent.withValues(alpha: 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.className} — ${widget.subject}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(widget.date)} · Tiết ${widget.periodNo}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          completed
                              ? Icons.verified_outlined
                              : Icons.warning_amber_rounded,
                          size: 14,
                          color: completed
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.sessionStatus['message']?.toString() ?? 'Đã lưu',
                          style: TextStyle(
                            fontSize: 11,
                            color: completed
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            value: present,
                            label: 'Có mặt',
                            color: AppColors.present,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatBox(
                            value: excused,
                            label: 'Vắng phép',
                            color: AppColors.absentExcused,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatBox(
                            value: unexcused,
                            label: 'Vắng KP',
                            color: AppColors.absentUnexcused,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatBox(
                            value: late,
                            label: 'Muộn',
                            color: AppColors.late,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [SectionHeader(title: 'Danh sách học sinh')],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, index) {
                    final row = data.rows[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.teacherAccent.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.teacherAccent,
                          ),
                        ),
                      ),
                      title: Text(
                        row.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: row.note?.isNotEmpty == true
                          ? Text(
                              row.note!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : null,
                      trailing: row.hasRecord
                          ? AttendanceBadge(row.status)
                          : const Text(
                              'Chưa ghi nhận',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessionDetailData {
  const _SessionDetailData({required this.rows, required this.sessionStatus});

  final List<_AttendanceDetailRow> rows;
  final Map<String, dynamic> sessionStatus;
}

class _AttendanceDetailRow {
  const _AttendanceDetailRow({
    required this.name,
    required this.status,
    required this.note,
    required this.hasRecord,
  });

  final String name;
  final String status;
  final String? note;
  final bool hasRecord;
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
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
