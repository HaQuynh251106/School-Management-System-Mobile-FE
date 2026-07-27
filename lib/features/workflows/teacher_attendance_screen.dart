import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  late Future<List<Map<String, dynamic>>> slotsFuture;
  List<Map<String, dynamic>> slots = [];
  List<Map<String, dynamic>> students = [];
  final status = <String, String>{};
  String? slotId;
  DateTime date = DateTime.now();
  bool loading = false;
  bool saving = false;
  Map<String, dynamic>? sessionStatus;

  @override
  void initState() {
    super.initState();
    slotsFuture = context.read<AppSession>().api.list('/me/timetable');
    slotsFuture.then((value) {
      if (mounted) setState(() => slots = value);
    });
  }

  String get dateText => DateFormat('yyyy-MM-dd').format(date);

  Future<void> selectSlot(String id) async {
    final slot = slots.firstWhere((item) => '${item['id']}' == id);
    setState(() {
      slotId = id;
      loading = true;
      students = [];
    });
    try {
      final results = await Future.wait([
        context
            .read<AppSession>()
            .api
            .list('/classes/${slot['classId']}/students'),
        context.read<AppSession>().api.list('/attendance', query: {
          'slotId': id,
          'date': dateText,
        }),
        context.read<AppSession>().api.map('/attendance/session-status', query: {
          'slotId': id,
          'date': dateText,
        }),
      ]);
      final roster = results[0] as List<Map<String, dynamic>>;
      final existing = results[1] as List<Map<String, dynamic>>;
      status
        ..clear()
        ..addEntries(
          roster.map((student) {
            final current = existing.cast<Map<String, dynamic>?>().firstWhere(
                  (mark) => '${mark?['studentId']}' == '${student['id']}',
                  orElse: () => null,
                );
            return MapEntry(
              '${student['id']}',
              '${current?['status'] ?? 'PRESENT'}',
            );
          }),
        );
      setState(() {
        students = roster;
        sessionStatus = results[2] as Map<String, dynamic>;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở sổ điểm danh: $error')),
      );
    }
  }

  Future<void> chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (selected == null) return;
    setState(() => date = selected);
    if (slotId != null) await selectSlot(slotId!);
  }

  Future<void> unlock() async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở khóa điểm danh'),
        content: TextField(
          controller: reason,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Lý do điểm danh muộn',
            helperText: 'Cần ít nhất 10 ký tự',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mở khóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || reason.text.trim().length < 10 || !mounted) return;
    await context.read<AppSession>().api.post('/attendance/unlock', {
      'slotId': slotId,
      'date': dateText,
      'reason': reason.text.trim(),
    });
    await selectSlot(slotId!);
  }

  Future<void> save() async {
    if (slotId == null || students.isEmpty) return;
    setState(() => saving = true);
    try {
      await context.read<AppSession>().api.dio.post('/attendance/bulk', data: {
        'slotId': slotId,
        'date': dateText,
        'marks': students
            .map(
              (student) => {
                'studentId': student['id'],
                'status': status['${student['id']}'] ?? 'PRESENT',
              },
            )
            .toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã lưu điểm danh và tự động thông báo thay đổi tới gia đình.',
          ),
        ),
      );
      await selectSlot(slotId!);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu: $error')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sổ điểm danh')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: slotsFuture,
                    builder: (context, snapshot) => DropdownButtonFormField<String>(
                      initialValue: slotId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tiết học đúng phân công',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      items: (snapshot.data ?? [])
                          .map(
                            (slot) => DropdownMenuItem(
                              value: '${slot['id']}',
                              child: Text(
                                '${slot['classCode'] ?? slot['classId']} · ${slot['subjectName']} · Tiết ${slot['periodNo']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectSlot(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: chooseDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(date)),
                  ),
                  if (sessionStatus != null &&
                      sessionStatus!['canMark'] == false) ...[
                    const SizedBox(height: 10),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        title: Text('${sessionStatus!['message']}'),
                        trailing: sessionStatus!['requiresUnlockReason'] == true
                            ? FilledButton(
                                onPressed: unlock,
                                child: const Text('Mở khóa'),
                              )
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : slotId == null
                      ? const Center(child: Text('Chọn một tiết học để bắt đầu'))
                      : students.isEmpty
                          ? const Center(child: Text('Lớp chưa có học sinh'))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                              itemCount: students.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final student = students[index];
                                final id = '${student['id']}';
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text('${student['fullName']}'),
                                    subtitle: Text(
                                      '${student['studentCode'] ?? ''}',
                                    ),
                                    trailing: DropdownButton<String>(
                                      value: status[id] ?? 'PRESENT',
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'PRESENT',
                                          child: Text('Có mặt'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'LATE',
                                          child: Text('Đi muộn'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ABSENT_EXCUSED',
                                          child: Text('Vắng phép'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ABSENT_UNEXCUSED',
                                          child: Text('Vắng'),
                                        ),
                                      ],
                                      onChanged: (value) => setState(
                                        () => status[id] = value ?? 'PRESENT',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
        floatingActionButton: students.isEmpty ||
                sessionStatus?['canMark'] == false
            ? null
            : FloatingActionButton.extended(
                onPressed: saving ? null : save,
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.save),
                label: Text(saving ? 'Đang lưu...' : 'Lưu điểm danh'),
              ),
      );
}
