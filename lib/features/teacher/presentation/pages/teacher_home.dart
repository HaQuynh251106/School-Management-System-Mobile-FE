import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'assignment_grading.dart';
import 'attendance_session_detail.dart';
import 'class_slot_detail.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          _TimetableTab(),
          _AttendanceTab(),
          _GradesTab(),
          _AssignmentsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppColors.teacherAccent.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded,
                color: AppColors.teacherAccent),
            label: 'TKB',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon:
                Icon(Icons.fact_check_rounded, color: AppColors.teacherAccent),
            label: 'Điểm danh',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon:
                Icon(Icons.grade_rounded, color: AppColors.teacherAccent),
            label: 'Điểm số',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded,
                color: AppColors.teacherAccent),
            label: 'Bài tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppColors.teacherAccent),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}

// ===================== TIMETABLE =====================

class _Slot {
  const _Slot(this.subject, this.period, this.className, this.room, this.time);
  final String subject;
  final String period;
  final String className;
  final String room;
  final String time;
}

const _teacherSlots = <int, List<_Slot>>{
  0: [
    _Slot('Toán', 'Tiết 1', '10A1', 'P201', '07:00–07:45'),
    _Slot('Ngữ văn', 'Tiết 3', '10A1', 'P201', '08:45–09:30'),
    _Slot('Toán', 'Tiết 4', '8A1', 'P105', '09:35–10:20'),
  ],
  1: [
    _Slot('Sinh học', 'Tiết 2', '10A1', 'P201', '07:50–08:35'),
    _Slot('Toán', 'Tiết 4', '10A2', 'P202', '09:35–10:20'),
  ],
  2: [
    _Slot('Toán', 'Tiết 1', '10A1', 'P201', '07:00–07:45'),
    _Slot('Toán', 'Tiết 3', '10A2', 'P202', '08:45–09:30'),
  ],
  3: [
    _Slot('Toán', 'Tiết 2', '8A1', 'P105', '07:50–08:35'),
  ],
  4: [
    _Slot('Toán', 'Tiết 1', '10A1', 'P201', '07:00–07:45'),
    _Slot('Toán', 'Tiết 2', '10A2', 'P202', '07:50–08:35'),
  ],
};

const _dayLabels = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
];

class _TimetableTab extends StatelessWidget {
  const _TimetableTab();

  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    final initial = (DateTime.now().weekday - 1).clamp(0, 5);
    return DefaultTabController(
      length: _days.length,
      initialIndex: initial,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thời khóa biểu'),
          backgroundColor: AppColors.teacherAccent,
          actions: const [_ChatAction(), _NotiAction()],
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: _days.map((d) => Tab(text: d)).toList(),
          ),
        ),
        body: TabBarView(
          children: List.generate(_days.length, (dayIdx) {
            final slots = _teacherSlots[dayIdx] ?? [];
            if (slots.isEmpty) {
              return const Center(
                child: Text(
                  'Không có tiết dạy',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: slots.length,
              itemBuilder: (_, i) => _SlotCard(slots[i], _dayLabels[dayIdx]),
            );
          }),
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard(this.slot, this.dayLabel);
  final _Slot slot;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TeacherClassSlotDetail(
              subject: slot.subject,
              period: slot.period,
              className: slot.className,
              room: slot.room,
              time: slot.time,
              dayLabel: dayLabel,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.teacherAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(slot.subject,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const Spacer(),
                        Text(slot.time,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.period} • Lớp ${slot.className} • ${slot.room}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== ATTENDANCE (sub-tabs Hôm nay / Lịch sử) =====================

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Điểm danh'),
          backgroundColor: AppColors.teacherAccent,
          actions: const [_ChatAction(), _NotiAction()],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Hôm nay'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TodayAttendance(),
            _AttendanceHistory(),
          ],
        ),
      ),
    );
  }
}

class _TodayAttendance extends StatefulWidget {
  const _TodayAttendance();
  @override
  State<_TodayAttendance> createState() => _TodayAttendanceState();
}

