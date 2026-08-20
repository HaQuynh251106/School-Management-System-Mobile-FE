import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class AdminClassDetail extends StatelessWidget {
  const AdminClassDetail({
    super.key,
    required this.classId,
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });

  final String classId;
  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  Widget build(BuildContext context) {
    final normalizedName = className.trim();
    final title = normalizedName.toLowerCase().startsWith('lớp ')
        ? normalizedName
        : 'Lớp $normalizedName';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.adminAccent,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Học sinh'),
              Tab(text: 'TKB'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(
              classId: classId,
              className: className,
              gradeName: gradeName,
              homeroom: homeroom,
              studentCount: studentCount,
            ),
            _StudentsTab(classId: classId),
            _TimetableSummaryTab(classId: classId),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatefulWidget {
  const _InfoTab({
    required this.classId,
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });

  final String classId;
  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  late Future<ClassOverviewMetrics> _future = _load();

  Future<ClassOverviewMetrics> _load() async {
    final api = sl<ApiService>();
    final results = await Future.wait<dynamic>([
      api.grades(classId: widget.classId),
      api.attendance(classId: widget.classId),
      api.teachingAssignments(classId: widget.classId),
    ]);
    return ClassOverviewMetrics.fromRaw(
      grades: (results[0] as List).cast<Map<String, dynamic>>(),
      attendance: (results[1] as List).cast<Map<String, dynamic>>(),
      assignments: (results[2] as List).cast<Map<String, dynamic>>(),
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ClassHeader(
          className: widget.className,
          gradeName: widget.gradeName,
          homeroom: widget.homeroom,
          studentCount: widget.studentCount,
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Thống kê'),
        const SizedBox(height: 10),
        FutureBuilder<ClassOverviewMetrics>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: OutlinedButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tải lại dữ liệu lớp'),
                ),
              );
            }

            final data = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'TB lớp',
                        value: data.averageScoreLabel,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Tỉ lệ CC',
                        value: data.attendanceRateLabel,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Vắng KP',
                        value: '${data.unexcusedCount}',
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Giáo viên bộ môn'),
                const SizedBox(height: 8),
                if (data.assignments.isEmpty)
                  const Text(
                    'Chưa có phân công giảng dạy',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < data.assignments.length; i++) ...[
                          if (i > 0) const Divider(height: 0),
                          _AssignmentTile(assignment: data.assignments[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });

  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminAccent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              className,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gradeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GVCN: ${homeroom.isEmpty ? 'Chưa phân công' : homeroom}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  'Sĩ số: $studentCount HS',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.assignment});

  final Map<String, dynamic> assignment;

  @override
  Widget build(BuildContext context) {
    final scheduled = (assignment['scheduledPeriods'] as num?)?.toInt() ?? 0;
    final weekly = (assignment['weeklyPeriods'] as num?)?.toInt() ?? 0;
    return ListTile(
      leading: const Icon(
        Icons.school_outlined,
        color: AppColors.teacherAccent,
      ),
      title: Text(assignment['subjectName']?.toString() ?? ''),
      subtitle: Text(
        assignment['teacherName']?.toString() ?? 'Chưa có giáo viên',
      ),
      trailing: Text(
        '$scheduled/$weekly tiết',
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({required this.classId});

  final String classId;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  late final Future<List<Map<String, dynamic>>> _future = sl<ApiService>()
      .classStudents(widget.classId);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.surface,
          child: TextField(
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Tìm học sinh...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Không thể tải danh sách học sinh',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              final all = snapshot.data ?? [];
              final students = _query.isEmpty
                  ? all
                  : all.where((student) {
                      final name = (student['fullName'] ?? '')
                          .toString()
                          .toLowerCase();
                      final code = (student['studentCode'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(_query) || code.contains(_query);
                    }).toList();
              if (students.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có học sinh',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.studentAccent.withValues(
                        alpha: 0.14,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.studentAccent,
                            ),
                      ),
                    ),
                    title: Text(
                      (student['fullName'] ?? '').toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      (student['studentCode'] ?? '').toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimetableSummaryTab extends StatelessWidget {
  const _TimetableSummaryTab({required this.classId});

  final String classId;

  static const _days = [
    ('MON', 'Thứ 2'),
    ('TUE', 'Thứ 3'),
    ('WED', 'Thứ 4'),
    ('THU', 'Thứ 5'),
    ('FRI', 'Thứ 6'),
    ('SAT', 'Thứ 7'),
  ];

  List<Map<String, dynamic>> _slotsForDay(
    List<Map<String, dynamic>> all,
    String dayCode,
  ) {
    final slots = all.where((slot) => slot['dayOfWeek'] == dayCode).toList();
    slots.sort(
      (a, b) => ((a['periodNo'] as num?)?.toInt() ?? 0).compareTo(
        (b['periodNo'] as num?)?.toInt() ?? 0,
      ),
    );
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: sl<ApiService>().classTimetableSlots(classId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Không thể tải thời khóa biểu'));
        }

        final all = snapshot.data ?? [];
        if (all.isEmpty) {
          return const Center(
            child: Text(
              'Lớp chưa có thời khóa biểu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final day in _days)
              if (_slotsForDay(all, day.$1).isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    day.$2,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.adminAccent,
                    ),
                  ),
                ),
                for (final slot in _slotsForDay(all, day.$1))
                  _TimetableSlotTile(slot: slot),
              ],
          ],
        );
      },
    );
  }
}

class _TimetableSlotTile extends StatelessWidget {
  const _TimetableSlotTile({required this.slot});

  final Map<String, dynamic> slot;

  @override
  Widget build(BuildContext context) {
    final details = [
      '${slot['startTime'] ?? ''}-${slot['endTime'] ?? ''}',
      slot['teacherName']?.toString() ?? '',
      slot['roomCode']?.toString() ?? '',
    ].where((value) => value.replaceAll('-', '').trim().isNotEmpty).join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.adminAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${slot['periodNo'] ?? ''}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.adminAccent,
            ),
          ),
        ),
        title: Text(
          slot['subjectName']?.toString() ?? '',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          details,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: slot['locked'] == true
            ? const Icon(Icons.lock_outline_rounded, size: 18)
            : null,
      ),
    );
  }
}

class ClassOverviewMetrics {
  const ClassOverviewMetrics({
    required this.averageScore,
    required this.attendanceRate,
    required this.unexcusedCount,
    required this.assignments,
  });

  factory ClassOverviewMetrics.fromRaw({
    required List<Map<String, dynamic>> grades,
    required List<Map<String, dynamic>> attendance,
    required List<Map<String, dynamic>> assignments,
  }) {
    final scores = grades
        .map((grade) => grade['score'])
        .whereType<num>()
        .map((score) => score.toDouble())
        .toList();
    final attended = attendance.where((record) {
      return const {'PRESENT', 'LATE'}.contains(record['status']);
    }).length;

    return ClassOverviewMetrics(
      averageScore: scores.isEmpty
          ? null
          : scores.reduce((a, b) => a + b) / scores.length,
      attendanceRate: attendance.isEmpty
          ? null
          : attended * 100 / attendance.length,
      unexcusedCount: attendance.where((record) {
        return record['status'] == 'ABSENT_UNEXCUSED';
      }).length,
      assignments: assignments,
    );
  }

  final double? averageScore;
  final double? attendanceRate;
  final int unexcusedCount;
  final List<Map<String, dynamic>> assignments;

  String get averageScoreLabel =>
      averageScore == null ? '—' : averageScore!.toStringAsFixed(1);
  String get attendanceRateLabel =>
      attendanceRate == null ? '—' : '${attendanceRate!.round()}%';
}
