import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';

class TeacherGradebookScreen extends StatefulWidget {
  const TeacherGradebookScreen({super.key, required this.accent});

  final Color accent;

  @override
  State<TeacherGradebookScreen> createState() => _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? contextData;
  String? classId;
  String? semesterId;
  bool loading = true;
  bool saving = false;
  final scores = <String, TextEditingController>{};

  List<({Map<String, dynamic> category, int index})> get columns => [
    for (final category in categories)
      for (
        var index = 1;
        index <= math.max(1, (category['requiredCount'] as num? ?? 1).toInt());
        index++
      )
        (category: category, index: index),
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  void _clearControllers() {
    for (final controller in scores.values) {
      controller.dispose();
    }
    scores.clear();
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
      classes = values[0];
      semesters = values[1];
      categories = values[2];
      classId = classes.isEmpty ? null : '${classes.first['id']}';
      semesterId = semesters.isEmpty ? null : '${semesters.first['id']}';
      await _loadGradebook();
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message('$error');
    }
  }

  Future<void> _loadGradebook() async {
    if (classId == null || semesterId == null) {
      setState(() => loading = false);
      return;
    }
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
          query: {'classId': classId, 'semesterId': semesterId},
        ),
      ]);
      final gradebookContext = Map<String, dynamic>.from(values[0] as Map);
      final loadedStudents = (values[1] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final grades = (values[2] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      _clearControllers();
      for (final student in loadedStudents) {
        final studentId = '${student['id']}';
        for (final column in columns) {
          final code = '${column.category['code'] ?? column.category['id']}';
          final matches = grades.where(
            (item) =>
                '${item['studentId']}' == studentId &&
                '${item['category']}' == code &&
                (item['assessmentIndex'] as num? ?? 1).toInt() == column.index,
          );
          scores[_key(studentId, code, column.index)] = TextEditingController(
            text: matches.isEmpty ? '' : _formatScore(matches.first['score']),
          );
        }
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
    final requests = <Future<dynamic>>[];
    for (final column in columns) {
      final code = '${column.category['code'] ?? column.category['id']}';
      final entries = <Map<String, dynamic>>[];
      for (final student in students) {
        final studentId = '${student['id']}';
        final raw =
            scores[_key(studentId, code, column.index)]?.text.trim().replaceAll(
              ',',
              '.',
            ) ??
            '';
        if (raw.isEmpty) continue;
        final score = double.tryParse(raw);
        if (score == null || score < 0 || score > 10) {
          _message('Điểm phải là số từ 0 đến 10.');
          return;
        }
        entries.add({'studentId': studentId, 'score': score});
      }
      if (entries.isEmpty) continue;
      requests.add(
        context.read<AppSession>().api.dio.post(
          '/grades/bulk',
          data: {
            'classId': classId,
            'subjectId': contextData?['subjectId'],
            'semesterId': semesterId,
            'category': code,
            'assessmentIndex': column.index,
            'entries': entries,
          },
        ),
      );
    }
    if (requests.isEmpty) {
      _message('Hãy nhập ít nhất một điểm.');
      return;
    }
    setState(() => saving = true);
    try {
      await Future.wait(requests);
      if (!mounted) return;
      _message('Đã lưu toàn bộ bảng điểm.');
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
      '${item['name'] ?? item['fullName'] ?? item['className'] ?? item['code'] ?? ''}';

  String _key(String studentId, String category, int index) =>
      '$studentId|$category|$index';

  String _formatScore(dynamic value) {
    if (value is num && value.toDouble() == value.toInt()) {
      return '${value.toInt()}';
    }
    return '${value ?? ''}';
  }

  int get filledCells => scores.values
      .where((controller) => controller.text.trim().isNotEmpty)
      .length;

  double? get enteredAverage {
    final values = scores.values
        .map(
          (controller) =>
              double.tryParse(controller.text.trim().replaceAll(',', '.')),
        )
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bảng điểm môn học'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _loadGradebook,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    floatingActionButton: contextData?['canEdit'] == true && students.isNotEmpty
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
            label: const Text('Lưu bảng điểm'),
          )
        : null,
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadGradebook,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
              children: [
                _GradebookHeader(
                  accent: widget.accent,
                  subjectName:
                      '${contextData?['subjectName'] ?? 'Môn được phân công'}',
                  className: classes
                      .where((item) => '${item['id']}' == classId)
                      .map(_name)
                      .firstOrNull,
                  canEdit: contextData?['canEdit'] == true,
                ),
                const SizedBox(height: 14),
                _Filters(
                  classes: classes,
                  semesters: semesters,
                  classId: classId,
                  semesterId: semesterId,
                  nameOf: _name,
                  onClassChanged: (value) {
                    classId = value;
                    _loadGradebook();
                  },
                  onSemesterChanged: (value) {
                    semesterId = value;
                    _loadGradebook();
                  },
                ),
                const SizedBox(height: 14),
                _GradebookStats(
                  accent: widget.accent,
                  studentCount: students.length,
                  filled: filledCells,
                  total: students.length * columns.length,
                  average: enteredAverage,
                ),
                const SizedBox(height: 14),
                if (students.isEmpty)
                  const EmptyState(
                    title: 'Lớp chưa có học sinh',
                    message: 'Danh sách học sinh sẽ xuất hiện tại đây.',
                    icon: Icons.groups_2_outlined,
                  )
                else
                  _ProfessionalGradeTable(
                    accent: widget.accent,
                    students: students,
                    categories: categories,
                    columns: columns,
                    controllers: scores,
                    canEdit: contextData?['canEdit'] == true,
                    nameOf: _name,
                    keyOf: _key,
                    onChanged: () => setState(() {}),
                  ),
              ],
            ),
          ),
  );
}

