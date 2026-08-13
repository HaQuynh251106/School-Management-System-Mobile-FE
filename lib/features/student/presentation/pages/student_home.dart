import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../grades/data/grade_record.dart';
import '../../../attendance/data/attendance_metrics.dart';
import 'assignment_detail.dart';
import 'attendance_record_detail.dart';
import 'subject_grade_detail.dart';
import 'timetable_slot_detail.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveRoleScaffold(
      index: _tab,
      onSelected: (i) => setState(() => _tab = i),
      accent: AppColors.studentAccent,
      pages: [
        _TimetableTab(
          onOpenAssignments: () => setState(() => _tab = 1),
          onOpenGrades: () => setState(() => _tab = 2),
          onOpenAttendance: () => setState(() => _tab = 3),
        ),
        const _AssignmentsTab(),
        const _GradesTab(),
        const _AttendanceTab(),
        const _ProfileTab(),
      ],
      destinations: const [
        RoleDestination(
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month_rounded,
          label: 'Lịch học',
        ),
        RoleDestination(
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
          label: 'Bài tập',
        ),
        RoleDestination(
          icon: Icons.stars_outlined,
          selectedIcon: Icons.stars_rounded,
          label: 'Kết quả',
        ),
        RoleDestination(
          icon: Icons.event_available_outlined,
          selectedIcon: Icons.event_available_rounded,
          label: 'Chuyên cần',
        ),
        RoleDestination(
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          label: 'Tôi',
        ),
      ],
    );
  }
}

// ===================== TIMETABLE =====================

class _TSlot {
  const _TSlot(
      this.subject, this.period, this.time, this.room, this.teacherName);
  final String subject;
  final String period;
  final String time;
  final String room;
  final String teacherName;
}

