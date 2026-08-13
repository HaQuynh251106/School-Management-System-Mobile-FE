import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../grades/data/grade_record.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/quick_create.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'assignment_grading.dart';
import 'class_slot_detail.dart';
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
              role: 'TEACHER', accent: AppColors.teacherAccent)
          : null,
      pages: [
        _TimetableTab(
          onOpenAttendance: () => setState(() => _tab = 1),
          onOpenGrades: () => setState(() => _tab = 2),
          onOpenProgress: () => setState(() => _tab = 3),
          onOpenAssignments: () => setState(() => _tab = 4),
        ),
        const _AttendanceTab(),
        const _GradesTab(),
        const TeacherProgressPage(),
        const _AssignmentsTab(),
        const _ProfileTab(),
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
          selectedIcon: Icons.history_edu_rounded,
          label: 'Tiến độ',
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

const _dayLabels = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
];

class _TimetableTab extends StatefulWidget {
  const _TimetableTab({
    required this.onOpenAttendance,
    required this.onOpenGrades,
    required this.onOpenProgress,
    required this.onOpenAssignments,
  });
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenAssignments;
  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab>
    with WidgetsBindingObserver {
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _dayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  late Future<List<List<Map<String, dynamic>>>> _future;
  StreamSubscription<RealtimeEvent>? _timetableEvents;
  Timer? _reloadDebounce;

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().myTimetable(),
        sl<ApiService>().teacherAssignments(),
      ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
    final realtime = sl<RealtimeService>()..connect();
    _timetableEvents = realtime.events
        .where((event) => event.type == 'TIMETABLE_PUBLISHED')
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
    _timetableEvents?.cancel();
    super.dispose();
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
        body: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Không thể tải thời khóa biểu.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              );
            }
            final batches = snap.data ?? const [];
            final all = batches.isEmpty
                ? const <Map<String, dynamic>>[]
                : batches.first;
            final assignments = batches.length > 1
                ? batches[1]
                : const <Map<String, dynamic>>[];
            final activeAssignments = assignments
                .where((item) => '${item['status']}' == 'PUBLISHED')
                .length;
            final subjectCount = all
                .map((item) => '${item['subjectId'] ?? item['subjectName']}')
                .where((value) => value.isNotEmpty)
                .toSet()
                .length;
            return TabBarView(
              children: List.generate(_days.length, (dayIdx) {
                final slots = all
                    .where((s) => s['dayOfWeek'] == _dayCodes[dayIdx])
                    .toList()
                  ..sort((a, b) =>
                      (a['periodNo'] as int).compareTo(b['periodNo'] as int));
                if (slots.isEmpty) {
                  return Center(
                    child: Text('Không có tiết dạy',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      final classCount = slots
                          .map((slot) => '${slot['classId']}')
                          .toSet()
                          .length;
                      return Column(
                        children: [
                          RolePageIntro(
                            title: 'Lịch dạy trong ngày',
                            subtitle:
                                '${_dayLabels[dayIdx]} có ${slots.length} tiết. Chọn mục bên dưới để tiếp tục.',
                            accent: AppColors.teacherAccent,
                            icon: Icons.co_present_rounded,
                          ),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.15,
                            children: [
                              _TeacherShortcut(
                                value: '$classCount',
                                label: 'Lớp điểm danh',
                                icon: Icons.fact_check_rounded,
                                onTap: widget.onOpenAttendance,
                              ),
                              _TeacherShortcut(
                                value: '$subjectCount',
                                label: 'Môn nhập điểm',
                                icon: Icons.grade_rounded,
                                onTap: widget.onOpenGrades,
                              ),
                              _TeacherShortcut(
                                value: '${slots.length}',
                                label: 'Tiết cập nhật tiến độ',
                                icon: Icons.history_edu_rounded,
                                onTap: widget.onOpenProgress,
                              ),
                              _TeacherShortcut(
                                value: '$activeAssignments',
                                label: 'Bài tập đang mở',
                                icon: Icons.assignment_rounded,
                                onTap: widget.onOpenAssignments,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.period} • Lớp ${slot.className} • ${slot.room}',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherShortcut extends StatelessWidget {
  const _TeacherShortcut({
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
              Icon(icon, color: AppColors.teacherAccent, size: 21),
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
                  color: AppColors.teacherAccent, size: 16),
            ]),
          ),
        ),
      );
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
  final Map<String, String> _notes = {};
  final Map<String, int> _attendanceVersions = {};
  DateTime _attendanceDate = DateTime.now();
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
      _sessionStatus = null;
    });
    await _loadSession(slot);
  }

  Future<void> _loadSession(Map<String, dynamic> slot) async {
    final date = DateFormat('yyyy-MM-dd').format(_attendanceDate);
    try {
      final values = await Future.wait([
        _api.classStudents(slot['classId'].toString()),
        _api.attendance(slotId: '${slot['id']}', date: date),
        _api.attendanceSessionStatus('${slot['id']}', date),
      ]);
      final st = values[0] as List<Map<String, dynamic>>;
      final existing = values[1] as List<Map<String, dynamic>>;
      final session = values[2] as Map<String, dynamic>;
      final byStudent = {
        for (final item in existing) '${item['studentId']}': item,
      };
      if (!mounted) return;
      setState(() {
        _students = st;
        _status
          ..clear()
          ..addEntries(st.map((s) => MapEntry(s['id'] as String,
              '${byStudent['${s['id']}']?['status'] ?? 'PRESENT'}')));
        _notes
          ..clear()
          ..addEntries(st.map((s) => MapEntry(
              s['id'] as String, '${byStudent['${s['id']}']?['note'] ?? ''}')));
        _attendanceVersions
          ..clear()
          ..addEntries(existing.map((record) => MapEntry(
              '${record['studentId']}',
              (record['version'] as num?)?.toInt() ?? 0)));
        _sessionStatus = session;
        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStudents = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải danh sách học sinh.')));
    }
  }

  Future<void> _submit() async {
    if (_slotId == null) return;
    final missingNote = _students.any((student) {
      final id = '${student['id']}';
      return (_status[id] ?? 'PRESENT') != 'PRESENT' &&
          (_notes[id] ?? '').trim().isEmpty;
    });
    if (missingNote) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Vui lòng nhập lý do/ghi chú cho học sinh vắng hoặc muộn.'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }
    setState(() => _submitting = true);
    final date = DateFormat('yyyy-MM-dd').format(_attendanceDate);
    final marks = _students
        .map((s) => {
              'studentId': s['id'],
              'status': _status[s['id']] ?? 'PRESENT',
              'note': (_notes[s['id']] ?? '').trim().isEmpty
                  ? null
                  : _notes[s['id']]!.trim(),
              if (_attendanceVersions.containsKey('${s['id']}'))
                'expectedVersion': _attendanceVersions['${s['id']}'],
            })
        .toList();
    try {
      await _api.bulkAttendance(slotId: _slotId!, date: date, marks: marks);
      if (_slot != null) await _loadSession(_slot!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Đã lưu điểm danh. Trạng thái thay đổi đã được tự động thông báo tới học sinh và phụ huynh.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      final conflict = e is DioException && e.response?.statusCode == 409;
      if (conflict && _slot != null) await _loadSession(_slot!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(conflict
              ? 'Sổ điểm danh vừa được cập nhật ở thiết bị khác. Dữ liệu mới nhất đã được tải lại; vui lòng kiểm tra rồi lưu lại.'
              : 'Không thể lưu điểm danh. Vui lòng thử lại.'),
          backgroundColor: conflict ? AppColors.warning : AppColors.error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _attendanceDate = picked);
    if (_slot != null) {
      setState(() => _loadingStudents = true);
      await _loadSession(_slot!);
    }
  }

  Future<void> _unlock() async {
    if (_slotId == null) return;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở khóa điểm danh muộn'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration:
              const InputDecoration(labelText: 'Lý do (ít nhất 10 ký tự)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Mở khóa')),
        ],
      ),
    );
    if (reason == null || reason.length < 10) return;
    try {
      final date = DateFormat('yyyy-MM-dd').format(_attendanceDate);
      final status = await _api.unlockAttendance(_slotId!, date, reason);
      if (mounted) setState(() => _sessionStatus = status);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể mở khóa điểm danh. Vui lòng thử lại.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_attendanceDate);
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
              color: Theme.of(context).colorScheme.surface,
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
                            '${_dayVi(s['dayOfWeek'] as String?)} · Tiết ${s['periodNo']} · ${s['subjectName']} · ${s['className'] ?? s['classCode'] ?? 'Lớp học'}',
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
                  Icon(Icons.event_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(selectedDate,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.teacherAccent,
                              fontWeight: FontWeight.w600)),
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
                      label: const Text('Tất cả có mặt',
                          style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ),
            if (_sessionStatus != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: (_sessionStatus!['canMark'] == true
                        ? AppColors.success
                        : AppColors.warning)
                    .withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(
                      _sessionStatus!['canMark'] == true
                          ? Icons.lock_open_rounded
                          : Icons.lock_clock_rounded,
                      size: 16,
                      color: _sessionStatus!['canMark'] == true
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_sessionStatus!['message'] ?? _sessionStatus!['state'] ?? ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    if (_sessionStatus!['requiresUnlockReason'] == true)
                      TextButton(
                        onPressed: _unlock,
                        child: const Text('Mở khóa'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: _slotId == null
                  ? Center(
                      child: Text('Chọn một tiết để điểm danh',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)))
                  : _loadingStudents
                      ? const Center(child: CircularProgressIndicator())
                      : _students.isEmpty
                          ? Center(
                              child: Text('Lớp chưa có học sinh',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)))
                          : ListView.separated(
                              itemCount: _students.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 0),
                              itemBuilder: (_, i) {
                                final s = _students[i];
                                final id = s['id'] as String;
                                final status = _status[id] ?? 'PRESENT';
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.teacherAccent
                                            .withValues(alpha: 0.12),
                                        radius: 18,
                                        child: Text('${i + 1}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color:
                                                    AppColors.teacherAccent)),
                                      ),
                                      title: Text(
                                          s['fullName']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14)),
                                      trailing: _StatusSelector(
                                        value: status,
                                        onChanged: (v) =>
                                            setState(() => _status[id] = v),
                                      ),
                                    ),
                                    if (status != 'PRESENT')
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            68, 0, 16, 10),
                                        child: TextFormField(
                                          initialValue: _notes[id] ?? '',
                                          onChanged: (value) =>
                                              _notes[id] = value,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Lý do/ghi chú (bắt buộc)',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                  ],
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
                    onPressed: (_slotId == null ||
                            _submitting ||
                            _sessionStatus?['canMark'] != true)
                        ? null
                        : _submit,
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

class _AttendanceHistory extends StatefulWidget {
  const _AttendanceHistory();

  @override
  State<_AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<_AttendanceHistory> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final slots = await _api.myTimetable();
    final unique = <String, Map<String, dynamic>>{
      for (final slot in slots) '${slot['id']}': slot,
    };
    final batches = await Future.wait(unique.values.map((slot) async {
      final records = await _api.attendance(slotId: '${slot['id']}');
      return (slot: slot, records: records);
    }));
    final sessions = <String, Map<String, dynamic>>{};
    for (final batch in batches) {
      for (final record in batch.records) {
        final key = '${batch.slot['id']}|${record['date']}';
        final session = sessions.putIfAbsent(
          key,
          () => {
            'slot': batch.slot,
            'date': '${record['date']}',
            'records': <Map<String, dynamic>>[],
          },
        );
        (session['records'] as List<Map<String, dynamic>>).add(record);
      }
    }
    final result = sessions.values.toList();
    result.sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return result;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại lịch sử'),
            ),
          );
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                const SizedBox(height: 180),
                Center(
                  child: Text('Chưa có buổi điểm danh nào được lưu.',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final session = sessions[i];
              final slot = session['slot'] as Map<String, dynamic>;
              final records = session['records'] as List<Map<String, dynamic>>;
              final absent = records
                  .where((record) => '${record['status']}' != 'PRESENT')
                  .length;
              final rawDate = DateTime.tryParse('${session['date']}');
              final date = rawDate == null
                  ? '${session['date']}'
                  : DateFormat('dd/MM/yyyy').format(rawDate);
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              AppColors.teacherAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(date.substring(0, 5),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.teacherAccent)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${slot['className'] ?? slot['classCode'] ?? 'Lớp học'} — ${slot['subjectName'] ?? 'Môn học'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                                'Tiết ${slot['periodNo'] ?? recordPeriod(records)} · ${records.length} học sinh',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (absent == 0
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          absent == 0 ? 'Đủ' : '$absent vắng/muộn',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: absent == 0
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
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

  Object recordPeriod(List<Map<String, dynamic>> records) =>
      records.isEmpty ? '-' : records.first['periodNo'] ?? '-';
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
  _StudentGrade(this.studentId, this.name, this.records);
  final String studentId;
  final String name;
  final Map<String, GradeRecord> records;
}

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
  List<GradeColumn> _gradeColumns = [];

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
      _api.examCategories(),
    ]);
    final allClasses = results[0];
    final timetable = results[1];
    _semesters = results[2];
    _gradeColumns = buildGradeColumns(results[3]
        .map(GradeCategoryDefinition.fromJson)
        .toList(growable: false));
    final mainSubject = user.mainSubject?.trim().toLowerCase();
    final accessibleClassIds = <String>{
      ...timetable
          .where((slot) =>
              mainSubject != null &&
              mainSubject.isNotEmpty &&
              ((slot['subjectId'] ?? '').toString().trim().toLowerCase() ==
                      mainSubject ||
                  (slot['subjectName'] ?? '').toString().trim().toLowerCase() ==
                      mainSubject))
          .map((slot) => (slot['classId'] ?? '').toString()),
      ...allClasses
          .where((schoolClass) =>
              (schoolClass['homeroomTeacherId'] ?? '').toString() == user.id)
          .map((schoolClass) => (schoolClass['id'] ?? '').toString()),
    }..remove('');
    _classes = allClasses
        .where((schoolClass) =>
            accessibleClassIds.contains((schoolClass['id'] ?? '').toString()))
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
      _gradesError = 'Không thể tải điểm. Vui lòng thử lại.';
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
        classId: classId, semesterId: semesterId);
    _subjectOptions = ((contextData['subjects'] as List?) ?? const [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
    _isHomeroomTeacher = contextData['homeroomTeacher'] == true;
    final currentExists = _subjectOptions
        .any((subject) => subject['subjectId']?.toString() == _subjectId);
    if (!currentExists) _subjectId = contextData['subjectId']?.toString();
    _syncSelectedSubjectAccess();
  }

  void _syncSelectedSubjectAccess() {
    final selected = _subjectOptions
        .where((subject) => subject['subjectId']?.toString() == _subjectId);
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
          classId: classId, subjectId: subjectId, semesterId: semesterId),
    ]);
    final students = results[0];
    final gradeRows = results[1];
    final byStudent = <String, Map<String, GradeRecord>>{};
    for (final row in gradeRows) {
      if (row['score'] is! num) continue;
      final record = GradeRecord.fromJson(row);
      if (record.studentId.isEmpty || record.category.isEmpty) continue;
      (byStudent[record.studentId] ??= {})[record.key] = record;
    }
    return students.map((s) {
      final sid = s['id']?.toString() ?? '';
      return _StudentGrade(sid, s['fullName']?.toString() ?? '',
          byStudent[sid] ?? <String, GradeRecord>{});
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
        _gradesError = 'Không thể tải điểm. Vui lòng thử lại.';
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
            child: Text('Không thể tải dữ liệu lớp học.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        return Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
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
                        _loadGrades(reloadContext: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(
                          'grade-subject-$_classId-$_semesterId-$_subjectId'),
                      initialValue: _subjectId,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: _canEdit ? 'Môn học' : 'Môn học · Chỉ xem',
                          isDense: true),
                      items: _subjectOptions
                          .map((c) => DropdownMenuItem(
                                value: c['subjectId']?.toString(),
                                child: Text(
                                  '${(c['subjectName'] ?? '').toString()}${c['editable'] == true ? '' : ' · Chỉ xem'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                color: (_canEdit ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                        _canEdit
                            ? Icons.verified_user_outlined
                            : Icons.lock_outline,
                        size: 17,
                        color:
                            _canEdit ? AppColors.success : AppColors.warning),
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
                                : AppColors.warning),
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
        child: Text(_gradesError!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }
    if (_grades.isEmpty) {
      return Center(
        child: Text('Lớp chưa có học sinh',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
          columns: [
            const DataColumn(label: Text('Học sinh')),
            ..._gradeColumns
                .map((column) => DataColumn(label: Text(column.label))),
            const DataColumn(label: Text('TB')),
          ],
          rows: _grades.map((g) {
            final avg = completeWeightedAverage(g.records, _gradeColumns);
            return DataRow(cells: [
              DataCell(Text(g.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
              for (final column in _gradeColumns)
                DataCell(
                  InkWell(
                    onTap: _canEdit ? () => _editScore(g, column) : null,
                    child: SizedBox(
                      width: 40,
                      child: Text(
                        g.records[column.key]?.score.toStringAsFixed(1) ?? '—',
                        style: TextStyle(
                            color: g.records[column.key] != null
                                ? _scoreColor(g.records[column.key]!.score)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _editScore(_StudentGrade g, GradeColumn column) async {
    if (!_canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bạn chỉ được xem điểm môn ngoài chuyên ngành.'),
      ));
      return;
    }
    final classId = _classId;
    final subjectId = _subjectId;
    final semesterId = _semesterId;
    if (classId == null || subjectId == null || semesterId == null) return;
    final current = g.records[column.key];
    final ctrl =
        TextEditingController(text: current?.score.toStringAsFixed(1) ?? '');
    final reasonCtrl = TextEditingController();
    final isEdit = current != null;
    final result = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${column.label} — ${g.name}'),
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
        classId: classId,
        subjectId: subjectId,
        semesterId: semesterId,
        category: column.category,
        assessmentIndex: column.assessmentIndex,
        reason: reason.isEmpty ? null : reason,
        entries: [
          {
            'studentId': g.studentId,
            'score': result,
            if (current != null) 'expectedVersion': current.version,
          },
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Đã sửa điểm, ghi log và tự động thông báo tới học sinh, phụ huynh.'
              : 'Đã lưu điểm mới và tự động thông báo tới học sinh, phụ huynh.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadGrades();
    } catch (e) {
      if (!mounted) return;
      final conflict = e is DioException && e.response?.statusCode == 409;
      if (conflict) await _loadGrades();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(conflict
                ? 'Điểm vừa được cập nhật ở thiết bị khác. Dữ liệu mới nhất đã được tải lại; vui lòng kiểm tra trước khi sửa lại.'
                : 'Không thể lưu điểm. Vui lòng thử lại.'),
            backgroundColor: conflict ? AppColors.warning : AppColors.error),
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
      final activeSemesters =
          _semesters.where((item) => item['status'] == 'ACTIVE').toList();
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
          classId: _classId!, semesterId: _semesterId!);
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
        _api.examCategories(),
      ]);
      final names = <String, String>{
        for (final student in values[1])
          student['id'].toString(): student['fullName'].toString(),
      };
      final columns = buildGradeColumns(values[2]
          .map(GradeCategoryDefinition.fromJson)
          .toList(growable: false));
      final grouped = <String, Map<String, GradeRecord>>{};
      for (final grade in values[0]) {
        if (grade['score'] is! num) continue;
        final record = GradeRecord.fromJson(grade);
        if (record.studentId.isEmpty) continue;
        (grouped[record.studentId] ??= {})[record.key] = record;
      }
      _students = grouped.entries
          .map((entry) {
            final average = completeWeightedAverage(entry.value, columns);
            return (
              id: entry.key,
              name: names[entry.key] ?? entry.key,
              average: average,
            );
          })
          .where((entry) => entry.average != null)
          .map((entry) => (
                id: entry.id,
                name: entry.name,
                average: entry.average!,
              ))
          .toList()
        ..sort((a, b) => b.average.compareTo(a.average));
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
        AppColors.error
      ),
      (
        'TB (5–6.5)',
        _students
            .where((item) => item.average >= 5 && item.average < 6.5)
            .length,
        AppColors.late
      ),
      (
        'Khá (6.5–8)',
        _students
            .where((item) => item.average >= 6.5 && item.average < 8)
            .length,
        AppColors.warning
      ),
      (
        'Giỏi (8–10)',
        _students.where((item) => item.average >= 8).length,
        AppColors.success
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _classId,
              decoration:
                  const InputDecoration(labelText: 'Lớp', isDense: true),
              items: _classes
                  .map((item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text((item['code'] ?? item['name']).toString()),
                      ))
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
              decoration:
                  const InputDecoration(labelText: 'Học kỳ', isDense: true),
              items: _semesters
                  .map((item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text((item['name'] ?? item['code']).toString()),
                      ))
                  .toList(),
              onChanged: _loading
                  ? null
                  : (value) async {
                      setState(() => _semesterId = value);
                      await _loadDistribution();
                    },
            ),
          ),
        ]),
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
              const Icon(Icons.insights_rounded,
                  color: AppColors.teacherAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _subjectName.isEmpty
                            ? 'Chưa có môn được phân công'
                            : _subjectName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                        'Có điểm: $total học sinh • TB: ${classAverage.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
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
                    for (var index = 0;
                        index < _students.take(5).length;
                        index++) ...[
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

class _GradeChangeLogView extends StatefulWidget {
  const _GradeChangeLogView();

  @override
  State<_GradeChangeLogView> createState() => _GradeChangeLogViewState();
}

class _GradeChangeLogViewState extends State<_GradeChangeLogView> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final values = await Future.wait([_api.myTimetable(), _api.semesters()]);
    final slots = values[0];
    final semesters = values[1];
    final semesterIds = semesters.map((item) => '${item['id']}').toSet();
    final combinations = <String, Map<String, String>>{};
    for (final slot in slots) {
      final classId = '${slot['classId'] ?? ''}';
      final subjectId = '${slot['subjectId'] ?? ''}';
      final slotSemesterId = '${slot['semesterId'] ?? ''}';
      final candidates =
          slotSemesterId.isNotEmpty ? <String>{slotSemesterId} : semesterIds;
      for (final semesterId in candidates) {
        if (classId.isEmpty || semesterId.isEmpty) continue;
        combinations['$classId|$subjectId|$semesterId'] = {
          'classId': classId,
          'subjectId': subjectId,
          'semesterId': semesterId,
        };
      }
    }

    final gradeBatches =
        await Future.wait(combinations.values.map((combo) => _api.grades(
              classId: combo['classId'],
              subjectId:
                  combo['subjectId']!.isEmpty ? null : combo['subjectId'],
              semesterId: combo['semesterId'],
            )));
    final gradesById = <String, Map<String, dynamic>>{};
    for (final batch in gradeBatches) {
      for (final grade in batch) {
        gradesById['${grade['id']}'] = grade;
      }
    }

    final studentNames = <String, String>{};
    final classIds =
        combinations.values.map((item) => item['classId']!).toSet();
    final studentBatches = await Future.wait(
        classIds.map((classId) => _api.classStudents(classId)));
    for (final batch in studentBatches) {
      for (final student in batch) {
        studentNames['${student['id']}'] =
            '${student['fullName'] ?? student['username'] ?? 'Học sinh'}';
      }
    }

    final logBatches = await Future.wait(gradesById.values.map((grade) async {
      final logs = await _api.gradeChangeLogs('${grade['id']}');
      return logs.map((log) => {
            ...log,
            'studentName': studentNames['${grade['studentId']}'] ?? 'Học sinh',
            'subjectName': grade['subjectName'] ?? 'Môn học',
            'categoryName': grade['categoryName'] ?? grade['category'],
          });
    }));
    final result = logBatches.expand((batch) => batch).toList();
    result.sort((a, b) => '${b['changedAt']}'.compareTo('${a['changedAt']}'));
    return result;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại log sửa điểm'),
            ),
          );
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                const SizedBox(height: 180),
                Center(
                  child: Text('Chưa có lịch sử thay đổi điểm.',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final log = logs[i];
              final oldV = (log['oldScore'] as num?)?.toDouble();
              final newV = (log['newScore'] as num?)?.toDouble();
              final up = oldV == null || (newV ?? 0) >= oldV;
              final changedAt = DateTime.tryParse('${log['changedAt']}');
              final time = changedAt == null
                  ? '${log['changedAt'] ?? ''}'
                  : DateFormat('dd/MM HH:mm').format(changedAt.toLocal());
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
                                Text('${log['studentName']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    '${log['subjectName']} — ${log['categoryName']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
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
                                if (oldV != null)
                                  Text(oldV.toStringAsFixed(1),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                if (oldV != null) const SizedBox(width: 4),
                                Icon(
                                  up
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 14,
                                  color:
                                      up ? AppColors.success : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(newV?.toStringAsFixed(1) ?? '—',
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.format_quote_rounded,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('${log['reason'] ?? 'Tạo điểm'}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ),
                            Text(time,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      ),
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

// ===================== PROFILE =====================

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late Future<TeacherScopeSummary> _scopeFuture;

  @override
  void initState() {
    super.initState();
    _scopeFuture = _loadScope();
  }

  Future<TeacherScopeSummary> _loadScope() async {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final results = await Future.wait([
      sl<ApiService>().teachingClasses(),
      sl<ApiService>().myTeachingAssignments(),
    ]);
    return TeacherScopeSummary.fromApi(
      teacherId: user.id,
      classes: results[0],
      assignments: results[1],
    );
  }

  Future<void> _reloadScope() async {
    setState(() => _scopeFuture = _loadScope());
    await _scopeFuture;
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin'),
        backgroundColor: AppColors.teacherAccent,
        actions: [
          IconButton(
            tooltip: 'Cập nhật phân công',
            onPressed: _reloadScope,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const _ChatAction(),
          const _NotiAction(),
        ],
      ),
      body: FutureBuilder<TeacherScopeSummary>(
        future: _scopeFuture,
        builder: (context, snapshot) => RefreshIndicator(
          onRefresh: _reloadScope,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      Text(
                          user.mainSubject == null
                              ? 'Giáo viên'
                              : 'Chuyên môn: ${user.mainSubject}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.class_rounded,
                          color: AppColors.teacherAccent),
                      title: const Text('Lớp chủ nhiệm'),
                      subtitle:
                          Text(snapshot.connectionState != ConnectionState.done
                              ? 'Đang tải...'
                              : snapshot.hasError
                                  ? 'Không thể tải phân công'
                                  : snapshot.data!.homeroomLabel),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.menu_book_rounded,
                          color: AppColors.teacherAccent),
                      title: const Text('Môn giảng dạy'),
                      subtitle:
                          Text(snapshot.connectionState != ConnectionState.done
                              ? 'Đang tải...'
                              : snapshot.hasError
                                  ? 'Không thể tải phân công'
                                  : snapshot.data!.teachingLabel),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.teacherAccent),
                      title: const Text('Trung tâm công việc'),
                      subtitle: const Text('Khảo thí, đơn xin nghỉ và báo cáo',
                          style: TextStyle(fontSize: 11)),
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
                      leading: const Icon(Icons.chat_bubble_outline_rounded,
                          color: AppColors.teacherAccent),
                      title: const Text('Tin nhắn'),
                      subtitle: const Text(
                          'Nhắn tin với học sinh, phụ huynh và gửi thông báo lớp',
                          style: TextStyle(fontSize: 11)),
                      trailing: Icon(Icons.chevron_right_rounded,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
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
                      leading: const Icon(Icons.notifications_outlined,
                          color: AppColors.teacherAccent),
                      title: const Text('Thông báo'),
                      trailing: Icon(Icons.chevron_right_rounded,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
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
                leading:
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Đăng xuất',
                    style: TextStyle(color: AppColors.error)),
                onTap: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  });
  final String id;
  final String title;
  final String subject;
  final String className;
  final String deadline;
  final String status; // DRAFT / PUBLISHED / CLOSED
  final int submitted;
  final int total;
}

class _AssignmentsTab extends StatefulWidget {
  const _AssignmentsTab();
  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab>
    with WidgetsBindingObserver {
  late Future<List<_TAssignment>> _future = _load();
  StreamSubscription<RealtimeEvent>? _assignmentEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _assignmentEvents = realtime.events
        .where((event) => event.type == 'ASSIGNMENT_UPDATED')
        .listen((_) => _reloadAssignments());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reloadAssignments();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _assignmentEvents?.cancel();
    super.dispose();
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
              actions: [
                IconButton(
                    onPressed: _reloadAssignments,
                    icon: const Icon(Icons.refresh_rounded)),
                const _ChatAction(),
                const _NotiAction(),
              ],
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
              child: Text('Không thể tải bài tập.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                _TAssignmentList(
                    items: published, onChanged: _reloadAssignments),
                _TAssignmentList(
                    items: drafts,
                    isDraft: true,
                    onChanged: _reloadAssignments),
                _TAssignmentList(
                    items: closed,
                    isClosed: true,
                    onChanged: _reloadAssignments),
              ],
            ),
          ),
        );
      },
    );
  }

  void _reloadAssignments() => setState(() => _future = _load());

  Future<void> _showCreateSheet(BuildContext ignoredContext) async {
    final api = sl<ApiService>();
    final options = await api.myTeachingAssignments();
    if (!mounted) return;
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bạn chưa có phân công lớp và môn để tạo bài tập.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    var selected = options.first;
    DateTime? deadline;
    PlatformFile? attachment;
    var allowLate = false;
    var saving = false;
    await showModalBottomSheet(
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
                        initialValue: '${selected['id']}',
                        decoration: const InputDecoration(
                            labelText: 'Lớp', isDense: true),
                        items: options
                            .map((assignment) => DropdownMenuItem(
                                  value: '${assignment['id']}',
                                  child: Text(
                                    '${assignment['classCode'] ?? assignment['classId']} · '
                                    '${assignment['subjectName'] ?? assignment['subjectId']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selected = options
                            .firstWhere((item) => '${item['id']}' == value)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả đề bài',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            initialDate: deadline ??
                                DateTime.now().add(const Duration(days: 7)),
                          );
                          if (picked == null || !ctx.mounted) return;
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(
                              deadline ??
                                  DateTime.now().add(const Duration(days: 7)),
                            ),
                          );
                          if (time != null) {
                            setState(() => deadline = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  time.hour,
                                  time.minute,
                                ));
                          }
                        },
                        icon: const Icon(Icons.event_rounded, size: 16),
                        label: Text(deadline == null
                            ? 'Hạn nộp'
                            : DateFormat('dd/MM HH:mm').format(deadline!)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                final result = await FilePicker.platform
                                    .pickFiles(withData: true);
                                if (result == null || !ctx.mounted) return;
                                final file = result.files.single;
                                if (file.size > 10 * 1024 * 1024) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Tệp không được vượt quá 10 MB.'),
                                    ),
                                  );
                                  return;
                                }
                                if (file.bytes == null) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Không thể đọc tệp đã chọn.'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => attachment = file);
                              },
                        icon: const Icon(Icons.attach_file_rounded, size: 16),
                        label: Text(
                          attachment?.name ?? 'Đính kèm tệp',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: allowLate,
                  onChanged: (value) => setState(() => allowLate = value),
                  title: const Text('Cho phép nộp muộn'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                await _saveAssignment(
                                  ctx,
                                  title: titleCtrl.text,
                                  description: descriptionCtrl.text,
                                  selected: selected,
                                  deadline: deadline,
                                  allowLate: allowLate,
                                  attachment: attachment,
                                  publishNow: false,
                                  setBusy: (value) =>
                                      setState(() => saving = value),
                                );
                              },
                        child: const Text('Lưu nháp'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: saving
                            ? null
                            : () async {
                                await _saveAssignment(
                                  ctx,
                                  title: titleCtrl.text,
                                  description: descriptionCtrl.text,
                                  selected: selected,
                                  deadline: deadline,
                                  allowLate: allowLate,
                                  attachment: attachment,
                                  publishNow: true,
                                  setBusy: (value) =>
                                      setState(() => saving = value),
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
    titleCtrl.dispose();
    descriptionCtrl.dispose();
  }

  Future<void> _saveAssignment(
    BuildContext sheetContext, {
    required String title,
    required String description,
    required Map<String, dynamic> selected,
    required DateTime? deadline,
    required bool allowLate,
    required PlatformFile? attachment,
    required bool publishNow,
    required ValueChanged<bool> setBusy,
  }) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng nhập tiêu đề bài tập.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setBusy(true);
    try {
      String? attachmentFileId;
      if (attachment != null) {
        final stored = await sl<ApiService>()
            .uploadFile(attachment.bytes!, attachment.name);
        attachmentFileId = '${stored['id'] ?? ''}';
        if (attachmentFileId.isEmpty) {
          throw StateError('Backend không trả mã tệp');
        }
      }
      await sl<ApiService>().createAssignment({
        'classId': selected['classId'],
        'subjectId': selected['subjectId'],
        'title': title.trim(),
        'description': description.trim(),
        'deadline': deadline?.toUtc().toIso8601String(),
        'allowLate': allowLate,
        'attachmentFileId': attachmentFileId,
        'publishNow': publishNow,
      });
      if (!mounted || !sheetContext.mounted) return;
      Navigator.pop(sheetContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(publishNow ? 'Đã phát hành bài tập.' : 'Đã lưu bản nháp.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      _reloadAssignments();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể lưu bài tập. Vui lòng kiểm tra dữ liệu.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (sheetContext.mounted) setBusy(false);
    }
  }
}

class _TAssignmentList extends StatelessWidget {
  const _TAssignmentList({
    required this.items,
    this.isDraft = false,
    this.isClosed = false,
    this.onChanged,
  });
  final List<_TAssignment> items;
  final bool isDraft;
  final bool isClosed;
  final VoidCallback? onChanged;

  Color _statusColor(BuildContext context, String s) => switch (s) {
        'DRAFT' => Theme.of(context).colorScheme.onSurfaceVariant,
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
      return Center(
          child: Text('Không có bài tập',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = items[i];
        final color = _statusColor(context, a.status);
        final pct = a.total == 0 ? 0.0 : a.submitted / a.total;
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              if (isDraft) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mở form chỉnh sửa bản nháp'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              await Navigator.of(context).push(
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
                      Icon(Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Hạn: ${a.deadline}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.outlineVariant,
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

// ===================== ACTIONS =====================

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
    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatListPage(
            accent: AppColors.teacherAccent,
            allowBroadcast: true,
          ),
        ),
      ),
    );
  }
}