class _GradebookHeader extends StatelessWidget {
  const _GradebookHeader({
    required this.accent,
    required this.subjectName,
    required this.className,
    required this.canEdit,
  });

  final Color accent;
  final String subjectName;
  final String? className;
  final bool canEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF11284E),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A102A56),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.table_chart_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${className ?? 'Chưa chọn lớp'} · Bảng điểm học kỳ',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: (canEdit ? const Color(0xFF22C38E) : Colors.white)
                .withValues(alpha: canEdit ? .2 : .1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            canEdit ? 'Được nhập điểm' : 'Chỉ xem',
            style: TextStyle(
              color: canEdit ? const Color(0xFF7CF0C7) : Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.classes,
    required this.semesters,
    required this.classId,
    required this.semesterId,
    required this.nameOf,
    required this.onClassChanged,
    required this.onSemesterChanged,
  });

  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> semesters;
  final String? classId;
  final String? semesterId;
  final String Function(Map<String, dynamic>) nameOf;
  final ValueChanged<String?> onClassChanged;
  final ValueChanged<String?> onSemesterChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;
          final classField = DropdownButtonFormField<String>(
            initialValue: classId,
            decoration: const InputDecoration(
              labelText: 'Lớp học',
              prefixIcon: Icon(Icons.groups_2_outlined),
            ),
            items: classes
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(nameOf(item)),
                  ),
                )
                .toList(),
            onChanged: onClassChanged,
          );
          final semesterField = DropdownButtonFormField<String>(
            initialValue: semesterId,
            decoration: const InputDecoration(
              labelText: 'Học kỳ',
              prefixIcon: Icon(Icons.date_range_outlined),
            ),
            items: semesters
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(nameOf(item)),
                  ),
                )
                .toList(),
            onChanged: onSemesterChanged,
          );
          return wide
              ? Row(
                  children: [
                    Expanded(child: classField),
                    const SizedBox(width: 12),
                    Expanded(child: semesterField),
                  ],
                )
              : Column(
                  children: [
                    classField,
                    const SizedBox(height: 12),
                    semesterField,
                  ],
                );
        },
      ),
    ),
  );
}

class _GradebookStats extends StatelessWidget {
  const _GradebookStats({
    required this.accent,
    required this.studentCount,
    required this.filled,
    required this.total,
    required this.average,
  });

  final Color accent;
  final int studentCount;
  final int filled;
  final int total;
  final double? average;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Sĩ số', '$studentCount', Icons.groups_2_outlined, accent),
      (
        'Đã nhập',
        '$filled/$total',
        Icons.check_circle_outline_rounded,
        const Color(0xFF159A70),
      ),
      (
        'Còn thiếu',
        '${math.max(0, total - filled)}',
        Icons.pending_actions_outlined,
        const Color(0xFFE68A2E),
      ),
      (
        'TB đã nhập',
        average?.toStringAsFixed(1) ?? '—',
        Icons.analytics_outlined,
        const Color(0xFF6D55D8),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.$3, color: item.$4),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodySmall,
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

class _ProfessionalGradeTable extends StatelessWidget {
  const _ProfessionalGradeTable({
    required this.accent,
    required this.students,
    required this.categories,
    required this.columns,
    required this.controllers,
    required this.canEdit,
    required this.nameOf,
    required this.keyOf,
    required this.onChanged,
  });

  final Color accent;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> categories;
  final List<({Map<String, dynamic> category, int index})> columns;
  final Map<String, TextEditingController> controllers;
  final bool canEdit;
  final String Function(Map<String, dynamic>) nameOf;
  final String Function(String, String, int) keyOf;
  final VoidCallback onChanged;

  static const studentWidth = 230.0;
  static const scoreWidth = 96.0;