class _TimetableTab extends StatefulWidget {
  const _TimetableTab({
    required this.onOpenAssignments,
    required this.onOpenGrades,
    required this.onOpenAttendance,
  });
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenAttendance;

  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _ctrl;
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6'];
  static const _dayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  static const _dayLabels = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu'
  ];
  late Future<List<List<Map<String, dynamic>>>> _future;
  StreamSubscription<RealtimeEvent>? _events;
  Timer? _reloadDebounce;

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().myTimetable(),
        sl<ApiService>().myAssignments(),
        sl<ApiService>().grades(),
        sl<ApiService>().attendance(),
      ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final idx = (DateTime.now().weekday - 1).clamp(0, 4);
    _ctrl = TabController(length: _days.length, vsync: this, initialIndex: idx);
    _future = _load();
    final realtime = sl<RealtimeService>()..connect();
    _events = realtime.events
        .where((event) => const {
              'TIMETABLE_PUBLISHED',
              'GRADE_CREATED',
              'GRADE_UPDATED',
              'ATTENDANCE_UPDATED',
            }.contains(event.type))
        .listen((_) => _scheduleReload());
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), _reload);
  }

  void _reload() {
    if (mounted) setState(() => _future = _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _events?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời khóa biểu'),
        backgroundColor: AppColors.studentAccent,
        actions: const [_NotiAction()],
        bottom: TabBar(
          controller: _ctrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
                child: Text('Không thể tải thông tin tổng quan.'));
          }
          final batches = snap.data ?? const [];
          final all =
              batches.isEmpty ? const <Map<String, dynamic>>[] : batches.first;
          final assignments =
              batches.length > 1 ? batches[1] : const <Map<String, dynamic>>[];
          final grades =
              batches.length > 2 ? batches[2] : const <Map<String, dynamic>>[];
          final attendance =
              batches.length > 3 ? batches[3] : const <Map<String, dynamic>>[];
          final pendingAssignments = assignments
              .where((item) =>
                  '${item['status']}' == 'PUBLISHED' ||
                  '${item['status']}' == 'PENDING')
              .length;
          final gradedSubjects = grades
              .where((item) => item['score'] is num)
              .map((item) => '${item['subjectId'] ?? item['subjectName']}')
              .where((value) => value.isNotEmpty)
              .toSet()
              .length;
          final attendanceIssues = attendance
              .where((item) => isAbsentAttendanceStatus(item['status']))
              .length;
          return TabBarView(
            controller: _ctrl,
            children: List.generate(5, (i) {
              final slots = all
                  .where((s) => s['dayOfWeek'] == _dayCodes[i])
                  .map((s) => _TSlot(
                        (s['subjectName'] ?? '').toString(),
                        'Tiết ${s['periodNo']}',
                        '${s['startTime'] ?? ''}–${s['endTime'] ?? ''}',
                        (s['roomCode'] ?? '').toString(),
                        (s['teacherName'] ?? '').toString(),
                      ))
                  .toList()
                ..sort((a, b) => a.period.compareTo(b.period));
              Widget overview() => Column(children: [
                    RolePageIntro(
                      title: 'Hôm nay học gì?',
                      subtitle:
                          '${_dayLabels[i]} có ${slots.length} tiết học. Chọn mục bên dưới để xem chi tiết.',
                      accent: AppColors.studentAccent,
                      icon: Icons.wb_sunny_outlined,
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.15,
                      children: [
                        _StudentShortcut(
                          value: '${slots.length}',
                          label: 'Tiết trong ngày',
                          icon: Icons.calendar_today_rounded,
                          onTap: slots.isEmpty
                              ? () {}
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentTimetableSlotDetail(
                                        subject: slots.first.subject,
                                        period: slots.first.period,
                                        time: slots.first.time,
                                        room: slots.first.room,
                                        dayLabel: _dayLabels[i],
                                        teacherName: slots.first.teacherName,
                                      ),
                                    ),
                                  ),
                        ),
                        _StudentShortcut(
                          value: '$pendingAssignments',
                          label: 'Bài tập chưa nộp',
                          icon: Icons.assignment_late_rounded,
                          onTap: widget.onOpenAssignments,
                        ),
                        _StudentShortcut(
                          value: '$gradedSubjects',
                          label: 'Môn đã có điểm',
                          icon: Icons.stars_rounded,
                          onTap: widget.onOpenGrades,
                        ),
                        _StudentShortcut(
                          value: '$attendanceIssues',
                          label: 'Buổi vắng/trễ',
                          icon: Icons.event_busy_rounded,
                          onTap: widget.onOpenAttendance,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ]);
              if (slots.isEmpty) {
                return ListView(padding: const EdgeInsets.all(16), children: [
                  overview(),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.free_breakfast_rounded),
                      title: Text('Không có tiết học trong ngày'),
                    ),
                  ),
                ]);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: slots.length + 1,
                itemBuilder: (_, j) {
                  if (j == 0) {
                    return overview();
                  }
                  final s = slots[j - 1];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudentTimetableSlotDetail(
                            subject: s.subject,
                            period: s.period,
                            time: s.time,
                            room: s.room,
                            dayLabel: _dayLabels[i],
                            teacherName: s.teacherName,
                          ),
                        ),
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.studentAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$j',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.studentAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(s.subject,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.period} • ${s.time} • ${s.room}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      trailing: Icon(Icons.chevron_right_rounded,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}

class _StudentShortcut extends StatelessWidget {
  const _StudentShortcut({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(icon, color: AppColors.studentAccent, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
                    ]),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.studentAccent, size: 16),
            ]),
          ),
        ),
      );
}

// ===================== GRADES (sub-tabs HK1 / HK2 / Cả năm) =====================

class _SubjectGrade {
  const _SubjectGrade({
    required this.subjectId,
    required this.subject,
    required this.semesterId,
    required this.records,
    required this.average,
  });
  final String subjectId;
  final String subject;
  final String semesterId;
  final Map<String, GradeRecord> records;
  final double? average;
}

class _GradesTab extends StatefulWidget {
  const _GradesTab();