class _TodayAttendanceState extends State<_TodayAttendance> {
  String _selectedClass = '10A1';
  int _selectedPeriod = 1;

  static const _students = [
    'Phạm Hoài An',
    'Nguyễn Minh Châu',
    'Trần Thị Dung',
    'Lê Quang Huy',
    'Võ Thị Kim',
    'Đỗ Văn Long',
    'Hoàng Thị Mai',
    'Bùi Ngọc Nam',
  ];

  late final Map<String, String> _status = {
    for (final s in _students) s: 'PRESENT'
  };

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(DateTime.now());
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Lớp',
                    isDense: true,
                  ),
                  items: ['10A1', '10A2', '8A1']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedPeriod,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Tiết',
                    isDense: true,
                  ),
                  items: [1, 2, 3, 4, 5]
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text('Tiết $p')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPeriod = v!),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.primary.withOpacity(0.06),
          child: Row(
            children: [
              const Icon(Icons.event_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(today,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton.icon(
                onPressed: _markAllPresent,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.done_all_rounded, size: 14),
                label: const Text('Tất cả có mặt',
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _students.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final name = _students[i];
              final s = _status[name]!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.teacherAccent.withOpacity(0.12),
                  radius: 18,
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
                trailing: _StatusSelector(
                  value: s,
                  onChanged: (v) => setState(() => _status[name] = v),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teacherAccent,
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text('Lưu điểm danh'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _markAllPresent() {
    setState(() {
      for (final s in _students) {
        _status[s] = 'PRESENT';
      }
    });
  }

  void _submit() {
    final absent = _status.entries.where((e) => e.value != 'PRESENT').length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã lưu điểm danh. ${_students.length - absent} có mặt, $absent vắng/muộn.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('PRESENT', 'Có mặt', AppColors.present),
    ('ABSENT_EXCUSED', 'Vắng phép', AppColors.absentExcused),
    ('ABSENT_UNEXCUSED', 'Vắng KP', AppColors.absentUnexcused),
    ('LATE', 'Muộn', AppColors.late),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      child: AttendanceBadge(value),
      itemBuilder: (_) => _options
          .map((o) => PopupMenuItem(
                value: o.$1,
                child: Row(
                  children: [
                    Icon(Icons.circle, color: o.$3, size: 10),
                    const SizedBox(width: 8),
                    Text(o.$2),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _AttendanceHistory extends StatelessWidget {
  const _AttendanceHistory();

  static const _sessions = [
    ('10A1', 'Toán', '21/05', 'Tiết 1', 30, 2),
    ('10A2', 'Toán', '21/05', 'Tiết 2', 32, 0),
    ('10A1', 'Toán', '20/05', 'Tiết 1', 30, 3),
    ('8A1', 'Toán', '20/05', 'Tiết 4', 28, 1),
    ('10A1', 'Toán', '19/05', 'Tiết 1', 30, 1),
    ('10A2', 'Toán', '19/05', 'Tiết 3', 32, 4),
    ('10A1', 'Ngữ văn', '19/05', 'Tiết 3', 30, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final (cls, subj, date, period, total, absent) = _sessions[i];
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TeacherAttendanceSessionDetail(
                  className: cls,
                  subject: subj,
                  date: date,
                  period: period,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.teacherAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(date.split('/').first,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.teacherAccent)),
                          Text(date.split('/').last,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.teacherAccent)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('$cls — $subj',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(period,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: absent == 0
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      absent == 0 ? 'Đủ' : '$absent vắng',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: absent == 0
                              ? AppColors.success
                              : AppColors.warning),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===================== GRADES (sub-tabs Bảng điểm / Phổ điểm / Log) =====================

class _GradesTab extends StatelessWidget {
  const _GradesTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Điểm số'),
          backgroundColor: AppColors.teacherAccent,
          actions: const [_ChatAction(), _NotiAction()],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Bảng điểm'),
              Tab(text: 'Phổ điểm'),
              Tab(text: 'Log sửa điểm'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GradeBookView(),
            _GradeDistributionView(),
            _GradeChangeLogView(),
          ],
        ),
      ),
    );
  }
}

class _StudentGrade {
  _StudentGrade(this.name, this.scores);
  final String name;
  final List<double?> scores; // [Miệng, 15p, GK, CK]
}

class _GradeBookView extends StatefulWidget {
  const _GradeBookView();
  @override
  State<_GradeBookView> createState() => _GradeBookViewState();
}

class _GradeBookViewState extends State<_GradeBookView> {
  String _class = '10A1';
  String _subject = 'Toán';
  String _semester = 'HK1';

  late final List<_StudentGrade> _grades = [
    _StudentGrade('Phạm Hoài An', [9.0, 8.5, 7.5, 8.8]),
    _StudentGrade('Nguyễn Minh Châu', [8.0, 9.0, 8.0, 8.5]),
    _StudentGrade('Trần Thị Dung', [7.0, 6.5, 7.0, 7.5]),
    _StudentGrade('Lê Quang Huy', [9.5, 9.0, 8.5, 9.0]),
    _StudentGrade('Võ Thị Kim', [6.0, 7.0, 6.5, 7.0]),
    _StudentGrade('Đỗ Văn Long', [8.0, 7.5, 8.0, null]),
    _StudentGrade('Hoàng Thị Mai', [9.0, null, 8.5, 9.0]),
    _StudentGrade('Bùi Ngọc Nam', [7.5, 8.0, 7.0, 7.5]),
  ];

  Color _scoreColor(double s) {
    if (s >= 8) return AppColors.success;
    if (s >= 6.5) return AppColors.warning;
    if (s >= 5) return AppColors.late;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _class,
                  isDense: true,
                  decoration: const InputDecoration(
                      labelText: 'Lớp', isDense: true),
                  items: ['10A1', '10A2', '8A1']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _class = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _subject,
                  isDense: true,
                  decoration: const InputDecoration(
                      labelText: 'Môn', isDense: true),
                  items: ['Toán', 'Ngữ văn', 'Sinh học']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _subject = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _semester,
                  isDense: true,
                  decoration: const InputDecoration(
                      labelText: 'HK', isDense: true),
                  items: ['HK1', 'HK2']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _semester = v!),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    AppColors.teacherAccent.withOpacity(0.08)),
                columns: const [
                  DataColumn(label: Text('Học sinh')),
                  DataColumn(label: Text('Miệng')),
                  DataColumn(label: Text('15p')),
                  DataColumn(label: Text('GK')),
                  DataColumn(label: Text('CK')),
                  DataColumn(label: Text('TB')),
                ],
                rows: _grades.map((g) {
                  final scores = g.scores;
                  const weights = [1, 1, 2, 3];
                  var sum = 0.0;
                  var sumW = 0;
                  for (var i = 0; i < scores.length; i++) {
                    if (scores[i] != null) {
                      sum += scores[i]! * weights[i];
                      sumW += weights[i];
                    }
                  }
                  final avg = sumW == 0 ? null : sum / sumW;
                  return DataRow(cells: [
                    DataCell(Text(g.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500))),
                    for (var i = 0; i < scores.length; i++)
                      DataCell(
                        InkWell(
                          onTap: () => _editScore(g, i),
                          child: SizedBox(
                            width: 40,
                            child: Text(
                              scores[i]?.toStringAsFixed(1) ?? '—',
                              style: TextStyle(
                                  color: scores[i] != null
                                      ? _scoreColor(scores[i]!)
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    DataCell(SizedBox(
                      width: 40,
                      child: Text(
                        avg?.toStringAsFixed(2) ?? '—',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: avg != null
                                ? _scoreColor(avg)
                                : AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editScore(_StudentGrade g, int index) async {
    const labels = ['Miệng', '15p', 'GK', 'CK'];
    final ctrl = TextEditingController(
        text: g.scores[index]?.toStringAsFixed(1) ?? '');
    final reasonCtrl = TextEditingController();
    final isEdit = g.scores[index] != null;
    final result = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${labels[index]} — ${g.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Điểm (0–10)',
                isDense: true,
              ),
              autofocus: true,
            ),
            if (isEdit) ...[
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lý do sửa (bắt buộc khi sửa)',
                  isDense: true,
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.teacherAccent),
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v == null || v < 0 || v > 10) return;
              if (isEdit && reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Vui lòng nhập lý do sửa điểm')),
                );
                return;
              }
              Navigator.pop(ctx, v);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => g.scores[index] = result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit
            ? 'Đã sửa điểm, đã ghi log.'
            : 'Đã lưu điểm mới.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GradeDistributionView extends StatelessWidget {
  const _GradeDistributionView();

  // mock distribution (count per range): <5, 5-6.5, 6.5-8, 8-10
  static const _ranges = [
    ('Yếu (<5)', 1, AppColors.error),
    ('TB (5–6.5)', 4, AppColors.late),
    ('Khá (6.5–8)', 10, AppColors.warning),
    ('Giỏi (8–10)', 15, AppColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _ranges.fold<int>(0, (s, r) => s + r.$2);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teacherAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.insights_rounded,
                  color: AppColors.teacherAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lớp 10A1 — Toán — HK1',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Tổng số HS: $total • TB lớp: 7.8',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Phân bố điểm trung bình'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final r in _ranges) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(r.$1,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: r.$2 / total,
                            color: r.$3,
                            backgroundColor: r.$3.withOpacity(0.15),
                            minHeight: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${r.$2}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: r.$3,
                              fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Top 5 HS điểm cao nhất'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              _TopStudentRow(rank: 1, name: 'Lê Quang Huy', avg: 9.05),
              Divider(height: 0),
              _TopStudentRow(rank: 2, name: 'Hoàng Thị Mai', avg: 8.85),
              Divider(height: 0),
              _TopStudentRow(rank: 3, name: 'Phạm Hoài An', avg: 8.40),
              Divider(height: 0),
              _TopStudentRow(rank: 4, name: 'Nguyễn Minh Châu', avg: 8.30),
              Divider(height: 0),
              _TopStudentRow(rank: 5, name: 'Bùi Ngọc Nam', avg: 7.60),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopStudentRow extends StatelessWidget {
  const _TopStudentRow(
      {required this.rank, required this.name, required this.avg});
  final int rank;
  final String name;
  final double avg;

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.teacherAccent;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: _rankColor.withOpacity(0.15),
        child: Text('$rank',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _rankColor,
                fontSize: 12)),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      trailing: Text(avg.toStringAsFixed(2),
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              fontSize: 14)),
    );
  }
}

class _GradeChangeLogView extends StatelessWidget {
  const _GradeChangeLogView();

  static const _logs = [
    (
      'Phạm Hoài An',
      'Toán — GK',
      8.5,
      9.0,
      'Cộng điểm bài tập thêm',
      '21/05 14:32',
    ),
    (
      'Trần Thị Dung',
      'Toán — 15p',
      7.5,
      6.5,
      'Phát hiện gian lận, hạ điểm',
      '20/05 16:10',
    ),
    (
      'Lê Quang Huy',
      'Toán — Miệng',
      9.0,
      9.5,
      'Bài kiểm tra bổ sung',
      '19/05 09:20',
    ),
    (
      'Nguyễn Minh Châu',
      'Ngữ văn — GK',
      7.5,
      8.0,
      'Chấm lại do nhầm phần A',
      '18/05 11:05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final (name, label, oldV, newV, reason, time) = _logs[i];
        final up = newV > oldV;
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (up ? AppColors.success : AppColors.error)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(oldV.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 4),
                          Icon(
                            up
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color:
                                up ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(newV.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: up
                                      ? AppColors.success
                                      : AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.format_quote_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(reason,
                            style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic)),
                      ),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        title: const Text('Thông tin'),
        backgroundColor: AppColors.teacherAccent,
        actions: const [_ChatAction(), _NotiAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppColors.teacherAccent.withOpacity(0.15),
                    child: Text(
                      user.fullName[0],
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teacherAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(user.mainSubject ?? 'Giáo viên',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.class_rounded,
                      color: AppColors.teacherAccent),
                  title: Text('Lớp chủ nhiệm'),
                  subtitle: Text('10A1'),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(Icons.menu_book_rounded,
                      color: AppColors.teacherAccent),
                  title: Text('Môn giảng dạy'),
                  subtitle: Text('Toán • 4 lớp'),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.teacherAccent),
                  title: const Text('Tin nhắn'),
                  subtitle: const Text('Chat HS / PH + Broadcast lớp',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatListPage(
                        accent: AppColors.teacherAccent,
                        allowBroadcast: true,
                        threads: _teacherThreads,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined,
                      color: AppColors.teacherAccent),
                  title: const Text('Thông báo'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenter(
                        accent: AppColors.teacherAccent,
                        items: mockNotifications,
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

class _TAssignment {
  const _TAssignment({
    required this.title,
    required this.subject,
    required this.className,
    required this.deadline,
    required this.status,
    required this.submitted,
    required this.total,
  });
  final String title;
  final String subject;
  final String className;
  final String deadline;
  final String status; // DRAFT / PUBLISHED / CLOSED
  final int submitted;
  final int total;
}

const _teacherAssignments = <_TAssignment>[
  _TAssignment(
    title: 'Bài tập Hàm số bậc hai',
    subject: 'Toán',
    className: '10A1',
    deadline: '28/05 23:59',
    status: 'PUBLISHED',
    submitted: 18,
    total: 38,
  ),
  _TAssignment(
    title: 'Đề ôn tập GK',
    subject: 'Toán',
    className: '10A2',
    deadline: '02/06 23:59',
    status: 'PUBLISHED',
    submitted: 5,
    total: 40,
  ),
  _TAssignment(
    title: 'Bài tập Phép tính ma trận',
    subject: 'Toán',
    className: '10A1',
    deadline: '10/06 23:59',
    status: 'DRAFT',
    submitted: 0,
    total: 38,
  ),
  _TAssignment(
    title: 'Bài tập Chương 1 — Đại số',
    subject: 'Toán',
    className: '10A1',
    deadline: '15/04 23:59',
    status: 'CLOSED',
    submitted: 36,
    total: 38,
  ),
  _TAssignment(
    title: 'Bài tập Chương 2 — Hình học',
    subject: 'Toán',
    className: '8A1',
    deadline: '20/04 23:59',
    status: 'CLOSED',
    submitted: 32,
    total: 35,
  ),
];

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    final drafts = _teacherAssignments
        .where((a) => a.status == 'DRAFT')
        .toList();
    final published = _teacherAssignments
        .where((a) => a.status == 'PUBLISHED')
        .toList();
    final closed = _teacherAssignments
        .where((a) => a.status == 'CLOSED')
        .toList();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài tập'),
          backgroundColor: AppColors.teacherAccent,
          actions: const [_ChatAction(), _NotiAction()],
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Đã phát hành (${published.length})'),
              Tab(text: 'Bản nháp (${drafts.length})'),
              Tab(text: 'Đã đóng (${closed.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateSheet(context),
          backgroundColor: AppColors.teacherAccent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tạo bài'),
        ),
        body: TabBarView(
          children: [
            _TAssignmentList(items: published),
            _TAssignmentList(items: drafts, isDraft: true),
            _TAssignmentList(items: closed, isClosed: true),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    String cls = '10A1';
    String subj = 'Toán';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tạo bài tập mới',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: cls,
                        decoration: const InputDecoration(
                            labelText: 'Lớp', isDense: true),
                        items: ['10A1', '10A2', '8A1']
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => cls = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: subj,
                        decoration: const InputDecoration(
                            labelText: 'Môn', isDense: true),
                        items: ['Toán', 'Vật lý', 'Hoá học']
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => subj = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Mô tả đề bài',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.event_rounded, size: 16),
                        label: const Text('Deadline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.attach_file_rounded, size: 16),
                        label: const Text('Đính kèm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Lưu nháp'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Đã phát hành. Học sinh nhận thông báo.'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teacherAccent),
                        child: const Text('Phát hành'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TAssignmentList extends StatelessWidget {
  const _TAssignmentList({
    required this.items,
    this.isDraft = false,
    this.isClosed = false,
  });
  final List<_TAssignment> items;
  final bool isDraft;
  final bool isClosed;

  Color _statusColor(String s) => switch (s) {
        'DRAFT' => AppColors.textSecondary,
        'CLOSED' => AppColors.primary,
        _ => AppColors.success,
      };

  String _statusLabel(String s) => switch (s) {
        'DRAFT' => 'Bản nháp',
        'CLOSED' => 'Đã đóng',
        _ => 'Đã phát hành',
      };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child: Text('Không có bài tập',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = items[i];
        final color = _statusColor(a.status);
        final pct = a.total == 0 ? 0.0 : a.submitted / a.total;
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isDraft) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mở form chỉnh sửa bản nháp'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TeacherAssignmentGrading(
                    assignmentTitle: a.title,
                    subject: a.subject,
                    className: a.className,
                    deadline: a.deadline,
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
                          color: AppColors.teacherAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${a.className} • ${a.subject}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teacherAccent)),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Hạn: ${a.deadline}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  if (!isDraft) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              color: AppColors.teacherAccent,
                              backgroundColor: AppColors.divider,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${a.submitted}/${a.total}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.teacherAccent)),
                      ],
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

// ===================== ACTIONS & MOCK =====================

const _teacherThreads = <ChatThread>[
  ChatThread(
    name: 'Phạm Văn Quân',
    role: 'PH em An (10A1)',
    lastMessage: 'Dạ vâng, em cảm ơn cô.',
    lastTime: '08:33',
    unread: 0,
  ),
  ChatThread(
    name: 'Nguyễn Văn Đức',
    role: 'PH em Châu (10A1)',
    lastMessage: 'Tối nay em rảnh, cô có thể gọi không ạ?',
    lastTime: 'Hôm qua',
    unread: 2,
  ),
  ChatThread(
    name: 'Phạm Hoài An',
    role: 'HS lớp 10A1',
    lastMessage: 'Cô ơi, em chưa hiểu bài 3...',
    lastTime: '2 ngày trước',
    unread: 1,
  ),
  ChatThread(
    name: 'Lớp 10A1',
    role: '38 thành viên',
    lastMessage: 'Cô gửi bài tập về nhà chương 3 nhé!',
    lastTime: 'Hôm qua',
    unread: 0,
    isBroadcast: true,
  ),
  ChatThread(
    name: 'Lớp 10A2',
    role: '40 thành viên',
    lastMessage: 'Mai kiểm tra 15 phút, các em ôn bài kỹ.',
    lastTime: '3 ngày trước',
    unread: 0,
    isBroadcast: true,
  ),
];

class _NotiAction extends StatelessWidget {
  const _NotiAction();

  @override
  Widget build(BuildContext context) {
    final unread = mockNotifications.where((n) => !n.read).length;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationCenter(
                  accent: AppColors.teacherAccent,
                  items: mockNotifications,
                ),
              ),
            ),
          ),
          if (unread > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 14),
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatAction extends StatelessWidget {
  const _ChatAction();

  @override
  Widget build(BuildContext context) {
    final unread =
        _teacherThreads.fold<int>(0, (s, t) => s + t.unread);
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChatListPage(
                  accent: AppColors.teacherAccent,
                  allowBroadcast: true,
                  threads: _teacherThreads,
                ),
              ),
            ),
          ),
          if (unread > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 14),
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
