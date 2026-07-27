import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../modules/create_record_sheet.dart';

class AdminExamScreen extends StatefulWidget {
  const AdminExamScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<AdminExamScreen> createState() => _AdminExamScreenState();
}

class _AdminExamScreenState extends State<AdminExamScreen> {
  List<Map<String, dynamic>> periods = [];
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> teachers = [];
  String? selectedId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list('/subjects'),
        api.list('/classes'),
        api.list('/users', query: {'role': 'TEACHER'}),
      ]);
      subjects = values[0];
      classes = values[1];
      teachers = values[2];
      await _reload();
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    final api = context.read<AppSession>().api;
    try {
      final loaded = await api.list('/exam-periods');
      selectedId ??= loaded.isEmpty
          ? null
          : '${loaded.first['period']?['id'] ?? loaded.first['id']}';
      final loadedSchedules = selectedId == null
          ? <Map<String, dynamic>>[]
          : await api.list('/exam-periods/$selectedId/schedules');
      if (!mounted) return;
      setState(() {
        periods = loaded;
        schedules = loadedSchedules;
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Map<String, dynamic> _periodOf(Map<String, dynamic> item) =>
      item['period'] is Map
      ? Map<String, dynamic>.from(item['period'] as Map)
      : item;

  Map<String, dynamic>? get selectedSummary {
    for (final item in periods) {
      if ('${_periodOf(item)['id']}' == selectedId) return item;
    }
    return null;
  }

  Map<String, dynamic>? get selectedPeriod =>
      selectedSummary == null ? null : _periodOf(selectedSummary!);

  Future<void> _createPeriod() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          CreateRecordSheet(kind: 'examPeriod', accent: widget.accent),
    );
    if (changed == true) _reload();
  }

  Future<void> _periodAction(String action, String success) async {
    if (selectedId == null) return;
    try {
      await context
          .read<AppSession>()
          .api
          .post('/exam-periods/$selectedId/$action', const {});
      if (mounted) {
        _message(success);
        await _reload();
      }
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _deletePeriod() async {
    if (selectedId == null) return;
    final accepted = await _confirm(
      'Xóa kỳ thi?',
      'Chỉ kỳ thi chưa phát hành và chưa có kết quả mới có thể xóa.',
    );
    if (!accepted || !mounted) return;
    try {
      await context
          .read<AppSession>()
          .api
          .delete('/exam-periods/$selectedId');
      selectedId = null;
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _schedule([Map<String, dynamic>? item]) async {
    if (selectedId == null) return;
    String subjectId =
        '${item?['subjectId'] ?? (subjects.isEmpty ? '' : subjects.first['id'])}';
    final selectedClasses = <String>{
      ...(item?['classIds'] as List? ?? const []).map((value) => '$value'),
    };
    if (selectedClasses.isEmpty && classes.isNotEmpty) {
      selectedClasses.add('${classes.first['id']}');
    }
    final date =
        TextEditingController(text: '${item?['examDate'] ?? ''}');
    final start =
        TextEditingController(text: '${item?['startTime'] ?? '07:30'}');
    final duration = TextEditingController(
      text: '${item?['durationMinutes'] ?? 90}',
    );
    final notes = TextEditingController(text: '${item?['notes'] ?? ''}');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Tạo lịch thi' : 'Sửa lịch thi'),
          content: SizedBox(
            width: 600,
            height: 580,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: subjectId.isEmpty ? null : subjectId,
                  decoration: const InputDecoration(labelText: 'Môn thi'),
                  items: subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: '${subject['id']}',
                          child: Text('${subject['name']}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => subjectId = value!,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: date,
                        decoration: const InputDecoration(
                          labelText: 'Ngày thi',
                          hintText: '2026-10-15',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: start,
                        decoration: const InputDecoration(
                          labelText: 'Bắt đầu',
                          hintText: '07:30',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: duration,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Số phút'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lớp dự thi',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classItem = classes[index];
                      final id = '${classItem['id']}';
                      return CheckboxListTile(
                        value: selectedClasses.contains(id),
                        title: Text(
                          '${classItem['name'] ?? classItem['code']}',
                        ),
                        subtitle:
                            Text('Khối ${classItem['gradeLevel'] ?? ''}'),
                        onChanged: (value) => setDialogState(() {
                          if (value == true) {
                            selectedClasses.add(id);
                          } else {
                            selectedClasses.remove(id);
                          }
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: selectedClasses.isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Lưu lịch thi'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    final payload = {
      'subjectId': subjectId,
      'classIds': selectedClasses.toList(),
      'examDate': date.text.trim(),
      'startTime': start.text.trim(),
      'durationMinutes': int.tryParse(duration.text.trim()) ?? 90,
      'notes': notes.text.trim(),
    };
    try {
      final api = context.read<AppSession>().api;
      if (item == null) {
        await api.post('/exam-periods/$selectedId/schedules', payload);
      } else {
        await api.put('/exam-schedules/${item['id']}', payload);
      }
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    } finally {
      date.dispose();
      start.dispose();
      duration.dispose();
      notes.dispose();
    }
  }

  Future<void> _deleteSchedule(Map<String, dynamic> item) async {
    final accepted = await _confirm(
      'Xóa lịch thi?',
      'Phòng thi, số báo danh và kết quả liên quan có thể bị ảnh hưởng.',
    );
    if (!accepted || !mounted) return;
    try {
      await context
          .read<AppSession>()
          .api
          .delete('/exam-schedules/${item['id']}');
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _rooms(Map<String, dynamic> schedule) async {
    var rooms = await context
        .read<AppSession>()
        .api
        .list('/exam-schedules/${schedule['id']}/rooms');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Phòng thi · ${schedule['subjectName']}'),
          content: SizedBox(
            width: 560,
            height: 430,
            child: rooms.isEmpty
                ? const Center(child: Text('Chưa phân phòng thi.'))
                : ListView.separated(
                    itemCount: rooms.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return ListTile(
                        leading: const Icon(Icons.meeting_room_outlined),
                        title: Text('Phòng ${room['roomCode']}'),
                        subtitle: Text(
                          'Sức chứa ${room['capacity']} · Giám thị ${room['proctorNames'] ?? 'chưa phân'}',
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final api =
                                context.read<AppSession>().api;
                            await api.delete('/exam-rooms/${room['id']}');
                            rooms = await api.list(
                              '/exam-schedules/${schedule['id']}/rooms',
                            );
                            if (dialogContext.mounted) setDialogState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final created = await _addRoom(schedule);
                if (created && context.mounted) {
                  rooms = await context
                      .read<AppSession>()
                      .api
                      .list('/exam-schedules/${schedule['id']}/rooms');
                  setDialogState(() {});
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm phòng'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _addRoom(Map<String, dynamic> schedule) async {
    final roomCode = TextEditingController();
    final capacity = TextEditingController(text: '30');
    String? proctorOne;
    String? proctorTwo;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm phòng thi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomCode,
                decoration: const InputDecoration(labelText: 'Mã phòng'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sức chứa'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: proctorOne,
                decoration: const InputDecoration(labelText: 'Giám thị 1'),
                items: teachers
                    .map(
                      (teacher) => DropdownMenuItem(
                        value: '${teacher['id']}',
                        child: Text('${teacher['fullName']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => proctorOne = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: proctorTwo,
                decoration: const InputDecoration(labelText: 'Giám thị 2'),
                items: teachers
                    .map(
                      (teacher) => DropdownMenuItem(
                        value: '${teacher['id']}',
                        child: Text('${teacher['fullName']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => proctorTwo = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Thêm phòng'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return false;
    try {
      await context.read<AppSession>().api.post(
        '/exam-schedules/${schedule['id']}/rooms',
        {
          'roomCode': roomCode.text.trim(),
          'capacity': int.tryParse(capacity.text.trim()) ?? 30,
          'proctorOneId': proctorOne,
          'proctorTwoId': proctorTwo,
        },
      );
      return true;
    } catch (error) {
      if (mounted) _message(_friendly(error));
      return false;
    } finally {
      roomCode.dispose();
      capacity.dispose();
    }
  }

  Future<bool> _confirm(String title, String content) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ) ??
      false;

  String _friendly(Object error) {
    final value = '$error';
    if (value.contains('409')) {
      return 'Lịch thi bị trùng lớp, môn, phòng hoặc giám thị.';
    }
    if (value.contains('400')) {
      return 'Kỳ thi chưa đủ lịch, phòng hoặc thí sinh để thực hiện.';
    }
    return 'Không thể xử lý dữ liệu khảo thí.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _classCodes(Map<String, dynamic> schedule) {
    final ids = (schedule['classIds'] as List? ?? const [])
        .map((value) => '$value')
        .toSet();
    return classes
        .where((item) => ids.contains('${item['id']}'))
        .map((item) => '${item['code'] ?? item['name']}')
        .join(', ');
  }

  String _periodStatus(String value) => switch (value) {
    'OPEN' => 'Đang mở',
    'CONFIRMED' => 'Đã xác nhận',
    'CLOSED' => 'Đã kết thúc',
    _ => 'Bản nháp',
  };

  @override
  Widget build(BuildContext context) {
    final period = selectedPeriod;
    final status = '${period?['status'] ?? 'DRAFT'}';
    final published = period?['schedulePublishedAt'] != null ||
        period?['schedulePublished'] == true;
    final locked = period?['scoreEntryLocked'] == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khảo thí và lịch thi'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPeriod,
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo kỳ thi'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : periods.isEmpty
          ? const Center(child: Text('Chưa có kỳ thi.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              children: [
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: periods.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final summary = periods[index];
                      final item = _periodOf(summary);
                      final selected = '${item['id']}' == selectedId;
                      return SizedBox(
                        width: 330,
                        child: Card(
                          color: selected
                              ? widget.accent.withValues(alpha: .1)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: selected
                                  ? widget.accent
                                  : Colors.transparent,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              selectedId = '${item['id']}';
                              _reload();
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['name']}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text('${item['startDate']} – ${item['endDate']}'),
                                  const Spacer(),
                                  Text(
                                    '${summary['scheduleCount'] ?? 0} môn · ${summary['candidateCount'] ?? 0} thí sinh · ${_periodStatus('${item['status'] ?? 'DRAFT'}')}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (!published)
                          FilledButton.icon(
                            onPressed: schedules.isEmpty
                                ? null
                                : () => _periodAction(
                                    'publish-schedule',
                                    'Đã công bố lịch thi.',
                                  ),
                            icon: const Icon(Icons.campaign_outlined),
                            label: const Text('Công bố lịch'),
                          ),
                        if (status != 'CONFIRMED')
                          OutlinedButton.icon(
                            onPressed: () => _periodAction(
                              'confirm',
                              'Đã xác nhận kỳ thi.',
                            ),
                            icon: const Icon(Icons.verified_outlined),
                            label: const Text('Xác nhận kỳ thi'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => _periodAction(
                            locked ? 'unlock-scores' : 'lock-scores',
                            locked
                                ? 'Đã mở nhập điểm.'
                                : 'Đã khóa nhập điểm.',
                          ),
                          icon: Icon(
                            locked
                                ? Icons.lock_open_rounded
                                : Icons.lock_outline_rounded,
                          ),
                          label: Text(
                            locked ? 'Mở nhập điểm' : 'Khóa nhập điểm',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Xóa kỳ thi',
                          onPressed: _deletePeriod,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lịch thi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _schedule(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Thêm môn thi'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (schedules.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: Text('Kỳ thi chưa có lịch thi.')),
                    ),
                  )
                else
                  ...schedules.map(
                    (item) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              widget.accent.withValues(alpha: .1),
                          child: Icon(
                            Icons.event_note_outlined,
                            color: widget.accent,
                          ),
                        ),
                        title: Text('${item['subjectName'] ?? item['subjectId']}'),
                        subtitle: Text(
                          '${item['examDate']} · ${item['startTime']} · ${item['durationMinutes']} phút · Lớp ${_classCodes(item)}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rooms') _rooms(item);
                            if (value == 'edit') _schedule(item);
                            if (value == 'delete') _deleteSchedule(item);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'rooms',
                              child: Text('Phòng và giám thị'),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa lịch thi'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa lịch thi'),
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
}