  @override
  Widget build(BuildContext context) {
    final totalWidth = studentWidth + scoreWidth * columns.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.table_rows_rounded),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh sách điểm học sinh',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Cuộn ngang để xem đầy đủ các đầu điểm',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    canEdit ? Icons.edit_outlined : Icons.lock_outline_rounded,
                    size: 16,
                  ),
                  label: Text(canEdit ? 'Có thể chỉnh sửa' : 'Đã khóa'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: [
                    _CategoryHeader(
                      categories: categories,
                      columns: columns,
                      accent: accent,
                    ),
                    _AssessmentHeader(columns: columns, accent: accent),
                    ...students.asMap().entries.map(
                      (entry) => _StudentGradeRow(
                        index: entry.key,
                        student: entry.value,
                        columns: columns,
                        controllers: controllers,
                        canEdit: canEdit,
                        accent: accent,
                        nameOf: nameOf,
                        keyOf: keyOf,
                        onChanged: onChanged,
                      ),
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

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.categories,
    required this.columns,
    required this.accent,
  });

  final List<Map<String, dynamic>> categories;
  final List<({Map<String, dynamic> category, int index})> columns;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    color: const Color(0xFF11284E),
    child: Row(
      children: [
        const SizedBox(
          width: _ProfessionalGradeTable.studentWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'HỌC SINH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        ),
        ...categories.map((category) {
          final code = '${category['code'] ?? category['id']}';
          final count = columns
              .where(
                (column) =>
                    '${column.category['code'] ?? column.category['id']}' ==
                    code,
              )
              .length;
          return Container(
            width: _ProfessionalGradeTable.scoreWidth * count,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0x334E6B99))),
            ),
            child: Text(
              _categoryName(category).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }),
      ],
    ),
  );
}

class _AssessmentHeader extends StatelessWidget {
  const _AssessmentHeader({required this.columns, required this.accent});

  final List<({Map<String, dynamic> category, int index})> columns;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1B293D)
        : const Color(0xFFF1F4F8),
    child: Row(
      children: [
        const SizedBox(width: _ProfessionalGradeTable.studentWidth),
        ...columns.map(
          (column) => Container(
            width: _ProfessionalGradeTable.scoreWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Text(
              'Lần ${column.index}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class _StudentGradeRow extends StatelessWidget {
  const _StudentGradeRow({
    required this.index,
    required this.student,
    required this.columns,
    required this.controllers,
    required this.canEdit,
    required this.accent,
    required this.nameOf,
    required this.keyOf,
    required this.onChanged,
  });

  final int index;
  final Map<String, dynamic> student;
  final List<({Map<String, dynamic> category, int index})> columns;
  final Map<String, TextEditingController> controllers;
  final bool canEdit;
  final Color accent;
  final String Function(Map<String, dynamic>) nameOf;
  final String Function(String, String, int) keyOf;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final studentId = '${student['id']}';
    final background = index.isEven
        ? Theme.of(context).colorScheme.surface
        : (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF111B2B)
              : const Color(0xFFFAFBFD));
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _ProfessionalGradeTable.studentWidth,
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 17,
                backgroundColor: accent.withValues(alpha: .1),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Text(
                nameOf(student),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${student['code'] ?? ''}'),
            ),
          ),
          ...columns.map((column) {
            final code = '${column.category['code'] ?? column.category['id']}';
            final controller =
                controllers[keyOf(studentId, code, column.index)];
            return Container(
              width: _ProfessionalGradeTable.scoreWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: TextField(
                controller: controller,
                enabled: canEdit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,2}([.,]\d?)?$'),
                  ),
                ],
                onChanged: (_) => onChanged(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _scoreColor(
                    double.tryParse(
                      controller?.text.replaceAll(',', '.') ?? '',
                    ),
                    context,
                  ),
                  fontWeight: FontWeight.w900,
                ),
                decoration: const InputDecoration(
                  hintText: '—',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 11,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _categoryName(Map<String, dynamic> category) {
  final code = '${category['code'] ?? category['id']}';
  return '${category['name'] ?? switch (code) {
        'ORAL' => 'Kiểm tra miệng',
        'QUIZ_15' => 'Kiểm tra 15 phút',
        'ONE_PERIOD' => 'Kiểm tra 1 tiết',
        'MIDTERM' => 'Giữa kỳ',
        'FINAL' => 'Cuối kỳ',
        _ => code,
      }}';
}

Color _scoreColor(double? score, BuildContext context) {
  if (score == null) return Theme.of(context).colorScheme.onSurfaceVariant;
  if (score >= 8) return const Color(0xFF0B8F68);
  if (score >= 6.5) return const Color(0xFF315EFB);
  if (score >= 5) return const Color(0xFFD17A1D);
  return const Color(0xFFD64055);
}
