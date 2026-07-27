import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class TeachingAssignmentScreen extends StatefulWidget {
  const TeachingAssignmentScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<TeachingAssignmentScreen> createState() =>
      _TeachingAssignmentScreenState();
}

class _TeachingAssignmentScreenState extends State<TeachingAssignmentScreen> {
  final search = TextEditingController();
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> assignments = [];
  List<Map<String, dynamic>> workloads = [];
  String? semesterId;
  String? teacherFilter;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list('/users', query: {'role': 'TEACHER'}),
        api.list('/classes'),
        api.list('/subjects'),
        api.list('/semesters'),
      ]);
      if (!mounted) return;
      teachers = values[0];
      classes = values[1];
      subjects = values[2];
      semesters = values[3];
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
    if (semesterId == null) {
      if (mounted) setState(() => loading = false);
      return;
    }
    setState(() => loading = true);
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list(
          '/teaching-assignments',
          query: {
            'semesterId': semesterId,
            if (teacherFilter != null) 'teacherId': teacherFilter,
          },
        ),
        api.list(
          '/teaching-assignments/workloads',
          query: {'semesterId': semesterId},
        ),
      ]);
      if (!mounted) return;
      setState(() {
        assignments = values[0];
        workloads = values[1];
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  String _name(Map<String, dynamic> item) =>
      '${item['fullName'] ?? item['name'] ?? item['code'] ?? item['id']}';

  Future<void> _addBatch() async {
    if (teachers.isEmpty || subjects.isEmpty || classes.isEmpty) {
      _message('Cần có giáo viên, môn học và lớp trước khi phân công.');
      return;
    }
    String teacherId = '${teachers.first['id']}';
    String subjectId = '${subjects.first['id']}';
    final selected = <String>{};
    final periods = <String, TextEditingController>{};
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm phân công bộ môn'),
          content: SizedBox(
            width: 620,
            height: 580,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: teacherId,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(labelText: 'Giáo viên bộ môn'),
                  items: teachers
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text(_name(item)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => teacherId = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: subjectId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Môn phụ trách'),
                  items: subjects
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text(_name(item)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => subjectId = value!),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chọn nhiều lớp và số tiết riêng cho từng lớp',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final item = classes[index];
                      final id = '${item['id']}';
                      periods.putIfAbsent(
                        id,
                        () => TextEditingController(text: '4'),
                      );
                      final alreadyAssigned = assignments.any(
                        (assignment) =>
                            '${assignment['classId']}' == id &&
                            '${assignment['subjectId']}' == subjectId,
                      );
                      return Card(
                        color: selected.contains(id)
                            ? widget.accent.withValues(alpha: .08)
                            : null,
                        child: CheckboxListTile(
                          value: selected.contains(id),
                          onChanged: alreadyAssigned
                              ? null
                              : (value) => setDialogState(() {
                                  if (value == true) {
                                    selected.add(id);
                                  } else {
                                    selected.remove(id);
                                  }
                                }),
                          title: Text(_name(item)),
                          subtitle: Text(
                            alreadyAssigned
                                ? 'Môn này đã được phân công cho lớp'
                                : '${item['gradeLevel'] ?? ''} · ${item['studyShift'] == 'AFTERNOON' ? 'Ca chiều' : 'Ca sáng'}',
                          ),
                          secondary: SizedBox(
                            width: 90,
                            child: TextField(
                              controller: periods[id],
                              enabled:
                                  selected.contains(id) && !alreadyAssigned,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: 'Tiết/tuần',
                              ),
                            ),
                          ),
                        ),
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
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: Text('Phân công ${selected.length} lớp'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) {
      for (final controller in periods.values) {
        controller.dispose();
      }
      return;
    }
    final entries = <Map<String, dynamic>>[];
    for (final id in selected) {
      final value = int.tryParse(periods[id]!.text.trim());
      if (value == null || value < 1 || value > 20) {
        _message('Số tiết mỗi lớp phải từ 1 đến 20.');
        return;
      }
      entries.add({'classId': id, 'weeklyPeriods': value});
    }
    try {
      await context.read<AppSession>().api.dio.post(
        '/teaching-assignments/batch',
        data: {
          'teacherId': teacherId,
          'subjectId': subjectId,
          'semesterId': semesterId,
          'assignments': entries,
        },
      );
      if (mounted) {
        _message('Đã phân công ${entries.length} lớp.');
        await _reload();
      }
    } catch (error) {
      if (mounted) _message(_friendly(error));
    } finally {
      for (final controller in periods.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final controller =
        TextEditingController(text: '${item['weeklyPeriods'] ?? 1}');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa số tiết giảng dạy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item['teacherName']} · ${item['subjectName']} · Lớp ${item['classCode']}',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiết/tuần'),
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
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    final weeklyPeriods = int.tryParse(controller.text.trim());
    controller.dispose();
    if (accepted != true || weeklyPeriods == null || !mounted) return;
    try {
      await context
          .read<AppSession>()
          .api
          .put('/teaching-assignments/${item['id']}', {
            'classId': item['classId'],
            'subjectId': item['subjectId'],
            'teacherId': item['teacherId'],
            'semesterId': item['semesterId'],
            'weeklyPeriods': weeklyPeriods,
          });
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phân công?'),
        content: Text(
          '${item['teacherName']} sẽ không còn phụ trách ${item['subjectName']} tại lớp ${item['classCode']}.',
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
      await context
          .read<AppSession>()
          .api
          .delete('/teaching-assignments/${item['id']}');
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  String _friendly(Object error) {
    final value = '$error';
    if (value.contains('409')) {
      return 'Phân công bị trùng hoặc giáo viên không còn đủ tải.';
    }
    if (value.contains('400')) {
      return 'Dữ liệu phân công chưa hợp lệ.';
    }
    return 'Không thể cập nhật phân công. Vui lòng thử lại.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  List<Map<String, dynamic>> get filtered {
    final term = search.text.trim().toLowerCase();
    if (term.isEmpty) return assignments;
    return assignments
        .where(
          (item) =>
              '${item['teacherName']} ${item['subjectName']} ${item['classCode']}'
                  .toLowerCase()
                  .contains(term),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Phân công bộ môn'),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: loading ? null : _addBatch,
      backgroundColor: widget.accent,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Thêm phân công'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 300,
                child: SearchBar(
                  controller: search,
                  hintText: 'Tìm giáo viên, lớp hoặc môn',
                  leading: const Icon(Icons.search_rounded),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: semesterId,
                  decoration: const InputDecoration(labelText: 'Học kỳ'),
                  items: semesters
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text(_name(item)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    semesterId = value;
                    _reload();
                  },
                ),
              ),
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: teacherFilter,
                  decoration:
                      const InputDecoration(labelText: 'Lọc giáo viên'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tất cả giáo viên'),
                    ),
                    ...teachers.map(
                      (item) => DropdownMenuItem(
                        value: '${item['id']}',
                        child: Text(_name(item)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    teacherFilter = value;
                    _reload();
                  },
                ),
              ),
            ],
          ),
        ),
        if (workloads.isNotEmpty)
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: workloads.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = workloads[index];
                return SizedBox(
                  width: 250,
                  child: Card(
                    color: widget.accent.withValues(alpha: .07),
                    child: ListTile(
                      title: Text('${item['teacherName']}'),
                      subtitle: Text(
                        '${item['classCount']} lớp · ${item['weeklyPeriods']} tiết/tuần\nĐã xếp ${item['scheduledPeriods']} tiết',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
              ? const Center(child: Text('Không có phân công phù hợp.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final remaining =
                        (item['remainingPeriods'] as num? ?? 0).toInt();
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor:
                              widget.accent.withValues(alpha: .1),
                          child: Icon(
                            Icons.assignment_ind_outlined,
                            color: widget.accent,
                          ),
                        ),
                        title: Text('${item['teacherName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['subjectName']} · Lớp ${item['classCode']}',
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (item['weeklyPeriods'] as num? ?? 1) == 0
                                  ? 0
                                  : ((item['scheduledPeriods'] as num? ?? 0) /
                                            (item['weeklyPeriods'] as num))
                                        .clamp(0, 1)
                                        .toDouble(),
                              color: remaining == 0
                                  ? Colors.green
                                  : widget.accent,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item['scheduledPeriods']}/${item['weeklyPeriods']} tiết đã xếp · Còn $remaining tiết',
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _edit(item);
                            if (value == 'delete') _delete(item);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa số tiết'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa phân công'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
