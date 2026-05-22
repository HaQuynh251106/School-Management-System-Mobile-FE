import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'assignment_detail.dart';
import 'attendance_record_detail.dart';
import 'extracurricular_page.dart';
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
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          _TimetableTab(),
          _GradesTab(),
          _AttendanceTab(),
          _AssignmentsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppColors.studentAccent.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppColors.studentAccent),
            label: 'TKB',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            selectedIcon:
                Icon(Icons.stars_rounded, color: AppColors.studentAccent),
            label: 'Điểm',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available_rounded,
                color: AppColors.studentAccent),
            label: 'Chuyên cần',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded,
                color: AppColors.studentAccent),
            label: 'Bài tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppColors.studentAccent),
            label: 'Tôi',
          ),
        ],
      ),
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

const _weekSlots = <int, List<_TSlot>>{
  0: [
    _TSlot('Toán', 'Tiết 1', '07:00–07:45', 'P201'),
    _TSlot('Vật lý', 'Tiết 2', '07:50–08:35', 'P201'),
    _TSlot('Ngữ văn', 'Tiết 3', '08:45–09:30', 'P201'),
  ],
  1: [
    _TSlot('Tiếng Anh', 'Tiết 1', '07:00–07:45', 'P201'),
    _TSlot('Sinh học', 'Tiết 2', '07:50–08:35', 'P201'),
  ],
  2: [
    _TSlot('Toán', 'Tiết 1', '07:00–07:45', 'P201'),
  ],
  3: [
    _TSlot('Vật lý', 'Tiết 2', '07:50–08:35', 'Lab 1'),
    _TSlot('Tiếng Anh', 'Tiết 3', '08:45–09:30', 'P201'),
  ],
  4: [
    _TSlot('Ngữ văn', 'Tiết 1', '07:00–07:45', 'P201'),
    _TSlot('Toán', 'Tiết 4', '09:35–10:20', 'P201'),
  ],
};