  @override
  State<_GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<_GradesTab> with WidgetsBindingObserver {
  late Future<List<List<Map<String, dynamic>>>> _future;
  StreamSubscription<RealtimeEvent>? _gradeEvents;
  Timer? _reloadDebounce;

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().grades(),
        sl<ApiService>().semesters(),
        sl<ApiService>().examCategories(),
        sl<ApiService>().gradeSummaries(),
      ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
    final realtime = sl<RealtimeService>()..connect();
    _gradeEvents = realtime.events
        .where((event) =>
            event.type == 'GRADE_CREATED' || event.type == 'GRADE_UPDATED')
        .listen((_) => _scheduleReload());
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), _reload);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _gradeEvents?.cancel();
    super.dispose();
  }

  List<_SubjectGrade> _subjectsFor(
    List<Map<String, dynamic>> grades,
    List<GradeSubjectSummary> summaries,
  ) {
    final bySubject = <String, List<GradeRecord>>{};
    final order = <String>[];
    for (final raw in grades) {
      final grade = GradeRecord.fromJson(raw);
      final groupKey = '${grade.subjectId}|${grade.semesterId}';
      bySubject.putIfAbsent(groupKey, () {
        order.add(groupKey);
        return <GradeRecord>[];
      }).add(grade);
    }
    final summaryByKey = {
      for (final summary in summaries) summary.key: summary
    };
    return order.map((key) {
      final records = bySubject[key]!;
      final first = records.first;
      return _SubjectGrade(
        subjectId: first.subjectId,
        subject: first.subjectName,
        semesterId: first.semesterId,
        records: {for (final record in records) record.key: record},
        average: summaryByKey[key]?.average,
      );
    }).toList();
  }

  /// Find the semesterId(s) matching code 'HK1'/'HK2' (fallback to sequence
  /// 1/2), then return all grades whose semesterId is in that set.
  List<Map<String, dynamic>> _gradesForSemester(
    List<Map<String, dynamic>> grades,
    List<Map<String, dynamic>> semesters,
    String code,
    int sequence,
  ) {
    final ids = semesters
        .where((s) =>
            (s['code'] ?? '').toString() == code ||
            (s['sequence'] is num &&
                (s['sequence'] as num).toInt() == sequence))
        .map((s) => (s['id'] ?? '').toString())
        .toSet();
    return grades
        .where((g) => ids.contains((g['semesterId'] ?? '').toString()))
        .toList();
  }

  String _semesterLabel(List<Map<String, dynamic>> semesters, String code,
      int sequence, String fallback) {
    final matches = semesters.where((semester) =>
        '${semester['code'] ?? ''}' == code ||
        (semester['sequence'] as num?)?.toInt() == sequence);
    if (matches.isEmpty) return fallback;
    final semester = matches.first;
    return '${semester['name'] ?? semester['code'] ?? fallback}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Điểm số'),
          backgroundColor: AppColors.studentAccent,
          actions: const [_NotiAction()],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'HK1'),
              Tab(text: 'HK2'),
              Tab(text: 'Cả năm'),
            ],
          ),
        ),
        body: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                  child: Text('Không thể tải kết quả học tập.',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)));
            }
            final data = snap.data ?? const [];
            final grades =
                data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[];
            final semesters =
                data.length > 1 ? data[1] : const <Map<String, dynamic>>[];
            final columns = buildGradeColumns(
                (data.length > 2 ? data[2] : const <Map<String, dynamic>>[])
                    .map(GradeCategoryDefinition.fromJson)
                    .toList());
            final summaries =
                (data.length > 3 ? data[3] : const <Map<String, dynamic>>[])
                    .map(GradeSubjectSummary.fromJson)
                    .toList();

            final hk1 = _subjectsFor(
                _gradesForSemester(grades, semesters, 'HK1', 1), summaries);
            final hk2 = _subjectsFor(
                _gradesForSemester(grades, semesters, 'HK2', 2), summaries);

            return TabBarView(
              children: [
                _SemesterGrades(
                    semester: _semesterLabel(semesters, 'HK1', 1, 'Học kỳ 1'),
                    subjects: hk1,
                    columns: columns),
                _SemesterGrades(
                    semester: _semesterLabel(semesters, 'HK2', 2, 'Học kỳ 2'),
                    subjects: hk2,
                    columns: columns),
                _YearlyGradesView(hk1: hk1, hk2: hk2),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SemesterGrades extends StatelessWidget {
  const _SemesterGrades({
    required this.semester,
    required this.subjects,
    required this.columns,
  });
  final String semester;
  final List<_SubjectGrade> subjects;
  final List<GradeColumn> columns;

  @override
  Widget build(BuildContext context) {
    final allAvgs =
        subjects.map((subject) => subject.average).whereType<double>().toList();
    final overall = allAvgs.isEmpty
        ? null
        : allAvgs.reduce((a, b) => a + b) / allAvgs.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBanner(semester, overall),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Theo môn học'),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Chưa có điểm',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          )
        else
          ...subjects.map((sg) => _buildSubjectCard(context, sg, semester)),
      ],
    );
  }

  Widget _buildBanner(String label, double? overall) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.studentAccent,
            AppColors.studentAccent.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded, color: Colors.white70, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  overall == null
                      ? 'Chưa có điểm'
                      : 'Trung bình: ${overall.toStringAsFixed(2)} • ${_classify(overall)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _classify(double avg) {
    if (avg >= 8) return 'Giỏi';
    if (avg >= 6.5) return 'Khá';
    if (avg >= 5) return 'Trung bình';
    return 'Yếu';
  }

  Widget _buildSubjectCard(
      BuildContext context, _SubjectGrade sg, String semester) {
    final avg = sg.average;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubjectGradeDetail(
              subject: sg.subject,
              subjectId: sg.subjectId,
              semesterId: sg.semesterId,
              semester: semester,
              average: sg.average,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(sg.subject,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (avg != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _avgColor(avg).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TB: ${avg.toStringAsFixed(1)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _avgColor(avg)),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: columns
                      .map((column) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _ScoreChip(
                              column.label,
                              sg.records[column.key]?.score,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _avgColor(double avg) {
    if (avg >= 8) return AppColors.success;
    if (avg >= 6.5) return AppColors.warning;
    return AppColors.error;
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip(this.label, this.score);
  final String label;
  final double? score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.fromBorderSide(
            BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(
              score != null ? score!.toStringAsFixed(1) : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearlyGradesView extends StatelessWidget {
  const _YearlyGradesView({required this.hk1, required this.hk2});
  final List<_SubjectGrade> hk1;
  final List<_SubjectGrade> hk2;

  @override
  Widget build(BuildContext context) {
    // Union of subjects across both semesters, preserving HK1 order first.
    final hk1Avg = {for (final sg in hk1) sg.subject: sg.average};
    final hk2Avg = {for (final sg in hk2) sg.subject: sg.average};
    final subjects = <String>[
      ...hk1.map((sg) => sg.subject),
      ...hk2.map((sg) => sg.subject).where((s) => !hk1Avg.containsKey(s)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.studentAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.studentAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Trung bình cả năm = (TB HK1 + 2 × TB HK2) / 3',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'So sánh HK1 vs HK2'),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Chưa có điểm',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          )
        else
          for (final subject in subjects)
            _buildYearlyRow(
              context,
              subject,
              hk1Avg[subject],
              hk2Avg[subject],
            ),
      ],
    );
  }

  Widget _buildYearlyRow(
      BuildContext context, String subject, double? hk1, double? hk2) {
    final year = hk1 != null && hk2 != null ? (hk1 + 2 * hk2) / 3 : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(subject,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.studentAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Năm: ${year?.toStringAsFixed(2) ?? '—'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.studentAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HK1',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      LinearProgressIndicator(
                        value: (hk1 ?? 0) / 10,
                        color: AppColors.studentAccent,
                        backgroundColor:
                            Theme.of(context).colorScheme.outlineVariant,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(hk1?.toStringAsFixed(1) ?? '—',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HK2',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      LinearProgressIndicator(
                        value: (hk2 ?? 0) / 10,
                        color: AppColors.warning,
                        backgroundColor:
                            Theme.of(context).colorScheme.outlineVariant,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(hk2?.toStringAsFixed(1) ?? '—',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== ATTENDANCE (sub-tabs Tuần / Tháng / HK) =====================

class _ARecord {
  const _ARecord(
      this.subject, this.date, this.status, this.note, this.periodNo);
  final String subject;
  final String date;
  final String status;
  final String? note;
  final int? periodNo;
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab();
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future;
  StreamSubscription<RealtimeEvent>? _attendanceEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = sl<ApiService>().attendance();
    final realtime = sl<RealtimeService>()..connect();
    _attendanceEvents = realtime.events
        .where((event) => event.type == 'ATTENDANCE_UPDATED')
        .listen((_) => _scheduleReload());
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), _reload);
  }

  void _reload() {
    if (mounted) setState(() => _future = sl<ApiService>().attendance());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _attendanceEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyên cần'),
        backgroundColor: AppColors.studentAccent,
        actions: const [_NotiAction()],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải dữ liệu chuyên cần.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final records = (snap.data ?? [])
              .map((r) => _ARecord(
                    (r['subjectName'] ?? '').toString(),
                    (r['date'] ?? '').toString(),
                    (r['status'] ?? '').toString(),
                    r['note'] as String?,
                    (r['periodNo'] as num?)?.toInt(),
                  ))
              .toList();
          if (records.isEmpty) {
            return Center(
                child: Text('Chưa có dữ liệu điểm danh',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          return _AttendanceRange(records: records, rangeLabel: 'học kỳ');
        },
      ),
    );
  }
}

class _AttendanceRange extends StatelessWidget {
  const _AttendanceRange({required this.records, required this.rangeLabel});
  final List<_ARecord> records;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    final stats = {
      'Có mặt': records.where((r) => r.status == 'PRESENT').length,
      'Vắng phép': records.where((r) => r.status == 'ABSENT_EXCUSED').length,
      'Vắng KP': records.where((r) => r.status == 'ABSENT_UNEXCUSED').length,
      'Muộn': records.where((r) => r.status == 'LATE').length,
    };
    final rate = records.isEmpty
        ? 0.0
        : (stats['Có mặt']! + stats['Muộn']! * 0.5) / records.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RateBanner(rate: rate, rangeLabel: rangeLabel),
        const SizedBox(height: 14),
        _buildStats(context, stats),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Lịch sử chi tiết'),
        const SizedBox(height: 10),
        ...records.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AttendanceRecordDetail(
                      subject: r.subject,
                      date: r.date,
                      status: r.status,
                      note: r.note,
                      periodNo: r.periodNo,
                    ),
                  ),
                ),
                leading: Icon(Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20),
                title: Text(r.subject,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  r.note ?? r.date,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AttendanceBadge(r.status),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildStats(BuildContext context, Map<String, int> stats) {
    final colors = [
      AppColors.present,
      AppColors.absentExcused,
      AppColors.absentUnexcused,
      AppColors.late,
    ];
    return Row(
      children: List.generate(stats.length, (i) {
        final entry = stats.entries.elementAt(i);
        return Expanded(
          child: Card(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colors[i]),
                  ),
                  const SizedBox(height: 2),
                  Text(entry.key,
                      style: TextStyle(
                          fontSize: 10,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _RateBanner extends StatelessWidget {
  const _RateBanner({required this.rate, required this.rangeLabel});
  final double rate;
  final String rangeLabel;

  Color get _color {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate,
                  color: _color,
                  backgroundColor: _color.withValues(alpha: 0.18),
                  strokeWidth: 5,
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                      color: _color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tỉ lệ chuyên cần $rangeLabel',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  rate >= 0.9
                      ? 'Rất tốt — duy trì nhé!'
                      : rate >= 0.75
                          ? 'Cần cải thiện'
                          : 'Cảnh báo — đã thông báo PH',
                  style: TextStyle(color: _color, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== PROFILE =====================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: AppColors.studentAccent,
        actions: const [_NotiAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppColors.studentAccent.withValues(alpha: 0.12),
                    child: Text(
                      user.fullName[0],
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.studentAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(user.studentCode ?? '',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.studentAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lớp ${user.className ?? "—"}',
                      style: const TextStyle(
                          color: AppColors.studentAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.studentAccent),
                  title: const Text('Trung tâm công việc'),
                  subtitle: const Text('Lịch thi, xin nghỉ và báo cáo',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MobileWorkspacePage(
                        role: 'STUDENT',
                        accent: AppColors.studentAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined,
                      color: AppColors.studentAccent),
                  title: const Text('Thông báo'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenter(
                        accent: AppColors.studentAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                const ThemeModeTile(accent: AppColors.studentAccent),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.studentAccent),
                  title: const Text('Tin nhắn'),
                  subtitle: const Text('Nhắn tin với giáo viên bộ môn',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatListPage(
                        accent: AppColors.studentAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Đăng xuất',
                style: TextStyle(color: AppColors.error)),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}

// ===================== ASSIGNMENTS TAB =====================

class _Assignment {
  const _Assignment({
    required this.id,
    required this.raw,
    required this.submission,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status,
    this.score,
    this.feedback,
  });
  final String id;
  final Map<String, dynamic> raw;
  final Map<String, dynamic>? submission;
  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String status; // PENDING / SUBMITTED / LATE / GRADED
  final double? score;
  final String? feedback;
}

/// Format an ISO-8601 deadline string into a short 'dd/MM HH:mm' label.
/// Returns '—' for null/blank/unparseable values.
String _formatDeadline(Object? raw) {
  final s = (raw ?? '').toString();
  if (s.isEmpty) return '—';
  final dt = DateTime.tryParse(s);
  if (dt == null) return s;
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
}

/// Map an API assignment status to the existing display-status vocabulary so
/// the colour/label logic in [_AssignmentList] keeps working. The student's
/// own submission state isn't part of /me/assignments, so we surface the
/// assignment status: PUBLISHED -> PENDING (chưa nộp), CLOSED/DRAFT kept raw.
String _mapAssignmentStatus(Object? raw) {
  final s = (raw ?? '').toString();
  return s == 'PUBLISHED' ? 'PENDING' : s;
}

_Assignment _assignmentFromJson(
  Map<String, dynamic> m,
  Map<String, dynamic>? submission,
) =>
    _Assignment(
      id: '${m['id'] ?? ''}',
      raw: m,
      submission: submission,
      title: (m['title'] ?? '').toString(),
      subject: (m['subjectName'] ?? '').toString(),
      teacher: (m['teacherName'] ?? '').toString(),
      deadline: _formatDeadline(m['deadline']),
      status: submission == null
          ? _mapAssignmentStatus(m['status'])
          : '${submission['status'] ?? 'SUBMITTED'}',
      score: (submission?['score'] as num?)?.toDouble(),
      feedback: submission?['feedback']?.toString(),
    );

class _AssignmentsTab extends StatefulWidget {
  const _AssignmentsTab();

  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab>
    with WidgetsBindingObserver {
  late Future<List<List<Map<String, dynamic>>>> _future = _load();
  StreamSubscription<RealtimeEvent>? _assignmentEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _assignmentEvents = realtime.events
        .where((event) => event.type == 'ASSIGNMENT_UPDATED')
        .listen((_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _assignmentEvents?.cancel();
    super.dispose();
  }

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().myAssignments(),
        sl<ApiService>().mySubmissions(),
      ]);

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _submit(_Assignment a) async {
    final id = a.id;
    if (id.isEmpty) return;
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(a.title),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 10,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nội dung bài làm',
            hintText: 'Nhập nội dung hoặc đường dẫn bài làm',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content == null) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<ApiService>().submitAssignment(id, content: content);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã nộp bài'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể nộp bài. Vui lòng thử lại.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final data = snap.data ?? const [];
        final submissions =
            data.length > 1 ? data[1] : const <Map<String, dynamic>>[];
        final submissionByAssignment = {
          for (final submission in submissions)
            '${submission['assignmentId'] ?? ''}': submission,
        };
        final assignments =
            (data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[])
                .map((item) => _assignmentFromJson(
                      item,
                      submissionByAssignment['${item['id'] ?? ''}'],
                    ))
                .toList();
        final pending =
            assignments.where((a) => a.status == 'PENDING').toList();
        final submitted = assignments
            .where((a) => a.status == 'SUBMITTED' || a.status == 'LATE')
            .toList();
        final graded = assignments.where((a) => a.status == 'GRADED').toList();
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Bài tập'),
              backgroundColor: AppColors.studentAccent,
              actions: [
                IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded)),
                const _NotiAction(),
              ],
              bottom: TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Tất cả (${assignments.length})'),
                  Tab(text: 'Chưa nộp (${pending.length})'),
                  Tab(text: 'Đã nộp (${submitted.length})'),
                  Tab(text: 'Đã chấm (${graded.length})'),
                ],
              ),
            ),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                    ? Center(
                        child: Text('Không thể tải bài tập.',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)))
                    : TabBarView(
                        children: [
                          _AssignmentList(
                              items: assignments,
                              onSubmit: _submit,
                              onChanged: _refresh),
                          _AssignmentList(
                              items: pending,
                              onSubmit: _submit,
                              onChanged: _refresh),
                          _AssignmentList(
                              items: submitted,
                              onSubmit: _submit,
                              onChanged: _refresh),
                          _AssignmentList(
                              items: graded,
                              onSubmit: _submit,
                              onChanged: _refresh),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({
    required this.items,
    this.onSubmit,
    this.onChanged,
  });
  final List<_Assignment> items;
  final void Function(_Assignment)? onSubmit;
  final VoidCallback? onChanged;

  Color _statusColor(String status) => switch (status) {
        'GRADED' => AppColors.success,
        'SUBMITTED' => AppColors.primary,
        'LATE' => AppColors.warning,
        _ => AppColors.error,
      };

  String _statusLabel(String status) => switch (status) {
        'GRADED' => 'Đã chấm',
        'SUBMITTED' => 'Đã nộp',
        'LATE' => 'Nộp trễ',
        _ => 'Chưa nộp',
      };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
          child: Text('Không có bài tập',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = items[i];
        final color = _statusColor(a.status);
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StudentAssignmentDetail(
                    assignment: a.raw,
                    submission: a.submission,
                    title: a.title,
                    subject: a.subject,
                    teacher: a.teacher,
                    deadline: a.deadline,
                    status: a.status,
                    score: a.score,
                    feedback: a.feedback,
                  ),
                ),
              );
              onChanged?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_statusLabel(a.status),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.studentAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(a.subject,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.studentAccent)),
                      ),
                      const Spacer(),
                      if (a.score != null)
                        Text(
                          a.score!.toStringAsFixed(1),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 12,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(a.teacher,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      const Spacer(),
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(a.deadline,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                  if (onSubmit != null &&
                      a.status == 'PENDING' &&
                      a.id.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onSubmit!(a),
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: const Text('Nộp bài'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.studentAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===================== NOTIFICATION ACTION =====================

class _NotiAction extends StatelessWidget {
  const _NotiAction();

  @override
  Widget build(BuildContext context) {
    return const LiveNotificationAction(
        accent: AppColors.studentAccent, padding: 8);
  }
}
