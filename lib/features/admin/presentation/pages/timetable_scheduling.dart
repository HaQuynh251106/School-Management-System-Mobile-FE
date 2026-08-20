import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'teaching_assignments_page.dart';

class TimetableSchedulingPage extends StatefulWidget {
  const TimetableSchedulingPage({super.key});

  @override
  State<TimetableSchedulingPage> createState() =>
      _TimetableSchedulingPageState();
}

class _TimetableSchedulingPageState extends State<TimetableSchedulingPage> {
  static const _days = [
    ('MON', 'T2'),
    ('TUE', 'T3'),
    ('WED', 'T4'),
    ('THU', 'T5'),
    ('FRI', 'T6'),
    ('SAT', 'T7'),
  ];
  static const _periods = [1, 2, 3, 4, 5];
  static const _times = {
    1: ('07:00', '07:45'),
    2: ('07:50', '08:35'),
    3: ('08:50', '09:35'),
    4: ('09:40', '10:25'),
    5: ('10:30', '11:15'),
  };

  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _assignments = [];
  String? _classId;
  String? _semesterId;
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
        _api.classes(),
        _api.semesters(),
        _api.rooms(),
      ]);
      _classes = values[0];
      _semesters = values[1];
      _rooms = values[2];
      if (_classId == null && _classes.isNotEmpty) {
        _classId = _classes.first['id']?.toString();
      }
      if (_semesterId == null && _semesters.isNotEmpty) {
        _semesterId = _semesters.first['id']?.toString();
      }
      await _loadSlots(showLoader: false);
    } catch (error) {
      _showError(
        apiErrorMessage(
          error,
          fallback: 'Không thể tải dữ liệu thời khóa biểu. Vui lòng thử lại.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSlots({bool showLoader = true}) async {
    if (_classId == null || _semesterId == null) {
      _slots = [];
      return;
    }
    if (showLoader && mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _api.timetableSlots(classId: _classId!, semesterId: _semesterId!),
        _api.teachingAssignments(classId: _classId!, semesterId: _semesterId!),
      ]);
      _slots = values[0];
      _assignments = values[1];
    } catch (error) {
      _showError(
        apiErrorMessage(
          error,
          fallback: 'Không thể tải thời khóa biểu. Vui lòng thử lại.',
        ),
      );
    } finally {
      if (showLoader && mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic>? _slot(String day, int period) {
    for (final slot in _slots) {
      if (slot['dayOfWeek'] == day && slot['periodNo'] == period) return slot;
    }
    return null;
  }

  Future<void> _openAssignments() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TeachingAssignmentsPage()));
    await _loadSlots();
  }

  Future<void> _autoSchedule() async {
    if (_semesterId == null) return;
    final selectedDays = _days.map((day) => day.$1).toSet();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tự xếp thời khóa biểu'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chọn các ngày được phép xếp tiết học trong tuần.'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _days.map((day) {
                    return FilterChip(
                      label: Text(day.$2),
                      selected: selectedDays.contains(day.$1),
                      onSelected: (selected) => setDialogState(() {
                        if (selected) {
                          selectedDays.add(day.$1);
                        } else {
                          selectedDays.remove(day.$1);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ngày nghỉ/lễ theo lịch cụ thể không xóa TKB tuần. Ứng dụng sẽ hiển thị nghỉ và bỏ điểm danh trong ngày đó.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton.icon(
              onPressed: selectedDays.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Xem trước'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final preview = await _api.autoPlanTimetable(
        _semesterId!,
        allowedDays: selectedDays.toList(),
      );
      if (!mounted) return;
      final proposed = (preview['proposedSlots'] as num?)?.toInt() ?? 0;
      final unscheduled = (preview['unscheduledSlots'] as num?)?.toInt() ?? 0;
      final warnings =
          (preview['warnings'] as List?)?.cast<Object>() ?? const [];
      final shouldApply = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Kết quả xem trước'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Có thể xếp: $proposed tiết'),
                  Text(
                    'Chưa xếp được: $unscheduled tiết',
                    style: TextStyle(
                      color: unscheduled == 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (warnings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Cảnh báo',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    for (final warning in warnings.take(8))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $warning',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Quay lại'),
            ),
            FilledButton(
              onPressed: unscheduled > 0
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Áp dụng lịch'),
            ),
          ],
        ),
      );
      if (shouldApply != true) return;
      await _api.autoPlanTimetable(
        _semesterId!,
        apply: true,
        allowedDays: selectedDays.toList(),
      );
      await _loadSlots(showLoader: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã áp dụng thời khóa biểu tự động.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showError(
        apiErrorMessage(
          error,
          fallback: 'Không thể tự xếp thời khóa biểu. Vui lòng thử lại.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xếp thời khóa biểu'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
            onPressed: _loading || _semesterId == null ? null : _autoSchedule,
            tooltip: 'Tự xếp thời khóa biểu',
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
          IconButton(
            onPressed: _openAssignments,
            tooltip: 'Phân công giáo viên bộ môn',
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          IconButton(
            onPressed: _loading ? null : _loadStructure,
            tooltip: 'Tải lại dữ liệu',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _filters(),
          Container(
            width: double.infinity,
            color: AppColors.adminAccent.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Đã xếp ${_assignments.fold<int>(0, (sum, item) => sum + ((item['scheduledPeriods'] as num?)?.toInt() ?? 0))}/${_assignments.fold<int>(0, (sum, item) => sum + ((item['weeklyPeriods'] as num?)?.toInt() ?? 0))} tiết theo phân công · ${_assignments.where((item) => item['fullyScheduled'] == true).length}/${_assignments.length} môn đã đủ lịch',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAssignments,
                  icon: const Icon(Icons.tune_rounded, size: 17),
                  label: const Text('Phân công'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _classes.isEmpty || _semesters.isEmpty
                ? const Center(
                    child: Text('Cần tạo lớp và học kỳ trước khi xếp lịch'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 42),
                              ..._days.map((day) => _HeaderCell(text: day.$2)),
                            ],
                          ),
                          for (final period in _periods)
                            Row(
                              children: [
                                _PeriodCell(period: period),
                                ..._days.map((day) {
                                  final slot = _slot(day.$1, period);
                                  return _GridCell(
                                    slot: slot,
                                    onTap: () =>
                                        _editSlot(day.$1, period, slot),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(12),
      child: Row(
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
              onChanged: (value) async {
                setState(() => _classId = value);
                await _loadSlots();
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
              onChanged: (value) async {
                setState(() => _semesterId = value);
                await _loadSlots();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editSlot(
    String day,
    int period,
    Map<String, dynamic>? current,
  ) async {
    if (_classId == null || _semesterId == null) return;
    List<Map<String, dynamic>> available;
    try {
      available = await _api.teachingAssignments(
        classId: _classId!,
        semesterId: _semesterId!,
        dayOfWeek: current == null ? day : null,
        periodNo: current == null ? period : null,
      );
    } catch (error) {
      _showError(
        apiErrorMessage(
          error,
          fallback: 'Không thể kiểm tra lịch giáo viên. Vui lòng thử lại.',
        ),
      );
      return;
    }
    if (!mounted) return;
    String? assignmentId;
    if (current != null) {
      for (final item in available) {
        if (item['subjectId']?.toString() == current['subjectId']?.toString() &&
            item['teacherId']?.toString() == current['teacherId']?.toString()) {
          assignmentId = item['id']?.toString();
          break;
        }
      }
    }
    String? roomCode = current?['roomCode']?.toString();
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          Map<String, dynamic>? selected;
          for (final item in available) {
            if (item['id']?.toString() == assignmentId) selected = item;
          }
          final canSave =
              selected != null &&
              (current != null || selected['canSchedule'] == true);
          final hasSchedulable = available.any(
            (item) => item['canSchedule'] == true,
          );
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_days.firstWhere((item) => item.$1 == day).$2} · Tiết $period',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Chỉ hiển thị giáo viên bộ môn đã được phân công cho lớp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: assignmentId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Phân công giảng dạy',
                    ),
                    items: available
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['id']?.toString(),
                            enabled:
                                current != null || item['canSchedule'] == true,
                            child: Text(
                              '${item['subjectName']} · ${item['teacherName']} · lớp này ${item['scheduledPeriods']}/${item['weeklyPeriods']} tiết · tổng ${item['teacherClassCount']} lớp',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => assignmentId = value),
                  ),
                  if (available.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Lớp chưa có phân công bộ môn. Hãy tạo phân công trước khi xếp lịch.',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  if (current == null &&
                      available.isNotEmpty &&
                      !hasSchedulable)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tất cả phân công của lớp đã đủ số tiết mỗi tuần.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Để xếp thêm, hãy tăng số tiết/tuần của môn hoặc sửa một tiết đang có.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pop(sheetContext, 'assignments'),
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text('Điều chỉnh phân công'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  ...available
                      .where((item) => item['canSchedule'] != true)
                      .map(
                        (item) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item['subjectName']} · ${item['teacherName']}: ${item['availabilityMessage']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    initialValue: roomCode,
                    decoration: const InputDecoration(labelText: 'Phòng học'),
                    items: _rooms
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['code'].toString(),
                            child: Text(item['code'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => roomCode = value),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (current != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pop(sheetContext, 'delete'),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            label: const Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: canSave
                              ? () => Navigator.pop(sheetContext, 'save')
                              : null,
                          child: Text(
                            current == null ? 'Thêm tiết' : 'Lưu thay đổi',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (action == null) return;
    if (action == 'assignments') {
      await _openAssignments();
      return;
    }
    try {
      if (action == 'delete' && current != null) {
        await _api.deleteTimetableSlot(current['id'].toString());
      } else if (action == 'save') {
        final selected = available.firstWhere(
          (item) => item['id']?.toString() == assignmentId,
        );
        final time = _times[period]!;
        final data = <String, dynamic>{
          'classId': _classId,
          'subjectId': selected['subjectId'],
          'teacherId': selected['teacherId'],
          'roomCode': roomCode,
          'dayOfWeek': day,
          'periodNo': period,
          'startTime': time.$1,
          'endTime': time.$2,
          'semesterId': _semesterId,
        };
        if (current == null) {
          await _api.createTimetableSlot(data);
        } else {
          await _api.updateTimetableSlot(current['id'].toString(), data);
        }
      }
      await _loadSlots();
    } catch (error) {
      await _loadSlots();
      _showError(
        apiErrorMessage(
          error,
          fallback: 'Không thể lưu tiết học. Vui lòng thử lại.',
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: 104,
    height: 38,
    alignment: Alignment.center,
    color: AppColors.adminAccent,
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

class _PeriodCell extends StatelessWidget {
  const _PeriodCell({required this.period});
  final int period;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 72,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.adminAccent.withValues(alpha: 0.06),
      border: Border.all(color: AppColors.divider),
    ),
    child: Text(
      'T$period',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.adminAccent,
      ),
    ),
  );
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.slot, required this.onTap});
  final Map<String, dynamic>? slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      width: 104,
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: slot == null
            ? AppColors.background
            : AppColors.adminAccent.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.divider),
      ),
      child: slot == null
          ? const Icon(
              Icons.add_rounded,
              color: AppColors.textSecondary,
              size: 20,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot!['subjectName']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminAccent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  slot!['teacherName']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  slot!['roomCode']?.toString() ?? 'Không phòng',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
    ),
  );
}