class _TimetableTab extends StatefulWidget {
  const _TimetableTab();

  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6'];
  static const _dayLabels = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu'
  ];

  @override
  void initState() {
    super.initState();
    final idx = (DateTime.now().weekday - 1).clamp(0, 4);
    _ctrl = TabController(length: _days.length, vsync: this, initialIndex: idx);
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
        bottom: TabBar(
          controller: _ctrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _ctrl,
        children: List.generate(5, (i) {
          final slots = _weekSlots[i] ?? [];
          if (slots.isEmpty) {
            return const Center(
              child: Text('Không có tiết học',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            itemBuilder: (_, j) {
              final s = slots[j];
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
                      color: AppColors.studentAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${j + 1}',
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
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ===================== GRADES (sub-tabs HK1 / HK2 / Cả năm) =====================

class _SubjectGrade {
  const _SubjectGrade(this.subject, this.scores);
  final String subject;
  final List<double?> scores; // [Miệng, 15p, GK, CK]
}

const _gradesHk1 = <_SubjectGrade>[
  _SubjectGrade('Toán', [9.0, 8.5, 7.5, 8.8]),
  _SubjectGrade('Vật lý', [8.0, 7.8, 8.8, 8.0]),
  _SubjectGrade('Tiếng Anh', [7.0, 7.5, 8.0, 7.5]),
  _SubjectGrade('Ngữ văn', [7.5, 6.0, 6.5, 7.0]),
  _SubjectGrade('Sinh học', [8.5, 7.0, 8.0, 8.5]),
];

const _gradesHk2 = <_SubjectGrade>[
  _SubjectGrade('Toán', [8.5, 8.0, null, null]),
  _SubjectGrade('Vật lý', [9.0, null, null, null]),
  _SubjectGrade('Tiếng Anh', [7.5, null, null, null]),
  _SubjectGrade('Ngữ văn', [null, null, null, null]),
  _SubjectGrade('Sinh học', [null, null, null, null]),
];

class _GradesTab extends StatelessWidget {
  const _GradesTab();

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
        body: const TabBarView(
          children: [
            _SemesterGrades(semester: 'Học kỳ 1 — 2025/2026', subjects: _gradesHk1),
            _SemesterGrades(semester: 'Học kỳ 2 — 2025/2026', subjects: _gradesHk2),
            _YearlyGradesView(),
          ],
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
    final scores = sg.scores.whereType<double>().toList();
    if (scores.isEmpty) return null;
    // weights: M=1, 15p=1, GK=2, CK=3
    const weights = [1, 1, 2, 3];
    var sumW = 0;
    var sum = 0.0;
    for (var i = 0; i < sg.scores.length; i++) {
      if (sg.scores[i] != null) {
        sum += sg.scores[i]! * weights[i];
        sumW += weights[i];
      }
    }
    return sum / sumW;
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
        _buildBanner(semester, overall),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Theo môn học'),
        const SizedBox(height: 10),
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
            AppColors.studentAccent.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded,
              color: Colors.white70, size: 36),
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
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
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
    final avg = _avgFor(sg);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubjectGradeDetail(
              subject: sg.subject,
              semester: semester,
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
                        color: _avgColor(avg).withOpacity(0.12),
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
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 18),
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
          border:
              const Border.fromBorderSide(BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
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
  const _YearlyGradesView();

  double _avg(List<double?> scores) {
    const weights = [1, 1, 2, 3];
    var sumW = 0;
    var sum = 0.0;
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] != null) {
        sum += scores[i]! * weights[i];
        sumW += weights[i];
      }
    }
    return sumW == 0 ? 0 : sum / sumW;
  }

  @override
  Widget build(BuildContext context) {
    final data = <Map<String, double>>[];
    for (var i = 0; i < _gradesHk1.length; i++) {
      data.add({
        'hk1': _avg(_gradesHk1[i].scores),
        'hk2': _avg(_gradesHk2[i].scores),
      });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.studentAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.studentAccent, size: 20),
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
        for (var i = 0; i < _gradesHk1.length; i++)
          _buildYearlyRow(
            _gradesHk1[i].subject,
            data[i]['hk1']!,
            data[i]['hk2']!,
          ),
      ],
    );
  }

  Widget _buildYearlyRow(String subject, double hk1, double hk2) {
    final year = hk2 == 0 ? hk1 : (hk1 + 2 * hk2) / 3;
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.studentAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Năm: ${year.toStringAsFixed(2)}',
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
                      const Text('HK1',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                      LinearProgressIndicator(
                        value: hk1 / 10,
                        color: AppColors.studentAccent,
                        backgroundColor: AppColors.divider,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(hk1.toStringAsFixed(1),
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
                      const Text('HK2',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                      LinearProgressIndicator(
                        value: hk2 / 10,
                        color: AppColors.warning,
                        backgroundColor: AppColors.divider,
                        minHeight: 5,
                      ),
                      const SizedBox(height: 2),
                      Text(hk2 == 0 ? '—' : hk2.toStringAsFixed(1),
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
  const _ARecord(this.subject, this.date, this.status, this.note);
  final String subject;
  final String date;
  final String status;
  final String? note;
}

const _attWeek = <_ARecord>[
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
  _ARecord('Sinh học', '19/05', 'LATE', 'Muộn 10 phút'),
  _ARecord('Toán', '20/05', 'ABSENT_EXCUSED', 'Có đơn xin nghỉ ốm'),
  _ARecord('Vật lý', '21/05', 'PRESENT', null),
  _ARecord('Toán', '21/05', 'PRESENT', null),
];

const _attMonth = <_ARecord>[
  _ARecord('Tiếng Anh', '02/05', 'PRESENT', null),
  _ARecord('Toán', '03/05', 'PRESENT', null),
  _ARecord('Vật lý', '06/05', 'LATE', 'Muộn 5 phút'),
  _ARecord('Ngữ văn', '08/05', 'ABSENT_EXCUSED', 'Đám tang ông'),
  _ARecord('Sinh học', '12/05', 'PRESENT', null),
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
  _ARecord('Sinh học', '19/05', 'LATE', 'Muộn 10 phút'),
  _ARecord('Toán', '20/05', 'ABSENT_EXCUSED', 'Có đơn xin nghỉ ốm'),
];

const _attSemester = <_ARecord>[
  _ARecord('Toán', '15/09', 'PRESENT', null),
  _ARecord('Vật lý', '22/09', 'LATE', 'Muộn 3 phút'),
  _ARecord('Tiếng Anh', '10/10', 'ABSENT_EXCUSED', 'Tham gia thi học sinh giỏi'),
  _ARecord('Sinh học', '25/10', 'ABSENT_UNEXCUSED', 'Trốn tiết'),
  _ARecord('Ngữ văn', '08/11', 'PRESENT', null),
  _ARecord('Toán', '12/11', 'PRESENT', null),
  _ARecord('Vật lý', '20/11', 'PRESENT', null),
  _ARecord('Tiếng Anh', '02/05', 'PRESENT', null),
  _ARecord('Toán', '03/05', 'PRESENT', null),
  _ARecord('Vật lý', '06/05', 'LATE', 'Muộn 5 phút'),
  _ARecord('Ngữ văn', '08/05', 'ABSENT_EXCUSED', 'Đám tang ông'),
  _ARecord('Sinh học', '12/05', 'PRESENT', null),
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
  _ARecord('Sinh học', '19/05', 'LATE', 'Muộn 10 phút'),
  _ARecord('Toán', '20/05', 'ABSENT_EXCUSED', 'Có đơn xin nghỉ ốm'),
];

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chuyên cần'),
          backgroundColor: AppColors.studentAccent,
          actions: const [_NotiAction()],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tuần này'),
              Tab(text: 'Tháng này'),
              Tab(text: 'Học kỳ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AttendanceRange(records: _attWeek, rangeLabel: 'tuần này'),
            _AttendanceRange(records: _attMonth, rangeLabel: 'tháng này'),
            _AttendanceRange(records: _attSemester, rangeLabel: 'học kỳ'),
          ],
        ),
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
                    ),
                  ),
                ),
                leading: const Icon(Icons.schedule_rounded,
                    color: AppColors.textSecondary, size: 20),
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
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            )),
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
                        color: colors[i]),
                  ),
                  const SizedBox(height: 2),
                  Text(entry.key,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
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
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
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
                  backgroundColor: _color.withOpacity(0.18),
                  strokeWidth: 5,
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
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
                    backgroundColor: AppColors.studentAccent.withOpacity(0.12),
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
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.studentAccent.withOpacity(0.1),
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
                  leading: const Icon(Icons.sports_basketball_rounded,
                      color: AppColors.studentAccent),
                  title: const Text('Khóa ngoại khóa'),
                  subtitle: const Text('Xem & đăng ký khóa mới',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StudentExtracurricularPage(),
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
                        items: mockNotifications,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.studentAccent),
                  title: const Text('Tin nhắn'),
                  subtitle: const Text('Chat với GV bộ môn',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mở danh sách chat'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status,
    this.score,
    this.feedback,
  });
  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String status; // PENDING / SUBMITTED / LATE / GRADED
  final double? score;
  final String? feedback;
}

const _assignments = <_Assignment>[
  _Assignment(
    title: 'Bài tập Hàm số bậc hai',
    subject: 'Toán',
    teacher: 'Trần Thị Hoa',
    deadline: '28/05 23:59',
    status: 'PENDING',
  ),
  _Assignment(
    title: 'Thí nghiệm con lắc đơn',
    subject: 'Vật lý',
    teacher: 'Lê Văn Minh',
    deadline: '30/05 23:59',
    status: 'PENDING',
  ),
  _Assignment(
    title: 'Tập làm văn — Tả mẹ',
    subject: 'Ngữ văn',
    teacher: 'Nguyễn Thị Hồng',
    deadline: '25/05 23:59',
    status: 'SUBMITTED',
  ),
  _Assignment(
    title: 'Bài luận — My favorite hobby',
    subject: 'Tiếng Anh',
    teacher: 'Phạm Quốc Bảo',
    deadline: '20/05 23:59',
    status: 'GRADED',
    score: 8.5,
    feedback: 'Bài viết tốt, có ý sáng tạo. Cần lưu ý ngữ pháp ở đoạn 2.',
  ),
  _Assignment(
    title: 'Vẽ chu trình tế bào',
    subject: 'Sinh học',
    teacher: 'Trần Thị Bình',
    deadline: '18/05 23:59',
    status: 'GRADED',
    score: 9.0,
    feedback: 'Hình vẽ chi tiết, chú thích đầy đủ. Rất tốt!',
  ),
];

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    final pending =
        _assignments.where((a) => a.status == 'PENDING').toList();
    final submitted = _assignments
        .where((a) => a.status == 'SUBMITTED' || a.status == 'LATE')
        .toList();
    final graded = _assignments.where((a) => a.status == 'GRADED').toList();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài tập'),
          backgroundColor: AppColors.studentAccent,
          actions: const [_NotiAction()],
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tất cả (${_assignments.length})'),
              Tab(text: 'Chưa nộp (${pending.length})'),
              Tab(text: 'Đã nộp (${submitted.length})'),
              Tab(text: 'Đã chấm (${graded.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AssignmentList(items: _assignments),
            _AssignmentList(items: pending),
            _AssignmentList(items: submitted),
            _AssignmentList(items: graded),
          ],
        ),
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList({required this.items});
  final List<_Assignment> items;

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
      return const Center(
          child: Text('Không có bài tập',
              style: TextStyle(color: AppColors.textSecondary)));
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StudentAssignmentDetail(
                  title: a.title,
                  subject: a.subject,
                  teacher: a.teacher,
                  deadline: a.deadline,
                  status: a.status,
                  score: a.score,
                  feedback: a.feedback,
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
                              AppColors.studentAccent.withOpacity(0.08),
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
                      const Icon(Icons.person_outline_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(a.teacher,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(a.deadline,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
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
    final unreadCount =
        mockNotifications.where((n) => !n.read).length;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationCenter(
                  accent: AppColors.studentAccent,
                  items: mockNotifications,
                ),
              ),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 14),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
