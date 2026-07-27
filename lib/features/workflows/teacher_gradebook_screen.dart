import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class TeacherGradebookScreen extends StatefulWidget {
  const TeacherGradebookScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<TeacherGradebookScreen> createState() =>
      _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? contextData;
  String? classId;
  String? semesterId;
  String category = 'ORAL';
  int assessmentIndex = 1;
  bool loading = true;
  bool saving = false;
  final scores = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    for (final controller in scores.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.list('/me/teaching-classes'),
        api.list('/semesters'),
        api.list('/exam-categories'),
      ]);
      if (!mounted) return;
      setState(() {
        classes = values[0];
        semesters = values[1];
        categories = values[2];
        classId = classes.isEmpty ? null : '${classes.first['id']}';
        semesterId = semesters.isEmpty ? null : '${semesters.first['id']}';
        if (categories.isNotEmpty) {
          category = '${categories.first['code'] ?? categories.first['id']}';
        }
        loading = false;
      });
      await _loadGradebook();
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message('$error');
    }
  }

  Future<void> _loadGradebook() async {
    if (classId == null || semesterId == null) return;
    setState(() => loading = true);
    final api = context.read<AppSession>().api;
    try {
      final values = await Future.wait([
        api.get(
          '/me/gradebook-context',
          query: {'classId': classId, 'semesterId': semesterId},
        ),
        api.list('/classes/$classId/students'),
        api.list(
          '/grades',
          query: {
            'classId': classId,
            'semesterId': semesterId,
            'category': category,
          },
        ),
      ]);
      final gradebookContext =
          Map<String, dynamic>.from(values[0] as Map);
      final loadedStudents = (values[1] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final grades = (values[2] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .where(
            (item) =>
                (item['assessmentIndex'] ?? 1).toString() ==
                assessmentIndex.toString(),
          )
          .toList();
      for (final controller in scores.values) {
        controller.dispose();
      }
      scores.clear();
      for (final student in loadedStudents) {
        final id = '${student['id']}';
        final found = grades.where((item) => '${item['studentId']}' == id);
        scores[id] = TextEditingController(
          text: found.isEmpty ? '' : '${found.first['score'] ?? ''}',
        );
      }
      if (!mounted) return;
      setState(() {
        contextData = gradebookContext;
        students = loadedStudents;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message('$error');
    }
  }

  Future<void> _save() async {
    final entries = <Map<String, dynamic>>[];
    for (final entry in scores.entries) {
      final raw = entry.value.text.trim().replaceAll(',', '.');
      if (raw.isEmpty) continue;
      final score = double.tryParse(raw);
      if (score == null || score < 0 || score > 10) {
        _message('Điểm phải là số từ 0 đến 10.');
        return;
      }
      entries.add({'studentId': entry.key, 'score': score});
    }
    if (entries.isEmpty) {
      _message('Hãy nhập ít nhất một điểm.');
      return;
    }
    setState(() => saving = true);
    try {
      await context.read<AppSession>().api.dio.post('/grades/bulk', data: {
        'classId': classId,
        'subjectId': contextData?['subjectId'],
        'semesterId': semesterId,
        'category': category,
        'assessmentIndex': assessmentIndex,
        'entries': entries,
      });
      if (!mounted) return;
      _message('Đã lưu bảng điểm.');
      await _loadGradebook();
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _name(Map<String, dynamic> item) =>
      '${item['name'] ?? item['fullName'] ?? item['className'] ?? item['code'] ?? item['id']}';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bảng điểm')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadGradebook,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn lớp và học kỳ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: classId,
                          decoration: const InputDecoration(labelText: 'Lớp'),
                          items: classes
                              .map(
                                (item) => DropdownMenuItem(
                                  value: '${item['id']}',
                                  child: Text(_name(item)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            classId = value;
                            _loadGradebook();
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: semesterId,
                          decoration:
                              const InputDecoration(labelText: 'Học kỳ'),
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
                            _loadGradebook();
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: category,
                                decoration: const InputDecoration(
                                  labelText: 'Đầu điểm',
                                ),
                                items: categories
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value:
                                            '${item['code'] ?? item['id']}',
                                        child: Text(_name(item)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  category = value;
                                  _loadGradebook();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 120,
                              child: DropdownButtonFormField<int>(
                                initialValue: assessmentIndex,
                                decoration:
                                    const InputDecoration(labelText: 'Lần'),
                                items: List.generate(
                                  3,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  assessmentIndex = value ?? 1;
                                  _loadGradebook();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: widget.accent.withValues(alpha: .08),
                  child: ListTile(
                    leading: Icon(Icons.menu_book_rounded, color: widget.accent),
                    title: Text(
                      '${contextData?['subjectName'] ?? 'Môn học được phân công'}',
                    ),
                    subtitle: Text(
                      contextData?['canEdit'] == true
                          ? 'Bạn có quyền cập nhật điểm môn đang phụ trách.'
                          : 'Chỉ xem: đây không phải môn bạn phụ trách.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (students.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: Text('Lớp chưa có học sinh.')),
                    ),
                  )
                else
                  ...students.asMap().entries.map((entry) {
                    final student = entry.value;
                    final id = '${student['id']}';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${entry.key + 1}')),
                        title: Text(_name(student)),
                        subtitle: Text('${student['code'] ?? id}'),
                        trailing: SizedBox(
                          width: 82,
                          child: TextField(
                            controller: scores[id],
                            enabled: contextData?['canEdit'] == true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: '—',
                              suffixText: '/10',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
    floatingActionButton:
        contextData?['canEdit'] == true && students.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: saving ? null : _save,
            backgroundColor: widget.accent,
            foregroundColor: Colors.white,
            icon: saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Lưu điểm'),
          )
        : null,
  );
}
