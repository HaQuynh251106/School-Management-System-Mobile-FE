import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
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
        indicatorColor: AppColors.teacherAccent.withValues(alpha: 0.15),
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
            selectedIcon:
                Icon(Icons.assignment_rounded, color: AppColors.teacherAccent),
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

class _TimetableTab extends StatefulWidget {
  const _TimetableTab();
  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab> {
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _dayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  late final Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().myTimetable();

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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Lỗi tải TKB: ${snap.error}',
                    style: const TextStyle(color: AppColors.textSecondary)),
              );
            }
            final all = snap.data ?? [];
            return TabBarView(
              children: List.generate(_days.length, (dayIdx) {
                final slots = all
                    .where((s) => s['dayOfWeek'] == _dayCodes[dayIdx])
                    .toList()
                  ..sort((a, b) =>
                      (a['periodNo'] as int).compareTo(b['periodNo'] as int));
                if (slots.isEmpty) {
                  return const Center(
                    child: Text('Không có tiết dạy',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  itemBuilder: (_, i) {
                    final s = slots[i];
                    return _SlotCard(
                      _Slot(
                        (s['subjectName'] ?? '').toString(),
                        'Tiết ${s['periodNo']}',
                        (s['classId'] ?? '').toString(),
                        (s['roomCode'] ?? '').toString(),
                        '${s['startTime'] ?? ''}–${s['endTime'] ?? ''}',
                      ),
                      _dayLabels[dayIdx],
                    );
                  },
                );
              }),
            );
          },
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
                                fontSize: 12, color: AppColors.textSecondary)),
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
  final _api = sl<ApiService>();
  late final Future<List<Map<String, dynamic>>> _slotsFuture =
      _api.myTimetable();
  String? _slotId;
  Map<String, dynamic>? _slot;
  List<Map<String, dynamic>> _students = [];
  final Map<String, String> _status = {};
  bool _loadingStudents = false;
  bool _submitting = false;

  String _dayVi(String? code) =>
      const {
        'MON': 'T2',
        'TUE': 'T3',
        'WED': 'T4',
        'THU': 'T5',
        'FRI': 'T6',
        'SAT': 'T7'
      }[code] ??
      (code ?? '');

  Future<void> _selectSlot(
      String? slotId, List<Map<String, dynamic>> slots) async {
    if (slotId == null) return;
    final slot = slots.firstWhere((s) => s['id'] == slotId);
    setState(() {
      _slotId = slotId;
      _slot = slot;
      _loadingStudents = true;
      _students = [];
    });
    try {
      final st = await _api.classStudents(slot['classId'].toString());
      if (!mounted) return;
      setState(() {
        _students = st;
        _status
          ..clear()
          ..addEntries(st.map((s) => MapEntry(s['id'] as String, 'PRESENT')));
        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải HS: $e')));
    }
  }

  Future<void> _submit() async {
    if (_slotId == null) return;
    setState(() => _submitting = true);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final marks = _students
        .map((s) =>
            {'studentId': s['id'], 'status': _status[s['id']] ?? 'PRESENT'})
        .toList();
    try {
      await _api.bulkAttendance(slotId: _slotId!, date: date, marks: marks);
      final absent = _status.values.where((v) => v != 'PRESENT').length;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Đã lưu điểm danh. $absent vắng/muộn → đã gửi cảnh báo phụ huynh.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(DateTime.now());
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _slotsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final slots = snap.data ?? [];
        return Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: DropdownButtonFormField<String>(
                initialValue: _slotId,
                isExpanded: true,
                isDense: true,
                decoration: const InputDecoration(
                    labelText: 'Chọn tiết', isDense: true),
                items: slots
                    .map((s) => DropdownMenuItem(
                          value: s['id'] as String,
                          child: Text(
                            '${_dayVi(s['dayOfWeek'] as String?)} · Tiết ${s['periodNo']} · ${s['subjectName']} · ${s['classId']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => _selectSlot(v, slots),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.06),
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
                  if (_students.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        for (final s in _students) {
                          _status[s['id'] as String] = 'PRESENT';
                        }
                      }),
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
              child: _slotId == null
                  ? const Center(
                      child: Text('Chọn một tiết để điểm danh',
                          style: TextStyle(color: AppColors.textSecondary)))
                  : _loadingStudents
                      ? const Center(child: CircularProgressIndicator())
                      : _students.isEmpty
                          ? const Center(
                              child: Text('Lớp chưa có học sinh',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)))
                          : ListView.separated(
                              itemCount: _students.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 0),
                              itemBuilder: (_, i) {
                                final s = _students[i];
                                final id = s['id'] as String;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.teacherAccent
                                        .withValues(alpha: 0.12),
                                    radius: 18,
                                    child: Text('${i + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppColors.teacherAccent)),
                                  ),
                                  title: Text(s['fullName']?.toString() ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                  trailing: _StatusSelector(
                                    value: _status[id] ?? 'PRESENT',
                                    onChanged: (v) =>
                                        setState(() => _status[id] = v),
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
                    onPressed:
                        (_slotId == null || _submitting) ? null : _submit,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teacherAccent),
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_submitting ? 'Đang lưu...' : 'Lưu điểm danh'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                      color: AppColors.teacherAccent.withValues(alpha: 0.08),
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
                                  fontSize: 9, color: AppColors.teacherAccent)),
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
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: absent == 0
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12),
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
  _StudentGrade(this.studentId, this.name, this.scores);
  final String studentId;
  final String name;
  final List<double?> scores; // [Miệng, 15p, GK, CK] => ORAL/15M/MID/FINAL
}

/// Mã loại điểm tương ứng 4 cột Miệng / 15p / GK / CK.
const _gradeCategoryCodes = ['ORAL', '15M', 'MID', 'FINAL'];
const _gradeColumnLabels = ['Miệng', '15p', 'GK', 'CK'];

class _GradeBookView extends StatefulWidget {
  const _GradeBookView();
  @override
  State<_GradeBookView> createState() => _GradeBookViewState();
}

class _GradeBookViewState extends State<_GradeBookView> {
  final _api = sl<ApiService>();

  // Danh mục lấy từ API (mỗi phần tử là JSON {id, code, name, ...}).
  late final Future<void> _initFuture = _loadStructure();
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _semesters = [];

  String? _classId;
  String? _subjectId;
  String? _semesterId;

  List<_StudentGrade> _grades = [];
  bool _loadingGrades = false;
  String? _gradesError;

  Future<void> _loadStructure() async {
    final results = await Future.wait([
      _api.classes(),
      _api.subjects(),
      _api.semesters(),
    ]);
    _classes = results[0];
    _subjects = results[1];
    _semesters = results[2];
    if (_classes.isNotEmpty) _classId = _classes.first['id']?.toString();
    if (_subjects.isNotEmpty) _subjectId = _subjects.first['id']?.toString();
    if (_semesters.isNotEmpty) {
      _semesterId = _semesters.first['id']?.toString();
    }
    // Tải bảng điểm cho lựa chọn mặc định ngay trong future khởi tạo
    // (không gọi setState ở đây vì widget chưa build lần đầu).
    try {
      _grades = await _fetchGrades();
    } catch (e) {
      _gradesError = '$e';
    }
  }

  /// Tải HS + điểm cho lựa chọn hiện tại và gom thành danh sách _StudentGrade.
  Future<List<_StudentGrade>> _fetchGrades() async {
    final classId = _classId;
    final subjectId = _subjectId;
    final semesterId = _semesterId;
    if (classId == null || subjectId == null || semesterId == null) {
      return const [];
    }
    final results = await Future.wait([
      _api.classStudents(classId),
      _api.grades(
          classId: classId, subjectId: subjectId, semesterId: semesterId),
    ]);
    final students = results[0];
    final gradeRows = results[1];
    // Gom điểm theo studentId -> {category: score}.
    final byStudent = <String, Map<String, double>>{};
    for (final row in gradeRows) {
      final sid = row['studentId']?.toString();
      final cat = row['category']?.toString();
      final raw = row['score'];
      if (sid == null || cat == null || raw is! num) continue;
      (byStudent[sid] ??= {})[cat] = raw.toDouble();
    }
    return students.map((s) {
      final sid = s['id']?.toString() ?? '';
      final scoresByCat = byStudent[sid] ?? const {};
      final scores = _gradeCategoryCodes
          .map((code) => scoresByCat[code])
          .toList(growable: false);
      return _StudentGrade(
          sid, s['fullName']?.toString() ?? '', List<double?>.from(scores));
    }).toList();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _loadingGrades = true;
      _gradesError = null;
    });
    try {
      final list = await _fetchGrades();
      if (!mounted) return;
      setState(() {
        _grades = list;
        _loadingGrades = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gradesError = '$e';
        _loadingGrades = false;
      });
    }
  }

  Color _scoreColor(double s) {
    if (s >= 8) return AppColors.success;
    if (s >= 6.5) return AppColors.warning;
    if (s >= 5) return AppColors.late;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Lỗi tải dữ liệu: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        return Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _classId,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Lớp', isDense: true),
                      items: _classes
                          .map((c) => DropdownMenuItem(
                                value: c['id']?.toString(),
                                child: Text(
                                  (c['code'] ?? c['name'] ?? '').toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _classId = v);
                        _loadGrades();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _subjectId,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Môn', isDense: true),
                      items: _subjects
                          .map((c) => DropdownMenuItem(
                                value: c['id']?.toString(),
                                child: Text(
                                  (c['name'] ?? c['code'] ?? '').toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _subjectId = v);
                        _loadGrades();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _semesterId,
                      isDense: true,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'HK', isDense: true),
                      items: _semesters
                          .map((c) => DropdownMenuItem(
                                value: c['id']?.toString(),
                                child: Text(
                                  (c['code'] ?? c['name'] ?? '').toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _semesterId = v);
                        _loadGrades();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingGrades) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_gradesError != null) {
      return Center(
        child: Text('Lỗi tải điểm: $_gradesError',
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    if (_grades.isEmpty) {
      return const Center(
        child: Text('Lớp chưa có học sinh',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
              AppColors.teacherAccent.withValues(alpha: 0.08)),
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
    );
  }

  Future<void> _editScore(_StudentGrade g, int index) async {
    final subjectId = _subjectId;
    final semesterId = _semesterId;
    if (subjectId == null || semesterId == null) return;
    final ctrl =
        TextEditingController(text: g.scores[index]?.toStringAsFixed(1) ?? '');
    final reasonCtrl = TextEditingController();
    final isEdit = g.scores[index] != null;
    final result = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_gradeColumnLabels[index]} — ${g.name}'),
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
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.teacherAccent),
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v == null || v < 0 || v > 10) return;
              if (isEdit && reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do sửa điểm')),
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
    final reason = reasonCtrl.text.trim();
    try {
      await _api.bulkGrades(
        subjectId: subjectId,
        semesterId: semesterId,
        category: _gradeCategoryCodes[index],
        reason: reason.isEmpty ? null : reason,
        entries: [
          {'studentId': g.studentId, 'score': result},
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isEdit ? 'Đã sửa điểm, đã ghi log.' : 'Đã lưu điểm mới.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadGrades();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Lỗi lưu điểm: $e'),
            backgroundColor: AppColors.error),
      );
    }
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
            color: AppColors.teacherAccent.withValues(alpha: 0.08),
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
                        child: Text(r.$1, style: const TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: r.$2 / total,
                            color: r.$3,
                            backgroundColor: r.$3.withValues(alpha: 0.15),
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
        const Card(
          child: Column(
            children: [
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
        backgroundColor: _rankColor.withValues(alpha: 0.15),
        child: Text('$rank',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _rankColor, fontSize: 12)),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
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
                            .withValues(alpha: 0.1),
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
                            color: up ? AppColors.success : AppColors.error,
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
                                fontSize: 12, fontStyle: FontStyle.italic)),
                      ),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
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
                        AppColors.teacherAccent.withValues(alpha: 0.15),
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
                  leading:
                      Icon(Icons.class_rounded, color: AppColors.teacherAccent),
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
                      builder: (_) => const ChatListPage(
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

class _AssignmentsTab extends StatefulWidget {
  const _AssignmentsTab();
  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab> {
  late final Future<List<_TAssignment>> _future = _load();

  Future<List<_TAssignment>> _load() async {
    final raw = await sl<ApiService>().teacherAssignments();
    return raw.map(_mapAssignment).toList();
  }

  _TAssignment _mapAssignment(Map<String, dynamic> a) {
    final rawDeadline = a['deadline'];
    String deadline = '—';
    if (rawDeadline != null && rawDeadline.toString().isNotEmpty) {
      final dt = DateTime.tryParse(rawDeadline.toString());
      deadline = dt != null
          ? DateFormat('dd/MM HH:mm').format(dt.toLocal())
          : rawDeadline.toString();
    }
    return _TAssignment(
      title: (a['title'] ?? '').toString(),
      subject: (a['subjectName'] ?? '').toString(),
      className: (a['classId'] ?? '').toString(),
      deadline: deadline,
      status: (a['status'] ?? 'DRAFT').toString(),
      submitted: 0,
      total: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_TAssignment>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bài tập'),
              backgroundColor: AppColors.teacherAccent,
              actions: const [_ChatAction(), _NotiAction()],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bài tập'),
              backgroundColor: AppColors.teacherAccent,
              actions: const [_ChatAction(), _NotiAction()],
            ),
            body: Center(
              child: Text('Lỗi tải bài tập: ${snap.error}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }
        final all = snap.data ?? const <_TAssignment>[];
        final drafts = all.where((a) => a.status == 'DRAFT').toList();
        final published = all.where((a) => a.status == 'PUBLISHED').toList();
        final closed = all.where((a) => a.status == 'CLOSED').toList();
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
      },
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
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
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
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
                              content: Text(
                                  'Đã phát hành. Học sinh nhận thông báo.'),
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
                          color:
                              AppColors.teacherAccent.withValues(alpha: 0.08),
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
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (!isDraft && a.total > 0) ...[
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
    return const LiveNotificationAction(accent: AppColors.teacherAccent);
  }
}

class _ChatAction extends StatelessWidget {
  const _ChatAction();

  @override
  Widget build(BuildContext context) {
    final unread = _teacherThreads.fold<int>(0, (s, t) => s + t.unread);
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
