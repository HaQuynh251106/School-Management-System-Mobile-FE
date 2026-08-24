import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/domain_realtime.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../shared/navigation/role_shortcut_navigation.dart';
import '../../../../shared/widgets/accent_tab_bar.dart';
import '../../../../shared/utils/vi_date_format.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/club_registration_page.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../../shared/widgets/school_day_status.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../../shared/widgets/upcoming_exam_banner.dart';
import '../../../../shared/widgets/yearly_summary_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../grades/data/grade_record.dart';
import 'assignment_detail.dart';
import 'attendance_record_detail.dart';
import 'exam_results_page.dart';
import 'subject_grade_detail.dart';
import 'timetable_slot_detail.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> with WidgetsBindingObserver {
  int _tab = 0;
  int _dataRevision = 0;
  late final DomainRealtimeSubscription _domainEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _domainEvents = DomainRealtimeSubscription.listen(
      realtime: sl<RealtimeService>(),
      domains: const {
        MobileDataDomain.timetable,
        MobileDataDomain.attendance,
        MobileDataDomain.grades,
        MobileDataDomain.assignments,
        MobileDataDomain.exams,
        MobileDataDomain.notifications,
        MobileDataDomain.educationPlan,
        MobileDataDomain.yearResult,
        MobileDataDomain.clubs,
      },
      onInvalidate: _invalidateData,
    );
  }

  void _invalidateData() {
    if (mounted) setState(() => _dataRevision++);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _invalidateData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_domainEvents.dispose());
    super.dispose();
  }

  void _selectTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return AdaptiveRoleScaffold(
      index: _tab,
      onSelected: _selectTab,
      accent: AppColors.studentAccent,
      pages: [
        KeyedSubtree(
          key: ValueKey('student-timetable-$_dataRevision'),
          child: _TimetableTab(onNavigate: _selectTab),
        ),
        KeyedSubtree(
          key: ValueKey('student-assignments-$_dataRevision'),
          child: const _AssignmentsTab(),
        ),
        KeyedSubtree(
          key: ValueKey('student-grades-$_dataRevision'),
          child: const _GradesTab(),
        ),
        KeyedSubtree(
          key: ValueKey('student-attendance-$_dataRevision'),
          child: const _AttendanceTab(),
        ),
        KeyedSubtree(
          key: ValueKey('student-profile-$_dataRevision'),
          child: _ProfileTab(onNavigate: _selectTab),
        ),
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
  const _TSlot(this.subject, this.period, this.time, this.room);
  final String subject;
  final String period;
  final String time;
  final String room;
}

class _TimetableTab extends StatefulWidget {
  const _TimetableTab({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _dayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _dayLabels = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
  ];
  late final List<DateTime> _weekDates;
  late Future<_StudentTimetableData> _future;

  @override
  void initState() {
    super.initState();
    _weekDates = schoolWeekDates(DateTime.now());
    _future = _load();
    final idx = (DateTime.now().weekday - 1).clamp(0, 5);
    _ctrl = TabController(length: _days.length, vsync: this, initialIndex: idx);
  }

  Future<_StudentTimetableData> _load() async {
    final api = sl<ApiService>();
    final timetable = api.myTimetable();
    final exams = api.examAgenda();
    final statuses = loadSchoolWeekStatuses(api, _weekDates);
    return _StudentTimetableData(
      timetable: await timetable,
      exams: await exams,
      statuses: await statuses,
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  void dispose() {
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
        bottom: AccentTabBar(
          accent: AppColors.studentAccent,
          controller: _ctrl,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: FutureBuilder<_StudentTimetableData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      apiErrorMessage(
                        snap.error,
                        fallback: 'Không thể tải thời khóa biểu.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snap.data!;
          final all = data.timetable;
          final exams = data.exams;
          return TabBarView(
            controller: _ctrl,
            children: List.generate(_days.length, (i) {
              final status = data.statuses[i];
              final slots =
                  all
                      .where((s) => s['dayOfWeek'] == _dayCodes[i])
                      .map(
                        (s) => _TSlot(
                          (s['subjectName'] ?? '').toString(),
                          'Tiết ${s['periodNo']}',
                          '${s['startTime'] ?? ''}–${s['endTime'] ?? ''}',
                          (s['roomCode'] ?? '').toString(),
                        ),
                      )
                      .toList()
                    ..sort((a, b) => a.period.compareTo(b.period));
              if (status.isHoliday) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    UpcomingExamBanner(
                      exams: exams,
                      accent: AppColors.studentAccent,
                      onTap: () => openRoleWorkspace(
                        context: context,
                        role: 'STUDENT',
                        accent: AppColors.studentAccent,
                        onNavigate: widget.onNavigate,
                      ),
                    ),
                    if (exams.isNotEmpty) const SizedBox(height: 12),
                    SchoolHolidayBanner(
                      status: status,
                      accent: AppColors.studentAccent,
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: slots.length + 1,
                itemBuilder: (_, j) {
                  if (j == 0) {
                    return Column(
                      children: [
                        UpcomingExamBanner(
                          exams: exams,
                          accent: AppColors.studentAccent,
                          onTap: () => openRoleWorkspace(
                            context: context,
                            role: 'STUDENT',
                            accent: AppColors.studentAccent,
                            onNavigate: widget.onNavigate,
                          ),
                        ),
                        if (exams.isNotEmpty) const SizedBox(height: 12),
                        RolePageIntro(
                          title: 'Hôm nay học gì?',
                          subtitle: slots.isEmpty
                              ? '${_dayLabels[i]} không có tiết học.'
                              : '${_dayLabels[i]} có ${slots.length} tiết học. Chạm vào từng tiết để xem chi tiết.',
                          accent: AppColors.studentAccent,
                          icon: Icons.wb_sunny_outlined,
                          badges: [
                            '${slots.length} tiết',
                            if (slots.isNotEmpty) slots.first.time,
                          ],
                        ),
                      ],
                    );
                  }
                  final s = slots[j - 1];
                  final colors = Theme.of(context).colorScheme;
                  final accent = AppColors.adaptiveAccent(
                    context,
                    AppColors.studentAccent,
                  );
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
                          ),
                        ),
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$j',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        s.subject,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${s.period} • ${s.time} • ${s.room}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                      ),
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

class _StudentTimetableData {
  const _StudentTimetableData({
    required this.timetable,
    required this.exams,
    required this.statuses,
  });

  final List<Map<String, dynamic>> timetable;
  final List<Map<String, dynamic>> exams;
  final List<SchoolDayStatus> statuses;
}

// ===================== GRADES (sub-tabs HK1 / HK2 / Cả năm) =====================

class _SubjectGrade {
  const _SubjectGrade({
    required this.subjectId,
    required this.semesterId,
    required this.subject,
    required this.scores,
    required this.average,
  });

  final String subjectId;
  final String semesterId;
  final String subject;
  final List<double?> scores; // [Miệng, 15p, GK, CK]
  final double? average;
}

class _GradesTab extends StatefulWidget {
  const _GradesTab();

  @override
  State<_GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<_GradesTab> {
  late final Future<List<List<Map<String, dynamic>>>> _future = Future.wait([
    sl<ApiService>().grades(),
    sl<ApiService>().semesters(),
    sl<ApiService>().gradeSummaries(),
  ]);

  // Order of categories in the score chips: [Miệng, 15p, GK, CK]
  static const _categoryOrder = ['ORAL', '15M', 'MID', 'FINAL'];

  /// Joins the real grade rows with the canonical backend summaries and keeps
  /// the ids required by the detail API. Multiple assessments in one category
  /// are represented by their category average in the compact card only; the
  /// detail screen still loads every assessment separately.
  List<_SubjectGrade> _subjectsFor(
    List<Map<String, dynamic>> grades,
    List<Map<String, dynamic>> summaries,
  ) {
    return buildSubjectGradeSelections(
      gradeRows: grades,
      summaryRows: summaries,
    ).map((selection) {
      final scores = _categoryOrder.map((category) {
        final values = selection.records.values
            .where((record) => record.category == category)
            .map((record) => record.score)
            .toList();
        return values.isEmpty
            ? null
            : values.reduce((left, right) => left + right) / values.length;
      }).toList();
      return _SubjectGrade(
        subjectId: selection.subjectId,
        semesterId: selection.semesterId,
        subject: selection.subjectName,
        scores: scores,
        average: selection.average,
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
        .where(
          (s) =>
              (s['code'] ?? '').toString() == code ||
              (s['sequence'] is num &&
                  (s['sequence'] as num).toInt() == sequence),
        )
        .map((s) => (s['id'] ?? '').toString())
        .toSet();
    return grades
        .where((g) => ids.contains((g['semesterId'] ?? '').toString()))
        .toList();
  }

  List<Map<String, dynamic>> _summariesForSemester(
    List<Map<String, dynamic>> summaries,
    List<Map<String, dynamic>> semesters,
    String code,
    int sequence,
  ) {
    final ids = semesters
        .where(
          (semester) =>
              '${semester['code'] ?? ''}' == code ||
              (semester['sequence'] is num &&
                  (semester['sequence'] as num).toInt() == sequence),
        )
        .map((semester) => '${semester['id'] ?? ''}')
        .toSet();
    return summaries
        .where((summary) => ids.contains('${summary['semesterId'] ?? ''}'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Điểm số'),
          backgroundColor: AppColors.studentAccent,
          actions: [
            IconButton(
              tooltip: 'Kết quả kỳ thi',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudentExamResultsPage(),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
            ),
            const _NotiAction(),
          ],
          bottom: const AccentTabBar(
            accent: AppColors.studentAccent,
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
                child: Text(
                  apiErrorMessage(snap.error!, fallback: 'Không thể tải điểm'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final data = snap.data ?? const [];
            final grades = data.isNotEmpty
                ? data[0]
                : const <Map<String, dynamic>>[];
            final semesters = data.length > 1
                ? data[1]
                : const <Map<String, dynamic>>[];
            final summaries = data.length > 2
                ? data[2]
                : const <Map<String, dynamic>>[];

            final hk1 = _subjectsFor(
              _gradesForSemester(grades, semesters, 'HK1', 1),
              _summariesForSemester(summaries, semesters, 'HK1', 1),
            );
            final hk2 = _subjectsFor(
              _gradesForSemester(grades, semesters, 'HK2', 2),
              _summariesForSemester(summaries, semesters, 'HK2', 2),
            );

            return TabBarView(
              children: [
                _SemesterGrades(semester: 'Học kỳ 1', subjects: hk1),
                _SemesterGrades(semester: 'Học kỳ 2', subjects: hk2),
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
  const _SemesterGrades({required this.semester, required this.subjects});
  final String semester;
  final List<_SubjectGrade> subjects;

  double? _avgFor(_SubjectGrade sg) {
    return sg.average;
  }

  @override
  Widget build(BuildContext context) {
    final allAvgs = subjects.map(_avgFor).whereType<double>().toList();
    final overall = allAvgs.isEmpty
        ? null
        : allAvgs.reduce((a, b) => a + b) / allAvgs.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: AppColors.studentAccent,
            ),
            title: const Text(
              'Tổng kết năm học',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Xem điểm cả năm, hạnh kiểm và kết quả lên lớp.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const YearlySummaryPage(accent: AppColors.studentAccent),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.studentAccent,
            ),
            title: const Text(
              'Kết quả kiểm tra học kỳ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Xem điểm giữa kỳ và cuối kỳ đã được nhà trường cập nhật.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudentExamResultsPage()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildBanner(semester, overall),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Theo môn học'),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Chưa có điểm',
                style: TextStyle(color: AppColors.textSecondary),
              ),
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
        color: AppColors.studentAccent,
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
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
    BuildContext context,
    _SubjectGrade sg,
    String semester,
  ) {
    final avg = _avgFor(sg);
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
                  Text(
                    sg.subject,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (avg != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _avgColor(avg).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TB: ${avg.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _avgColor(avg),
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ScoreChip('Miệng', sg.scores[0]),
                  const SizedBox(width: 6),
                  _ScoreChip('15p', sg.scores[1]),
                  const SizedBox(width: 6),
                  _ScoreChip('GK', sg.scores[2]),
                  const SizedBox(width: 6),
                  _ScoreChip('CK', sg.scores[3]),
                ],
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.divider),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              score != null ? score!.toStringAsFixed(1) : '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
    final hk1Avg = {
      for (final sg in hk1)
        if (sg.average != null) sg.subject: sg.average!,
    };
    final hk2Avg = {
      for (final sg in hk2)
        if (sg.average != null) sg.subject: sg.average!,
    };
    final hk1Subjects = hk1.map((subject) => subject.subject).toSet();
    final subjects = <String>[
      ...hk1.map((sg) => sg.subject),
      ...hk2.map((sg) => sg.subject).where((s) => !hk1Subjects.contains(s)),
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
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.studentAccent,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Trung bình cả năm = (TB HK1 + 2 × TB HK2) / 3',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'So sánh HK1 vs HK2'),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Chưa có điểm',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final subject in subjects)
            _buildYearlyRow(subject, hk1Avg[subject], hk2Avg[subject]),
      ],
    );
  }

  Widget _buildYearlyRow(String subject, double? hk1, double? hk2) {
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
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.studentAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Năm: ${year?.toStringAsFixed(2) ?? '—'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.studentAccent,
                    ),
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
                      const Text(
                        'HK1',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: hk1 == null ? 0 : hk1 / 10,
                        color: AppColors.studentAccent,
                        backgroundColor: AppColors.divider,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hk1?.toStringAsFixed(1) ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HK2',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: hk2 == null ? 0 : hk2 / 10,
                        color: AppColors.warning,
                        backgroundColor: AppColors.divider,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hk2?.toStringAsFixed(1) ?? '—',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
  const _ARecord(this.subject, this.date, this.status, this.note);
  final String subject;
  final String date;
  final String status;
  final String? note;
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab();
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  late final Future<List<Map<String, dynamic>>> _future = sl<ApiService>()
      .attendance();

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
              child: Text(
                apiErrorMessage(
                  snap.error!,
                  fallback: 'Không thể tải lịch sử chuyên cần',
                ),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final records = (snap.data ?? [])
              .map(
                (r) => _ARecord(
                  (r['subjectName'] ?? '').toString(),
                  formatViDate(r['date']),
                  (r['status'] ?? '').toString(),
                  r['note'] as String?,
                ),
              )
              .toList();
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu điểm danh',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
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
        _buildStats(stats),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Lịch sử chi tiết'),
        const SizedBox(height: 10),
        ...records.map(
          (r) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AttendanceRecordDetail(
                    subject: r.subject,
                    date: r.date,
                    status: r.status,
                    note: r.note,
                  ),
                ),
              ),
              leading: const Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              title: Text(
                r.subject,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
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
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Map<String, int> stats) {
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
                      color: colors[i],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
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
  const _ProfileTab({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final profileAccent = AppColors.adaptiveAccent(
      context,
      AppColors.studentAccent,
    );
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
                    backgroundColor: profileAccent.withValues(alpha: 0.12),
                    child: Text(
                      user.fullName[0],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: profileAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.studentCode ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: profileAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lớp ${user.className ?? "—"}',
                      style: TextStyle(
                        color: profileAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                  leading: Icon(
                    Icons.auto_awesome_rounded,
                    color: profileAccent,
                  ),
                  title: const Text('Trung tâm công việc'),
                  subtitle: const Text(
                    'Lịch thi, xin nghỉ và báo cáo',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => openRoleWorkspace(
                    context: context,
                    role: 'STUDENT',
                    accent: AppColors.studentAccent,
                    onNavigate: onNavigate,
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: profileAccent,
                  ),
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
                ListTile(
                  leading: Icon(Icons.groups_outlined, color: profileAccent),
                  title: const Text('Câu lạc bộ'),
                  subtitle: const Text(
                    'Đăng ký, theo dõi và hủy đăng ký',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClubRegistrationPage(
                        accent: AppColors.studentAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                const ThemeModeTile(accent: AppColors.studentAccent),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: profileAccent,
                  ),
                  title: const Text('Tin nhắn'),
                  subtitle: const Text(
                    'Chat với GV bộ môn',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChatListPage(accent: AppColors.studentAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
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
    this.id,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status,
    this.description,
    this.assignmentAttachmentFileId,
    this.assignmentAttachmentName,
    this.submissionId,
    this.submissionContent,
    this.submissionAttachmentFileId,
    this.submissionAttachmentName,
    this.score,
    this.feedback,
    this.assignmentStatus = 'PUBLISHED',
    this.deadlineAt,
    this.allowLate = false,
  });
  final String? id;
  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String status; // PENDING / SUBMITTED / LATE / GRADED
  final String? description;
  final String? assignmentAttachmentFileId;
  final String? assignmentAttachmentName;
  final String? submissionId;
  final String? submissionContent;
  final String? submissionAttachmentFileId;
  final String? submissionAttachmentName;
  final double? score;
  final String? feedback;
  final String assignmentStatus;
  final DateTime? deadlineAt;
  final bool allowLate;
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

_Assignment _assignmentFromJson(
  Map<String, dynamic> m,
  Map<String, dynamic>? submission,
) {
  final assignmentStatus = (m['status'] ?? '').toString();
  final deadlineAt = DateTime.tryParse(
    (m['deadline'] ?? '').toString(),
  )?.toLocal();
  final allowLate = m['allowLate'] == true;
  String status;
  if (submission != null) {
    status = (submission['status'] ?? 'SUBMITTED').toString();
  } else if (assignmentStatus != 'PUBLISHED') {
    status = 'CLOSED';
  } else if (deadlineAt != null && DateTime.now().isAfter(deadlineAt)) {
    status = allowLate ? 'LATE_ALLOWED' : 'OVERDUE';
  } else {
    status = 'PENDING';
  }
  return _Assignment(
    id: (m['id'] ?? '').toString(),
    title: (m['title'] ?? '').toString(),
    subject: (m['subjectName'] ?? '').toString(),
    teacher: (m['teacherName'] ?? '').toString(),
    deadline: _formatDeadline(m['deadline']),
    status: status,
    description: m['description']?.toString(),
    assignmentAttachmentFileId: m['attachmentFileId']?.toString(),
    assignmentAttachmentName: m['attachmentName']?.toString(),
    submissionId: submission?['id']?.toString(),
    submissionContent: submission?['content']?.toString(),
    submissionAttachmentFileId: submission?['attachmentFileId']?.toString(),
    submissionAttachmentName: submission?['attachmentName']?.toString(),
    score: (submission?['score'] as num?)?.toDouble(),
    feedback: submission?['feedback']?.toString(),
    assignmentStatus: assignmentStatus,
    deadlineAt: deadlineAt,
    allowLate: allowLate,
  );
}

class _AssignmentsTab extends StatefulWidget {
  const _AssignmentsTab();

  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab> {
  late Future<List<_Assignment>> _future = _load();

  Future<List<_Assignment>> _load() async {
    final results = await Future.wait([
      sl<ApiService>().myAssignments(),
      sl<ApiService>().mySubmissions(),
    ]);
    final submissions = <String, Map<String, dynamic>>{
      for (final item in results[1])
        (item['assignmentId'] ?? '').toString(): item,
    };
    return results[0]
        .map(
          (item) => _assignmentFromJson(
            item,
            submissions[(item['id'] ?? '').toString()],
          ),
        )
        .toList();
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<bool> _submit(_Assignment a) async {
    final id = a.id;
    if (id == null || id.isEmpty) return false;
    final draft = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (_) => _AssignmentSubmissionDialog(title: a.title),
    );
    if (draft == null || !mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    try {
      String? attachmentFileId;
      final file = draft['file'] as PlatformFile?;
      if (file != null) {
        if (file.bytes == null) {
          throw StateError('Không đọc được nội dung file đã chọn');
        }
        final uploaded = await sl<ApiService>().uploadFile(
          bytes: file.bytes!,
          fileName: file.name,
        );
        attachmentFileId = uploaded['id']?.toString();
      }
      await sl<ApiService>().submitAssignment(
        id,
        content: (draft['content'] ?? '').toString(),
        attachmentFileId: attachmentFileId,
      );
      if (!mounted) return false;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã nộp bài'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
      return true;
    } catch (e) {
      if (!mounted) return false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              e,
              fallback: 'Không thể nộp bài. Vui lòng thử lại.',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Assignment>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final assignments = snap.data ?? const <_Assignment>[];
        final pending = assignments
            .where(
              (a) =>
                  a.status == 'PENDING' ||
                  a.status == 'LATE_ALLOWED' ||
                  a.status == 'RESUBMISSION_ALLOWED',
            )
            .toList();
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
              actions: const [_NotiAction()],
              bottom: AccentTabBar(
                accent: AppColors.studentAccent,
                isScrollable: true,
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
                    child: Text(
                      apiErrorMessage(
                        snap.error!,
                        fallback: 'Không thể tải bài tập',
                      ),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : TabBarView(
                    children: [
                      _AssignmentList(items: assignments, onSubmit: _submit),
                      _AssignmentList(items: pending, onSubmit: _submit),
                      _AssignmentList(items: submitted, onSubmit: _submit),
                      _AssignmentList(items: graded, onSubmit: _submit),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _AssignmentSubmissionDialog extends StatefulWidget {
  const _AssignmentSubmissionDialog({required this.title});

  final String title;

  @override
  State<_AssignmentSubmissionDialog> createState() =>
      _AssignmentSubmissionDialogState();
}

class _AssignmentSubmissionDialogState
    extends State<_AssignmentSubmissionDialog> {
  final _controller = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 10,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nội dung bài làm',
                hintText: 'Nhập nội dung hoặc đính kèm file',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  withData: true,
                  allowMultiple: false,
                );
                if (result != null && mounted) {
                  setState(() => _selectedFile = result.files.single);
                }
              },
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(_selectedFile?.name ?? 'Chọn file'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isEmpty && _selectedFile == null) return;
            Navigator.pop(context, {'content': value, 'file': _selectedFile});
          },
          child: const Text('Nộp bài'),
        ),
      ],
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({required this.items, this.onSubmit});
  final List<_Assignment> items;
  final Future<bool> Function(_Assignment)? onSubmit;

  Color _statusColor(String status) => switch (status) {
    'GRADED' => AppColors.success,
    'SUBMITTED' => AppColors.primary,
    'LATE' => AppColors.warning,
    'RESUBMISSION_ALLOWED' => AppColors.warning,
    'LATE_ALLOWED' => AppColors.warning,
    'OVERDUE' => AppColors.error,
    'CLOSED' => AppColors.textSecondary,
    _ => AppColors.error,
  };

  String _statusLabel(String status) => switch (status) {
    'GRADED' => 'Đã chấm',
    'SUBMITTED' => 'Đã nộp',
    'LATE' => 'Nộp trễ',
    'RESUBMISSION_ALLOWED' => 'Được nộp lại',
    'LATE_ALLOWED' => 'Nộp muộn',
    'OVERDUE' => 'Quá hạn',
    'CLOSED' => 'Đã đóng',
    _ => 'Chưa nộp',
  };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài tập',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
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
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => StudentAssignmentDetail(
                    assignmentId: a.id!,
                    title: a.title,
                    subject: a.subject,
                    teacher: a.teacher,
                    deadline: a.deadline,
                    status: a.status,
                    description: a.description,
                    assignmentAttachmentFileId: a.assignmentAttachmentFileId,
                    assignmentAttachmentName: a.assignmentAttachmentName,
                    submissionContent: a.submissionContent,
                    submissionAttachmentFileId: a.submissionAttachmentFileId,
                    submissionAttachmentName: a.submissionAttachmentName,
                    score: a.score,
                    feedback: a.feedback,
                    onSubmit: () => onSubmit?.call(a) ?? Future.value(false),
                  ),
                ),
              );
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
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(a.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.studentAccent.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.subject,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.studentAccent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (a.status == 'GRADED' && a.score != null)
                        Text(
                          a.score!.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        a.teacher,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        a.deadline,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (onSubmit != null &&
                      (a.status == 'PENDING' ||
                          a.status == 'LATE_ALLOWED' ||
                          a.status == 'RESUBMISSION_ALLOWED') &&
                      a.id != null) ...[
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
                            horizontal: 8,
                            vertical: 0,
                          ),
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
      accent: AppColors.studentAccent,
      padding: 8,
    );
  }
}
