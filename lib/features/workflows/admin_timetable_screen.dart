import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../../core/widgets/timetable_grid.dart';

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> assignments = [];
  List<Map<String, dynamic>> slots = [];
  String? classId;
  String? semesterId;
  bool loading = true;

  static const days = <(String, String)>[
    ('MON', 'Thứ 2'),
    ('TUE', 'Thứ 3'),
    ('WED', 'Thứ 4'),
    ('THU', 'Thứ 5'),
    ('FRI', 'Thứ 6'),
    ('SAT', 'Thứ 7'),
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list('/classes'),
        api.list('/semesters'),
        api.list('/rooms'),
      ]);
      if (!mounted) return;
      classes = values[0];
      semesters = values[1];
      rooms = values[2];
      classId = classes.isEmpty ? null : '${classes.first['id']}';
      semesterId = semesters.isEmpty ? null : '${semesters.first['id']}';
      await _reload();
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _reload() async {
    if (classId == null || semesterId == null) {
      if (mounted) setState(() => loading = false);
      return;
    }
    setState(() => loading = true);
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list(
          '/timetableSlots',
          query: {'classId': classId, 'semesterId': semesterId},
        ),
        api.list(
          '/teaching-assignments',
          query: {'classId': classId, 'semesterId': semesterId},
        ),
      ]);
      if (!mounted) return;
      setState(() {
        slots = values[0]
          ..sort((a, b) {
            final dayA = days.indexWhere((d) => d.$1 == '${a['dayOfWeek']}');
            final dayB = days.indexWhere((d) => d.$1 == '${b['dayOfWeek']}');
            final dayCompare = dayA.compareTo(dayB);
            if (dayCompare != 0) return dayCompare;
            return (a['periodNo'] as num? ?? 0).compareTo(
              b['periodNo'] as num? ?? 0,
            );
          });
        assignments = values[1];
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  String _label(Map<String, dynamic> item) =>
      '${item['name'] ?? item['classCode'] ?? item['code'] ?? item['id']}';

  Future<void> _edit([Map<String, dynamic>? slot]) async {
    if (assignments.isEmpty) {
      _message('Lớp chưa được phân công giáo viên bộ môn.');
      return;
    }
    final candidates = slot == null
        ? assignments
              .where(
                (item) =>
                    (item['remainingPeriods'] as num? ?? 0) > 0 &&
                    item['fullyScheduled'] != true,
              )
              .toList()
        : assignments;
    if (candidates.isEmpty) {
      _message('Tất cả phân công của lớp đã được xếp đủ số tiết trong tuần.');
      return;
    }
    String? assignmentId;
    if (slot != null) {
      final match = candidates.where(
        (item) =>
            '${item['teacherId']}' == '${slot['teacherId']}' &&
            '${item['subjectId']}' == '${slot['subjectId']}',
      );
      if (match.isNotEmpty) assignmentId = '${match.first['id']}';
    }
    assignmentId ??= '${candidates.first['id']}';
    String day = '${slot?['dayOfWeek'] ?? 'MON'}';
    int period = (slot?['periodNo'] as num?)?.toInt() ?? 1;
    String start = '${slot?['startTime'] ?? '07:00'}';
    String end = '${slot?['endTime'] ?? '07:45'}';
    String? roomCode = slot?['roomCode']?.toString();
    final formKey = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selected = candidates.firstWhere(
            (item) => '${item['id']}' == assignmentId,
            orElse: () => candidates.first,
          );
          return AlertDialog(
            title: Text(slot == null ? 'Xếp tiết học' : 'Sửa tiết học'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: assignmentId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Môn học và giáo viên',
                        ),
                        items: candidates
                            .map(
                              (item) => DropdownMenuItem(
                                value: '${item['id']}',
                                child: Text(
                                  '${item['subjectName']} · ${item['teacherName']} (${item['scheduledPeriods']}/${item['weeklyPeriods']} tiết)',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => assignmentId = value),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: day,
                              decoration: const InputDecoration(
                                labelText: 'Thứ',
                              ),
                              items: days
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value.$1,
                                      child: Text(value.$2),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setDialogState(() => day = value!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: period,
                              decoration: const InputDecoration(
                                labelText: 'Tiết',
                              ),
                              items: List.generate(
                                12,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('Tiết ${index + 1}'),
                                ),
                              ),
                              onChanged: (value) {
                                final shift = _selectedClass()['studyShift'];
                                final preset = _timePreset(
                                  value ?? 1,
                                  '$shift',
                                );
                                setDialogState(() {
                                  period = value ?? 1;
                                  start = preset.$1;
                                  end = preset.$2;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('start-$start'),
                              initialValue: start,
                              decoration: const InputDecoration(
                                labelText: 'Bắt đầu',
                                hintText: '07:00',
                              ),
                              validator: _timeValidator,
                              onSaved: (value) => start = value!.trim(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('end-$end'),
                              initialValue: end,
                              decoration: const InputDecoration(
                                labelText: 'Kết thúc',
                                hintText: '07:45',
                              ),
                              validator: _timeValidator,
                              onSaved: (value) => end = value!.trim(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: roomCode,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Phòng học',
                        ),
                        items: rooms
                            .where((room) {
                              final shift = '${room['studyShift'] ?? ''}';
                              final classShift =
                                  '${_selectedClass()['studyShift'] ?? ''}';
                              return shift.isEmpty || shift == classShift;
                            })
                            .map(
                              (room) => DropdownMenuItem(
                                value: '${room['code']}',
                                child: Text(_label(room)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => roomCode = value),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selected['availabilityMessage']?.toString() ??
                              'Hệ thống sẽ kiểm tra trùng lịch giáo viên, lớp và phòng.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
    if (accepted != true || !mounted) return;
    final assignment = candidates.firstWhere(
      (item) => '${item['id']}' == assignmentId,
    );
    final payload = {
      'classId': classId,
      'subjectId': assignment['subjectId'],
      'teacherId': assignment['teacherId'],
      'roomCode': roomCode,
      'dayOfWeek': day,
      'periodNo': period,
      'startTime': start,
      'endTime': end,
      'semesterId': semesterId,
    };
    try {
      final api = context.read<AppSession>().api;
      if (slot == null) {
        await api.post('/timetableSlots', payload);
      } else {
        await api.put('/timetableSlots/${slot['id']}', payload);
      }
      if (mounted) {
        _message('Đã lưu thời khóa biểu.');
        await _reload();
      }
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Map<String, dynamic> _selectedClass() => classes.firstWhere(
    (item) => '${item['id']}' == classId,
    orElse: () => const {},
  );

  (String, String) _timePreset(int period, String shift) {
    const morning = [
      ('07:00', '07:45'),
      ('07:50', '08:35'),
      ('08:45', '09:30'),
      ('09:35', '10:20'),
      ('10:25', '11:10'),
      ('11:15', '12:00'),
    ];
    const afternoon = [
      ('13:00', '13:45'),
      ('13:50', '14:35'),
      ('14:45', '15:30'),
      ('15:35', '16:20'),
      ('16:25', '17:10'),
      ('17:15', '18:00'),
    ];
    final source = shift == 'AFTERNOON' ? afternoon : morning;
    return source[(period - 1).clamp(0, source.length - 1)];
  }

  String? _timeValidator(String? value) =>
      value != null &&
          RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value.trim())
      ? null
      : 'Dùng định dạng HH:mm';

  Future<void> _delete(Map<String, dynamic> slot) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tiết học?'),
        content: Text(
          '${slot['subjectName']} · ${_dayLabel('${slot['dayOfWeek']}')} · Tiết ${slot['periodNo']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    try {
      await context.read<AppSession>().api.delete(
        '/timetableSlots/${slot['id']}',
      );
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  String _dayLabel(String value) =>
      days.where((item) => item.$1 == value).firstOrNull?.$2 ?? value;

  String _friendly(Object error) {
    final text = '$error';
    if (text.contains('409') || text.toLowerCase().contains('conflict')) {
      return 'Không thể xếp tiết vì giáo viên, lớp hoặc phòng đang bị trùng lịch.';
    }
    if (text.contains('400')) {
      return 'Thông tin tiết học chưa hợp lệ hoặc vượt số tiết đã phân công.';
    }
    return 'Không thể thực hiện. Vui lòng kiểm tra lại dữ liệu.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  void _slotActions(Map<String, dynamic> slot) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${slot['subjectName'] ?? 'Tiết học'} · Tiết ${slot['periodNo']}',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              '${slot['teacherName'] ?? 'Chưa có giáo viên'} · Phòng ${slot['roomCode'] ?? '—'}',
              style: Theme.of(sheetContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _edit(slot);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Sửa tiết học'),
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _delete(slot);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Xóa tiết học'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final selectedClass = _selectedClass();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xếp thời khóa biểu'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _edit,
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Xếp tiết'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: const InputDecoration(
                        labelText: 'Lớp học',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      items: classes
                          .map(
                            (item) => DropdownMenuItem(
                              value: '${item['id']}',
                              child: Text(_label(item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        classId = value;
                        _reload();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      initialValue: semesterId,
                      decoration: const InputDecoration(
                        labelText: 'Học kỳ',
                        prefixIcon: Icon(Icons.date_range_outlined),
                      ),
                      items: semesters
                          .map(
                            (item) => DropdownMenuItem(
                              value: '${item['id']}',
                              child: Text(_label(item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        semesterId = value;
                        _reload();
                      },
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      '${selectedClass['studyShift']}' == 'AFTERNOON'
                          ? Icons.wb_twilight_outlined
                          : Icons.wb_sunny_outlined,
                      size: 18,
                    ),
                    label: Text(
                      '${selectedClass['studyShift']}' == 'AFTERNOON'
                          ? 'Ca chiều'
                          : 'Ca sáng',
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.assignment_ind_outlined, size: 18),
                    label: Text('${assignments.length} phân công'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.view_week_outlined, size: 18),
                    label: Text('${slots.length} tiết đã xếp'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : slots.isEmpty
                ? const EmptyState(
                    title: 'Lớp chưa có thời khóa biểu',
                    message: 'Chọn “Xếp tiết” để bắt đầu xây dựng lịch học.',
                    icon: Icons.calendar_view_week_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                color: widget.accent,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  'Chạm vào một ô để sửa hoặc xóa tiết học',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              const Chip(label: Text('Vuốt ngang')),
                            ],
                          ),
                        ),
                      ),
                      TimetableGrid(
                        slots: slots,
                        accent: widget.accent,
                        onSlotTap: _slotActions,
                        showClass: false,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
