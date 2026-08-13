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
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/quick_create.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../../shared/widgets/school_day_status.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'assignment_grading.dart';
import 'attendance_session_detail.dart';
import 'class_slot_detail.dart';
import 'exam_grading_page.dart';
import 'homeroom_year_end_page.dart';
import 'teacher_progress_page.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveRoleScaffold(
      index: _tab,
      onSelected: (i) => setState(() => _tab = i),
      accent: AppColors.teacherAccent,
      floatingActionButton: _tab == 0
          ? const QuickCreateButton(
              role: 'TEACHER',
              accent: AppColors.teacherAccent,
            )
          : null,
      pages: const [
        _TimetableTab(),
        _AttendanceTab(),
        _GradesTab(),
        _AssignmentsTab(),
        _ProfileTab(),
      ],
      destinations: const [
        RoleDestination(
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today_rounded,
          label: 'Lịch dạy',
        ),
        RoleDestination(
          icon: Icons.fact_check_outlined,
          selectedIcon: Icons.fact_check_rounded,
          label: 'Điểm danh',
        ),
        RoleDestination(
          icon: Icons.grade_outlined,
          selectedIcon: Icons.grade_rounded,
          label: 'Bảng điểm',
        ),
        RoleDestination(
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
          label: 'Bài tập',
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
  3: [_Slot('Toán', 'Tiết 2', '8A1', 'P105', '07:50–08:35')],
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
  late final List<DateTime> _weekDates = schoolWeekDates(DateTime.now());
  late final Future<_TeacherTimetableData> _future = _load();

  Future<_TeacherTimetableData> _load() async {
    final api = sl<ApiService>();
    final timetable = api.myTimetable();
    final statuses = loadSchoolWeekStatuses(api, _weekDates);
    return _TeacherTimetableData(
      timetable: await timetable,
      statuses: await statuses,
    );
  }

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
        body: FutureBuilder<_TeacherTimetableData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Lỗi tải TKB: ${snap.error}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final data = snap.data!;
            final all = data.timetable;
            return TabBarView(
              children: List.generate(_days.length, (dayIdx) {
                final status = data.statuses[dayIdx];
                final slots =
                    all
                        .where((s) => s['dayOfWeek'] == _dayCodes[dayIdx])
                        .toList()
                      ..sort(
                        (a, b) => (a['periodNo'] as int).compareTo(
                          b['periodNo'] as int,
                        ),
                      );
                if (status.isHoliday) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SchoolHolidayBanner(
                        status: status,
                        accent: AppColors.teacherAccent,
                      ),
                    ],
                  );
                }
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
                  itemCount: slots.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return RolePageIntro(
                        title: 'Lịch dạy trong ngày',
                        subtitle:
                            '${_dayLabels[dayIdx]} có ${slots.length} tiết. Điểm danh đúng giờ và theo dõi công việc cần xử lý.',
                        accent: AppColors.teacherAccent,
                        icon: Icons.co_present_rounded,
                        badges: [
                          '${slots.length} tiết dạy',
                          '${slots.map((slot) => slot['classId']).toSet().length} lớp',
                        ],
                      );
                    }
                    final s = slots[i - 1];
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

class _TeacherTimetableData {
  const _TeacherTimetableData({
    required this.timetable,
    required this.statuses,
  });

  final List<Map<String, dynamic>> timetable;
  final List<SchoolDayStatus> statuses;
}

class TeacherScopeSummary {
  const TeacherScopeSummary({
    required this.homeroomClassCodes,
    required this.teachingClassCodes,
    required this.subjectNames,
  });

  final List<String> homeroomClassCodes;
  final List<String> teachingClassCodes;
  final List<String> subjectNames;

  factory TeacherScopeSummary.fromApi({
    required String teacherId,
    required List<Map<String, dynamic>> classes,
    required List<Map<String, dynamic>> assignments,
  }) {
    String value(Map<String, dynamic> row, String preferred, String fallback) =>
        (row[preferred] ?? row[fallback] ?? '').toString().trim();
    final homeroomCodes = <String>{
      for (final schoolClass in classes)
        if ('${schoolClass['homeroomTeacherId']}' == teacherId &&
            value(schoolClass, 'code', 'id').isNotEmpty)
          value(schoolClass, 'code', 'id'),
    };
    final teachingCodes = <String>{
      for (final assignment in assignments)
        if (value(assignment, 'classCode', 'classId').isNotEmpty)
          value(assignment, 'classCode', 'classId'),
    };
    final subjects = <String>{
      for (final assignment in assignments)
        if (value(assignment, 'subjectName', 'subjectId').isNotEmpty)
          value(assignment, 'subjectName', 'subjectId'),
    };
    return TeacherScopeSummary(
      homeroomClassCodes: homeroomCodes.toList(),
      teachingClassCodes: teachingCodes.toList(),
      subjectNames: subjects.toList(),
    );
  }

  String get homeroomLabel => homeroomClassCodes.isEmpty
      ? 'Chưa được phân công'
      : homeroomClassCodes.join(', ');

  String get teachingLabel => teachingClassCodes.isEmpty
      ? 'Chưa được phân công giảng dạy'
      : '${subjectNames.join(', ')} • ${teachingClassCodes.length} lớp';
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
                        Text(
                          slot.subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          slot.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.period} • Lớp ${slot.className} • ${slot.room}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
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
          children: [_TodayAttendance(), _AttendanceHistory()],
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
  late final Future<List<Map<String, dynamic>>> _slotsFuture = _api
      .myTimetable();
  String? _slotId;
  Map<String, dynamic>? _slot;
  List<Map<String, dynamic>> _students = [];
  final Map<String, String> _status = {};
  final Map<String, String> _notes = {};
  Map<String, dynamic>? _sessionStatus;
  bool _loadingStudents = false;
  bool _submitting = false;

  String _dayVi(String? code) =>
      const {
        'MON': 'T2',
        'TUE': 'T3',
        'WED': 'T4',
        'THU': 'T5',
        'FRI': 'T6',
        'SAT': 'T7',
      }[code] ??
      (code ?? '');

  Future<void> _selectSlot(
    String? slotId,
    List<Map<String, dynamic>> slots,
  ) async {
    if (slotId == null) return;
    final slot = slots.firstWhere((s) => s['id'] == slotId);
    setState(() {
      _slotId = slotId;
      _slot = slot;
      _loadingStudents = true;
      _students = [];
    });
    try {
      final date = DateTime.now();
      final results = await Future.wait<dynamic>([
        _api.classStudents(slot['classId'].toString()),
        _api.attendance(
          slotId: slotId,
          date: DateFormat('yyyy-MM-dd').format(date),
        ),
        _api.approvedLeavesForAttendance(slotId: slotId, date: date),
        _api.attendanceSessionStatus(slotId: slotId, date: date),
      ]);
      final st = (results[0] as List).cast<Map<String, dynamic>>();
      final saved = (results[1] as List).cast<Map<String, dynamic>>();
      final leaves = (results[2] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _students = st;
        _status
          ..clear()
          ..addEntries(st.map((s) => MapEntry(s['id'] as String, 'PRESENT')));
        _notes.clear();
        for (final record in saved) {
          final studentId = record['studentId']?.toString();
          if (studentId == null) continue;
          _status[studentId] = record['status']?.toString() ?? 'PRESENT';
          _notes[studentId] = record['note']?.toString() ?? '';
        }
        for (final leave in leaves) {
          final studentId = leave['studentId']?.toString();
          if (studentId == null ||
              saved.any((r) => r['studentId'] == studentId)) {
            continue;
          }
          _status[studentId] = 'ABSENT_EXCUSED';
          _notes[studentId] =
              leave['reason']?.toString() ?? 'Đơn nghỉ đã được duyệt';
        }
        _sessionStatus = (results[3] as Map).cast<String, dynamic>();
        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải HS: $e')));
    }
  }

  Future<void> _submit() async {
    if (_slotId == null) return;
    final missingNote = _students.where((student) {
      final id = student['id'].toString();
      return (_status[id] ?? 'PRESENT') != 'PRESENT' &&
          (_notes[id]?.trim().isEmpty ?? true);
    }).toList();
    if (missingNote.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần nhập ghi chú cho học sinh vắng hoặc đi muộn.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final marks = _students
        .map(
          (s) => {
            'studentId': s['id'],
            'status': _status[s['id']] ?? 'PRESENT',
            'note': (_notes[s['id']]?.trim().isEmpty ?? true)
                ? null
                : _notes[s['id']]!.trim(),
          },
        )
        .toList();
    try {
      await _api.bulkAttendance(
        slotId: _slotId!,
        date: date,
        marks: marks,
        classId: _slot?['classId']?.toString(),
        subjectName: _slot?['subjectName']?.toString(),
        periodNo: _slot?['periodNo'] as int?,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã lưu điểm danh. Trạng thái thay đổi đã được tự động thông báo tới học sinh và phụ huynh.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final refreshed = await _api.attendanceSessionStatus(
        slotId: _slotId!,
        date: DateTime.now(),
      );
      if (mounted) setState(() => _sessionStatus = refreshed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _unlockLateAttendance() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở khóa điểm danh muộn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lý do quên điểm danh',
            hintText: 'Nhập lý do cụ thể',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Mở khóa'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || _slotId == null) return;
    try {
      final status = await _api.unlockLateAttendance(
        slotId: _slotId!,
        date: DateTime.now(),
        reason: reason,
      );
      if (mounted) setState(() => _sessionStatus = status);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở khóa: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat(
      'EEEE, dd/MM/yyyy',
      'vi_VN',
    ).format(DateTime.now());
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _slotsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final dayCode = DateFormat(
          'EEE',
          'en_US',
        ).format(DateTime.now()).toUpperCase();
        final slots =
            (snap.data ?? [])
                .where((slot) => slot['dayOfWeek'] == dayCode)
                .toList()
              ..sort(
                (a, b) => ((a['periodNo'] as num?)?.toInt() ?? 0).compareTo(
                  (b['periodNo'] as num?)?.toInt() ?? 0,
                ),
              );
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
                  labelText: 'Chọn tiết',
                  isDense: true,
                ),
                items: slots
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(
                          '${_dayVi(s['dayOfWeek'] as String?)} · Tiết ${s['periodNo']} · ${s['subjectName']} · ${s['classId']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => _selectSlot(v, slots),
              ),
            ),
            if (_sessionStatus != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teacherAccent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _sessionStatus?['message']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (_sessionStatus?['requiresUnlockReason'] == true)
                      TextButton(
                        onPressed: _unlockLateAttendance,
                        child: const Text('Mở khóa'),
                      ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.06),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    today,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      label: const Text(
                        'Tất cả có mặt',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _slotId == null
                  ? const Center(
                      child: Text(
                        'Chọn một tiết để điểm danh',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : _loadingStudents
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                  ? const Center(
                      child: Text(
                        'Lớp chưa có học sinh',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _students.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final s = _students[i];
                        final id = s['id'] as String;
                        final status = _status[id] ?? 'PRESENT';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.teacherAccent.withValues(
                              alpha: 0.12,
                            ),
                            radius: 18,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.teacherAccent,
                              ),
                            ),
                          ),
                          title: Text(
                            s['fullName']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: status == 'PRESENT'
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: TextFormField(
                                    key: ValueKey('$id-$status'),
                                    initialValue: _notes[id] ?? '',
                                    maxLength: 255,
                                    decoration: const InputDecoration(
                                      labelText: 'Ghi chú bắt buộc',
                                      isDense: true,
                                      counterText: '',
                                    ),
                                    onChanged: (value) => _notes[id] = value,
                                  ),
                                ),
                          trailing: _StatusSelector(
                            value: status,
                            onChanged: (v) => setState(() {
                              _status[id] = v;
                              if (v == 'PRESENT') _notes.remove(id);
                            }),
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
                        (_slotId == null ||
                            _submitting ||
                            _sessionStatus?['canMark'] != true)
                        ? null
                        : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teacherAccent,
                    ),
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
          .map(
            (o) => PopupMenuItem(
              value: o.$1,
              child: Row(
                children: [
                  Icon(Icons.circle, color: o.$3, size: 10),
                  const SizedBox(width: 8),
                  Text(o.$2),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AttendanceHistory extends StatefulWidget {
  const _AttendanceHistory();

  @override
  State<_AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<_AttendanceHistory> {
  late Future<List<_AttendanceSessionSummary>> _future = _load();

  Future<List<_AttendanceSessionSummary>> _load() async {
    final api = sl<ApiService>();
    final slots = await api.myTimetable();
    final rowsBySlot = await Future.wait(
      slots.map((slot) async {
        try {
          return await api.attendance(slotId: slot['id'].toString());
        } catch (_) {
          // Ignore stale assignments that backend rejects for this teacher.
          return <Map<String, dynamic>>[];
        }
      }),
    );
    final sessions = <_AttendanceSessionSummary>[];
    for (var index = 0; index < slots.length; index++) {
      final slot = slots[index];
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final row in rowsBySlot[index]) {
        final date = row['date']?.toString();
        if (date != null) grouped.putIfAbsent(date, () => []).add(row);
      }
      for (final entry in grouped.entries) {
        sessions.add(
          _AttendanceSessionSummary(
            slotId: slot['id'].toString(),
            classId: slot['classId'].toString(),
            className:
                slot['classCode']?.toString() ?? slot['classId'].toString(),
            subject: slot['subjectName']?.toString() ?? '',
            date: DateTime.parse(entry.key),
            periodNo: (slot['periodNo'] as num?)?.toInt() ?? 0,
            records: entry.value,
          ),
        );
      }
    }
    sessions.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : a.periodNo.compareTo(b.periodNo);
    });
    return sessions;
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_AttendanceSessionSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Không thể tải lịch sử: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _reload,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final sessions = snapshot.data ?? const [];
        if (sessions.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có buổi điểm danh đã lưu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final session = sessions[index];
              final absent = session.records
                  .where((row) => row['status'] != 'PRESENT')
                  .length;
              final dateLabel = DateFormat('dd/MM/yyyy').format(session.date);
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherAttendanceSessionDetail(
                        slotId: session.slotId,
                        classId: session.classId,
                        className: session.className,
                        subject: session.subject,
                        date: session.date,
                        periodNo: session.periodNo,
                      ),
                    ),
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.teacherAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd/MM').format(session.date),
                      style: const TextStyle(
                        color: AppColors.teacherAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    '${session.className} — ${session.subject}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$dateLabel · Tiết ${session.periodNo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        absent == 0 ? 'Đủ' : '$absent cần chú ý',
                        style: TextStyle(
                          color: absent == 0
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AttendanceSessionSummary {
  const _AttendanceSessionSummary({
    required this.slotId,
    required this.classId,
    required this.className,
    required this.subject,
    required this.date,
    required this.periodNo,
    required this.records,
  });

  final String slotId;
  final String classId;
  final String className;
  final String subject;
  final DateTime date;
  final int periodNo;
  final List<Map<String, dynamic>> records;
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
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeroomYearEndPage()),
              ),
              icon: const Icon(Icons.school_outlined),
              label: const Text('Năm'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamGradingPage()),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Thi'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
            const _ChatAction(),
            const _NotiAction(),
          ],
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
  List<Map<String, dynamic>> _subjectOptions = [];
  List<Map<String, dynamic>> _semesters = [];

  String? _classId;
  String? _subjectId;
  String? _semesterId;
  bool _isHomeroomTeacher = false;
  bool _canEdit = false;

  List<_StudentGrade> _grades = [];
  bool _loadingGrades = false;
  String? _gradesError;

  Future<void> _loadStructure() async {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final results = await Future.wait([
      _api.classes(),
      _api.myTimetable(),
      _api.semesters(),
    ]);
    final allClasses = results[0];
    final timetable = results[1];
    _semesters = results[2];
    final mainSubject = user.mainSubject?.trim().toLowerCase();
    final accessibleClassIds = <String>{
      ...timetable
          .where(
            (slot) =>
                mainSubject != null &&
                mainSubject.isNotEmpty &&
                ((slot['subjectId'] ?? '').toString().trim().toLowerCase() ==
                        mainSubject ||
                    (slot['subjectName'] ?? '')
                            .toString()
                            .trim()
                            .toLowerCase() ==
                        mainSubject),
          )
          .map((slot) => (slot['classId'] ?? '').toString()),
      ...allClasses
          .where(
            (schoolClass) =>
                (schoolClass['homeroomTeacherId'] ?? '').toString() == user.id,
          )
          .map((schoolClass) => (schoolClass['id'] ?? '').toString()),
    }..remove('');
    _classes = allClasses
        .where(
          (schoolClass) =>
              accessibleClassIds.contains((schoolClass['id'] ?? '').toString()),
        )
        .toList();
    if (_classes.isNotEmpty) _classId = _classes.first['id']?.toString();
    if (_semesters.isNotEmpty) {
      final active = _semesters.where((item) => item['status'] == 'ACTIVE');
      _semesterId = (active.isNotEmpty ? active.first : _semesters.first)['id']
          ?.toString();
    }
    try {
      await _loadGradebookContext();
      _grades = await _fetchGrades();
    } catch (e) {
      _gradesError = '$e';
    }
  }

  Future<void> _loadGradebookContext() async {
    final classId = _classId;
    final semesterId = _semesterId;
    if (classId == null || semesterId == null) {
      _subjectOptions = [];
      _subjectId = null;
      _isHomeroomTeacher = false;
      _canEdit = false;
      return;
    }
    final contextData = await _api.teacherGradebookContext(
      classId: classId,
      semesterId: semesterId,
    );
    _subjectOptions = ((contextData['subjects'] as List?) ?? const [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
    _isHomeroomTeacher = contextData['homeroomTeacher'] == true;
    final currentExists = _subjectOptions.any(
      (subject) => subject['subjectId']?.toString() == _subjectId,
    );
    if (!currentExists) _subjectId = contextData['subjectId']?.toString();
    _syncSelectedSubjectAccess();
  }

  void _syncSelectedSubjectAccess() {
    final selected = _subjectOptions.where(
      (subject) => subject['subjectId']?.toString() == _subjectId,
    );
    _canEdit = selected.isNotEmpty && selected.first['editable'] == true;
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
        classId: classId,
        subjectId: subjectId,
        semesterId: semesterId,
      ),
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
        sid,
        s['fullName']?.toString() ?? '',
        List<double?>.from(scores),
      );
    }).toList();
  }

  Future<void> _loadGrades({bool reloadContext = false}) async {
    setState(() {
      _loadingGrades = true;
      _gradesError = null;
    });
    try {
      if (reloadContext) await _loadGradebookContext();
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
            child: Text(
              'Lỗi tải dữ liệu: ${snap.error}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
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
                        labelText: 'Lớp',
                        isDense: true,
                      ),
                      items: _classes
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id']?.toString(),
                              child: Text(
                                (c['code'] ?? c['name'] ?? '').toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _classId = v);
                        _loadGrades(reloadContext: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(
                        'grade-subject-$_classId-$_semesterId-$_subjectId',
                      ),
                      initialValue: _subjectId,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: _canEdit ? 'Môn học' : 'Môn học · Chỉ xem',
                        isDense: true,
                      ),
                      items: _subjectOptions
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['subjectId']?.toString(),
                              child: Text(
                                '${(c['subjectName'] ?? '').toString()}${c['editable'] == true ? '' : ' · Chỉ xem'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _subjectId = v;
                          _syncSelectedSubjectAccess();
                        });
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
                      decoration: const InputDecoration(
                        labelText: 'HK',
                        isDense: true,
                      ),
                      items: _semesters
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id']?.toString(),
                              child: Text(
                                (c['code'] ?? c['name'] ?? '').toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _semesterId = v);
                        _loadGrades(reloadContext: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_isHomeroomTeacher)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                color: (_canEdit ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      _canEdit
                          ? Icons.verified_user_outlined
                          : Icons.lock_outline,
                      size: 17,
                      color: _canEdit ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _canEdit
                            ? 'Lớp chủ nhiệm · Bạn có thể sửa môn thuộc chuyên ngành.'
                            : 'Lớp chủ nhiệm · Môn ngoài chuyên ngành chỉ được xem.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _canEdit
                              ? AppColors.success
                              : AppColors.warning,
                        ),
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
        child: Text(
          'Lỗi tải điểm: $_gradesError',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    if (_grades.isEmpty) {
      return const Center(
        child: Text(
          'Lớp chưa có học sinh',
          style: TextStyle(color: AppColors.textSecondary),
        ),
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
            AppColors.teacherAccent.withValues(alpha: 0.08),
          ),
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
            final hasAllScores = scores.every((score) => score != null);
            final avg = hasAllScores && sumW > 0 ? sum / sumW : null;
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    g.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                for (var i = 0; i < scores.length; i++)
                  DataCell(
                    InkWell(
                      onTap: _canEdit ? () => _editScore(g, i) : null,
                      child: SizedBox(
                        width: 40,
                        child: Text(
                          scores[i]?.toStringAsFixed(1) ?? '—',
                          style: TextStyle(
                            color: scores[i] != null
                                ? _scoreColor(scores[i]!)
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                DataCell(
                  SizedBox(
                    width: 40,
                    child: Text(
                      avg?.toStringAsFixed(2) ?? '—',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: avg != null
                            ? _scoreColor(avg)
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _editScore(_StudentGrade g, int index) async {
    if (!_canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chỉ được xem điểm môn ngoài chuyên ngành.'),
        ),
      );
      return;
    }
    final classId = _classId;
    final subjectId = _subjectId;
    final semesterId = _semesterId;
    if (classId == null || subjectId == null || semesterId == null) return;
    final ctrl = TextEditingController(
      text: g.scores[index]?.toStringAsFixed(1) ?? '',
    );
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
              backgroundColor: AppColors.teacherAccent,
            ),
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
        classId: classId,
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
          content: Text(
            isEdit
                ? 'Đã sửa điểm, ghi log và tự động thông báo tới học sinh, phụ huynh.'
                : 'Đã lưu điểm mới và tự động thông báo tới học sinh, phụ huynh.',
          ),
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
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _GradeDistributionView extends StatefulWidget {
  const _GradeDistributionView();

  @override
  State<_GradeDistributionView> createState() => _GradeDistributionViewState();
}

class _GradeDistributionViewState extends State<_GradeDistributionView> {
  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _semesters = [];
  List<({String id, String name, double average})> _students = [];
  String? _classId;
  String? _semesterId;
  String _subjectName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStructure();
  }

  Future<void> _loadStructure() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.teachingClasses(),
        _api.semesters(),
      ]);
      _classes = values[0];
      _semesters = values[1];
      if (_classId == null && _classes.isNotEmpty) {
        _classId = _classes.first['id']?.toString();
      }
      final activeSemesters = _semesters
          .where((item) => item['status'] == 'ACTIVE')
          .toList();
      if (_semesterId == null && activeSemesters.isNotEmpty) {
        _semesterId = activeSemesters.first['id']?.toString();
      }
      if (_semesterId == null && _semesters.isNotEmpty) {
        _semesterId = _semesters.first['id']?.toString();
      }
      await _loadDistribution(showLoader: false);
    } catch (_) {
      _students = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDistribution({bool showLoader = true}) async {
    if (_classId == null || _semesterId == null) return;
    if (showLoader) setState(() => _loading = true);
    try {
      final context = await _api.teacherGradebookContext(
        classId: _classId!,
        semesterId: _semesterId!,
      );
      final subjectId = context['subjectId']?.toString();
      _subjectName = context['subjectName']?.toString() ?? '';
      if (subjectId == null || subjectId.isEmpty) {
        _students = [];
        return;
      }
      final values = await Future.wait([
        _api.grades(
          classId: _classId,
          semesterId: _semesterId,
          subjectId: subjectId,
        ),
        _api.classStudents(_classId!),
      ]);
      final names = <String, String>{
        for (final student in values[1])
          student['id'].toString(): student['fullName'].toString(),
      };
      final grouped = <String, List<double>>{};
      for (final grade in values[0]) {
        final score = (grade['score'] as num?)?.toDouble();
        final studentId = grade['studentId']?.toString();
        if (score != null && studentId != null) {
          grouped.putIfAbsent(studentId, () => []).add(score);
        }
      }
      _students = grouped.entries.map((entry) {
        final average =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
        return (
          id: entry.key,
          name: names[entry.key] ?? entry.key,
          average: average,
        );
      }).toList()..sort((a, b) => b.average.compareTo(a.average));
    } finally {
      if (showLoader && mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _students.length;
    final classAverage = total == 0
        ? 0.0
        : _students.fold<double>(0, (sum, item) => sum + item.average) / total;
    final ranges = [
      (
        'Yếu (<5)',
        _students.where((item) => item.average < 5).length,
        AppColors.error,
      ),
      (
        'TB (5–6.5)',
        _students
            .where((item) => item.average >= 5 && item.average < 6.5)
            .length,
        AppColors.late,
      ),
      (
        'Khá (6.5–8)',
        _students
            .where((item) => item.average >= 6.5 && item.average < 8)
            .length,
        AppColors.warning,
      ),
      (
        'Giỏi (8–10)',
        _students.where((item) => item.average >= 8).length,
        AppColors.success,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _classId,
                decoration: const InputDecoration(
                  labelText: 'Lớp',
                  isDense: true,
                ),
                items: _classes
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text((item['code'] ?? item['name']).toString()),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (value) async {
                        setState(() => _classId = value);
                        await _loadDistribution();
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _semesterId,
                decoration: const InputDecoration(
                  labelText: 'Học kỳ',
                  isDense: true,
                ),
                items: _semesters
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text((item['name'] ?? item['code']).toString()),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (value) async {
                        setState(() => _semesterId = value);
                        await _loadDistribution();
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teacherAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.teacherAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subjectName.isEmpty
                          ? 'Chưa có môn được phân công'
                          : _subjectName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Có điểm: $total học sinh • TB: ${classAverage.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
                for (final r in ranges) ...[
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
                            value: total == 0 ? 0 : r.$2 / total,
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
                            fontSize: 13,
                          ),
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
        const SectionHeader(title: 'Top 5 học sinh điểm cao nhất'),
        const SizedBox(height: 10),
        Card(
          child: total == 0
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Chưa có dữ liệu điểm cho lựa chọn này.'),
                )
              : Column(
                  children: [
                    for (
                      var index = 0;
                      index < _students.take(5).length;
                      index++
                    ) ...[
                      _TopStudentRow(
                        rank: index + 1,
                        name: _students[index].name,
                        avg: _students[index].average,
                      ),
                      if (index < _students.take(5).length - 1)
                        const Divider(height: 0),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _TopStudentRow extends StatelessWidget {
  const _TopStudentRow({
    required this.rank,
    required this.name,
    required this.avg,
  });
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
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _rankColor,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        avg.toStringAsFixed(2),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.success,
          fontSize: 14,
        ),
      ),
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
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (up ? AppColors.success : AppColors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            oldV.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            up
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: up ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newV.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: up ? AppColors.success : AppColors.error,
                            ),
                          ),
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
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                    backgroundColor: AppColors.teacherAccent.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      user.fullName[0],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teacherAccent,
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
                    user.mainSubject ?? 'Giáo viên',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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
                const ListTile(
                  leading: Icon(
                    Icons.class_rounded,
                    color: AppColors.teacherAccent,
                  ),
                  title: Text('Lớp chủ nhiệm'),
                  subtitle: Text('10A1'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.teacherAccent,
                  ),
                  title: Text('Môn giảng dạy'),
                  subtitle: Text('Toán • 4 lớp'),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.teacherAccent,
                  ),
                  title: const Text('Tiến độ giảng dạy'),
                  subtitle: const Text(
                    'Cập nhật bài đã dạy và đề xuất lịch bù',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TeacherProgressPage(),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.teacherAccent,
                  ),
                  title: const Text('Trung tâm công việc'),
                  subtitle: const Text(
                    'Khảo thí, đơn xin nghỉ và báo cáo',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MobileWorkspacePage(
                        role: 'TEACHER',
                        accent: AppColors.teacherAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.teacherAccent,
                  ),
                  title: const Text('Tin nhắn'),
                  subtitle: const Text(
                    'Chat HS / PH + Broadcast lớp',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatListPage(
                        accent: AppColors.teacherAccent,
                        allowBroadcast: true,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.teacherAccent,
                  ),
                  title: const Text('Thông báo'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenter(
                        accent: AppColors.teacherAccent,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                const ThemeModeTile(accent: AppColors.teacherAccent),
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

class _TAssignment {
  const _TAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.deadline,
    required this.status,
    required this.submitted,
    required this.total,
    this.deadlineAt,
    this.allowLate = false,
  });
  final String id;
  final String title;
  final String subject;
  final String className;
  final String deadline;
  final String status; // DRAFT / PUBLISHED / CLOSED
  final int submitted;
  final int total;
  final DateTime? deadlineAt;
  final bool allowLate;
}

const _teacherAssignments = <_TAssignment>[
  _TAssignment(
    id: 'demo-1',
    title: 'Bài tập Hàm số bậc hai',
    subject: 'Toán',
    className: '10A1',
    deadline: '28/05 23:59',
    status: 'PUBLISHED',
    submitted: 18,
    total: 38,
  ),
  _TAssignment(
    id: 'demo-2',
    title: 'Đề ôn tập GK',
    subject: 'Toán',
    className: '10A2',
    deadline: '02/06 23:59',
    status: 'PUBLISHED',
    submitted: 5,
    total: 40,
  ),
  _TAssignment(
    id: 'demo-3',
    title: 'Bài tập Phép tính ma trận',
    subject: 'Toán',
    className: '10A1',
    deadline: '10/06 23:59',
    status: 'DRAFT',
    submitted: 0,
    total: 38,
  ),
  _TAssignment(
    id: 'demo-4',
    title: 'Bài tập Chương 1 — Đại số',
    subject: 'Toán',
    className: '10A1',
    deadline: '15/04 23:59',
    status: 'CLOSED',
    submitted: 36,
    total: 38,
  ),
  _TAssignment(
    id: 'demo-5',
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
  late Future<List<_TAssignment>> _future = _load();

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

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
      id: (a['id'] ?? '').toString(),
      title: (a['title'] ?? '').toString(),
      subject: (a['subjectName'] ?? '').toString(),
      className: (a['classId'] ?? '').toString(),
      deadline: deadline,
      status: (a['status'] ?? 'DRAFT').toString(),
      submitted: (a['submissionCount'] as num?)?.toInt() ?? 0,
      total: (a['studentCount'] as num?)?.toInt() ?? 0,
      deadlineAt: DateTime.tryParse(
        (a['deadline'] ?? '').toString(),
      )?.toLocal(),
      allowLate: a['allowLate'] == true,
    );
  }

  Future<void> _publish(_TAssignment assignment) async {
    try {
      await sl<ApiService>().publishAssignment(assignment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã phát hành bài tập')));
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể phát hành: $error')));
    }
  }

  Future<void> _assignmentAction(_TAssignment assignment, String action) async {
    try {
      String message;
      switch (action) {
        case 'close':
          await sl<ApiService>().closeAssignment(assignment.id);
          message = 'Đã đóng nhận bài';
          break;
        case 'reopen':
          await sl<ApiService>().reopenAssignment(assignment.id);
          message = 'Đã mở lại nhận bài';
          break;
        case 'late':
          await sl<ApiService>().updateAssignment(assignment.id, {
            'allowLate': !assignment.allowLate,
          });
          message = assignment.allowLate
              ? 'Đã tắt nộp muộn'
              : 'Đã cho phép nộp muộn';
          break;
        case 'extend':
          final now = DateTime.now();
          final tomorrow = DateTime(now.year, now.month, now.day + 1);
          final currentDeadline = assignment.deadlineAt;
          final initial =
              currentDeadline != null &&
                  !DateTime(
                    currentDeadline.year,
                    currentDeadline.month,
                    currentDeadline.day,
                  ).isBefore(tomorrow)
              ? currentDeadline
              : tomorrow;
          final date = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: tomorrow,
            lastDate: DateTime.now().add(const Duration(days: 730)),
          );
          if (date == null) return;
          final deadline = DateTime(date.year, date.month, date.day, 23, 59);
          await sl<ApiService>().extendAssignment(assignment.id, deadline);
          message = 'Đã gia hạn và mở nhận bài';
          break;
        default:
          return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật bài tập: $error')),
      );
    }
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
              child: Text(
                'Lỗi tải bài tập: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
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
            floatingActionButton: QuickCreateButton(
              role: 'TEACHER',
              accent: AppColors.teacherAccent,
              initialType: 'ASSIGNMENT',
              onCreated: _refresh,
            ),
            body: TabBarView(
              children: [
                _TAssignmentList(
                  items: published,
                  onChanged: _refresh,
                  onAction: _assignmentAction,
                ),
                _TAssignmentList(
                  items: drafts,
                  isDraft: true,
                  onChanged: _refresh,
                  onPublish: _publish,
                  onAction: _assignmentAction,
                ),
                _TAssignmentList(
                  items: closed,
                  isClosed: true,
                  onChanged: _refresh,
                  onAction: _assignmentAction,
                ),
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
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo bài tập mới',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
                          labelText: 'Lớp',
                          isDense: true,
                        ),
                        items: ['10A1', '10A2', '8A1']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => cls = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: subj,
                        decoration: const InputDecoration(
                          labelText: 'Môn',
                          isDense: true,
                        ),
                        items: ['Toán', 'Vật lý', 'Hoá học']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
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
                                'Đã phát hành. Học sinh nhận thông báo.',
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teacherAccent,
                        ),
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
    this.onChanged,
    this.onPublish,
    this.onAction,
  });
  final List<_TAssignment> items;
  final bool isDraft;
  final bool isClosed;
  final VoidCallback? onChanged;
  final Future<void> Function(_TAssignment assignment)? onPublish;
  final Future<void> Function(_TAssignment assignment, String action)? onAction;

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
        child: Text(
          'Không có bài tập',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
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
            onTap: () async {
              if (isDraft) {
                await onPublish?.call(a);
                return;
              }
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => TeacherAssignmentGrading(
                    assignmentId: a.id,
                    assignmentTitle: a.title,
                    subject: a.subject,
                    className: a.className,
                    deadline: a.deadline,
                    studentCount: a.total,
                  ),
                ),
              );
              if (changed == true) onChanged?.call();
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
                          color: AppColors.teacherAccent.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${a.className} • ${a.subject}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teacherAccent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (a.status == 'DRAFT')
                        const Icon(
                          Icons.publish_rounded,
                          color: AppColors.textSecondary,
                        )
                      else
                        PopupMenuButton<String>(
                          tooltip: 'Quản lý bài tập',
                          onSelected: (action) => onAction?.call(a, action),
                          itemBuilder: (_) => [
                            if (a.status == 'PUBLISHED') ...[
                              const PopupMenuItem(
                                value: 'close',
                                child: Text('Đóng nhận bài'),
                              ),
                              PopupMenuItem(
                                value: 'late',
                                child: Text(
                                  a.allowLate
                                      ? 'Tắt nộp muộn'
                                      : 'Cho phép nộp muộn',
                                ),
                              ),
                            ],
                            if (a.status == 'CLOSED')
                              const PopupMenuItem(
                                value: 'reopen',
                                child: Text('Mở lại nhận bài'),
                              ),
                            const PopupMenuItem(
                              value: 'extend',
                              child: Text('Gia hạn'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert_rounded),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hạn: ${a.deadline}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (a.allowLate) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'Cho phép nộp muộn',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                        Text(
                          '${a.submitted}/${a.total}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teacherAccent,
                          ),
                        ),
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
    return const LiveChatAction(
      accent: AppColors.teacherAccent,
      allowBroadcast: true,
    );
  }
}
