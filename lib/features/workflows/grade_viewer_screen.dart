import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';

class GradeViewerScreen extends StatefulWidget {
  const GradeViewerScreen({super.key, required this.accent});

  final Color accent;

  @override
  State<GradeViewerScreen> createState() => _GradeViewerScreenState();
}

class _GradeViewerScreenState extends State<GradeViewerScreen> {
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> grades = [];
  String? semesterId;
  bool loading = true;

  bool get isParent => context.read<AppSession>().user?.role == 'PARENT';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final values = await Future.wait([
        context.read<AppSession>().api.list('/semesters'),
        context.read<AppSession>().api.list('/exam-categories'),
      ]);
      semesters = values[0];
      categories = values[1];
      semesterId = semesters.isEmpty ? null : '${semesters.first['id']}';
      await _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message('$error');
    }
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    final session = context.read<AppSession>();
    try {
      final values = await session.api.list(
        '/grades',
        query: {
          if (semesterId != null) 'semesterId': semesterId,
          if (isParent && session.selectedChildId != null)
            'studentId': session.selectedChildId,
        },
      );
      if (!mounted) return;
      setState(() {
        grades = values;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message('$error');
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Map<String, List<Map<String, dynamic>>> get bySubject {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final grade in grades) {
      final key = '${grade['subjectName'] ?? grade['subjectId']}';
      result.putIfAbsent(key, () => []).add(grade);
    }
    return result;
  }

  double? _subjectAverage(List<Map<String, dynamic>> items) {
    var weighted = 0.0;
    var weights = 0.0;
    for (final category in categories) {
      final code = '${category['code'] ?? category['id']}';
      final required = math.max(
        1,
        (category['requiredCount'] as num? ?? 1).toInt(),
      );
      final values = _scores(items, code);
      if (values.length < required) return null;
      final weight = (category['weight'] as num? ?? 1).toDouble();
      weighted +=
          values.take(required).reduce((a, b) => a + b) / required * weight;
      weights += weight;
    }
    return weights == 0 ? null : weighted / weights;
  }

  List<double> _scores(List<Map<String, dynamic>> items, String category) {
    final values =
        items.where((item) => '${item['category']}' == category).toList()..sort(
          (a, b) => (a['assessmentIndex'] as num? ?? 1).compareTo(
            b['assessmentIndex'] as num? ?? 1,
          ),
        );
    return values
        .map((item) => item['score'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
  }

  double? get overallAverage {
    final values = bySubject.values
        .map(_subjectAverage)
        .whereType<double>()
        .toList();
    if (values.isEmpty || values.length < bySubject.length) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  int get completedSubjects =>
      bySubject.values.where((items) => _subjectAverage(items) != null).length;

  String get selectedSemesterName =>
      semesters
          .where((item) => '${item['id']}' == semesterId)
          .map((item) => '${item['name'] ?? item['code']}')
          .firstOrNull ??
      'Học kỳ';

  String _studentName(AppSession session) {
    if (!isParent) return session.user?.fullName ?? 'Học sinh';
    return session.children
            .where((item) => '${item['id']}' == session.selectedChildId)
            .map((item) => '${item['fullName'] ?? item['name']}')
            .firstOrNull ??
        'Học sinh';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả học tập'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          children: [
            _StudentGradeHeader(
              accent: widget.accent,
              studentName: _studentName(session),
              semesterName: selectedSemesterName,
              average: overallAverage,
              completed: completedSubjects,
              totalSubjects: bySubject.length,
            ),
            const SizedBox(height: 14),
            _ViewerFilters(
              isParent: isParent,
              session: session,
              semesters: semesters,
              semesterId: semesterId,
              onChildChanged: (value) async {
                if (value == null) return;
                await session.selectChild(value);
                await _reload();
              },
              onSemesterChanged: (value) {
                semesterId = value;
                _reload();
              },
            ),
            const SizedBox(height: 14),
            if (loading)
              const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (bySubject.isEmpty)
              const EmptyState(
                title: 'Chưa có điểm',
                message: 'Chưa có điểm trong học kỳ đã chọn.',
                icon: Icons.query_stats_outlined,
              )
            else ...[
              _LearningStats(
                accent: widget.accent,
                subjects: bySubject.length,
                completed: completedSubjects,
                gradeEntries: grades.length,
                average: overallAverage,
              ),
              const SizedBox(height: 14),
              _StudentGradeTable(
                accent: widget.accent,
                categories: categories,
                subjects: bySubject,
                scoresOf: _scores,
                averageOf: _subjectAverage,
              ),
              const SizedBox(height: 12),
              const _GradeNote(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentGradeHeader extends StatelessWidget {
  const _StudentGradeHeader({
    required this.accent,
    required this.studentName,
    required this.semesterName,
    required this.average,
    required this.completed,
    required this.totalSubjects,
  });

  final Color accent;
  final String studentName;
  final String semesterName;
  final double? average;
  final int completed;
  final int totalSubjects;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF11284E),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BẢNG ĐIỂM HỌC KỲ',
                style: TextStyle(
                  color: Color(0xFF9DB8E8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                studentName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$semesterName · $completed/$totalSubjects môn đủ đầu điểm',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                average?.toStringAsFixed(1) ?? '—',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'TRUNG BÌNH',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ViewerFilters extends StatelessWidget {
  const _ViewerFilters({
    required this.isParent,
    required this.session,
    required this.semesters,
    required this.semesterId,
    required this.onChildChanged,
    required this.onSemesterChanged,
  });

  final bool isParent;
  final AppSession session;
  final List<Map<String, dynamic>> semesters;
  final String? semesterId;
  final ValueChanged<String?> onChildChanged;
  final ValueChanged<String?> onSemesterChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fields = <Widget>[
            if (isParent)
              DropdownButtonFormField<String>(
                key: ValueKey(session.selectedChildId),
                initialValue: session.selectedChildId,
                decoration: const InputDecoration(
                  labelText: 'Học sinh',
                  prefixIcon: Icon(Icons.family_restroom_outlined),
                ),
                items: session.children
                    .map(
                      (item) => DropdownMenuItem(
                        value: '${item['id']}',
                        child: Text('${item['fullName'] ?? item['name']}'),
                      ),
                    )
                    .toList(),
                onChanged: onChildChanged,
              ),
            DropdownButtonFormField<String>(
              initialValue: semesterId,
              decoration: const InputDecoration(
                labelText: 'Học kỳ',
                prefixIcon: Icon(Icons.date_range_outlined),
              ),
              items: semesters
                  .map(
                    (item) => DropdownMenuItem(
                      value: '${item['id']}',
                      child: Text('${item['name'] ?? item['code']}'),
                    ),
                  )
                  .toList(),
              onChanged: onSemesterChanged,
            ),
          ];
          return constraints.maxWidth >= 620 && fields.length > 1
              ? Row(
                  children:
                      fields
                          .map((field) => Expanded(child: field))
                          .expand((field) => [field, const SizedBox(width: 12)])
                          .toList()
                        ..removeLast(),
                )
              : Column(
                  children:
                      fields
                          .expand(
                            (field) => [field, const SizedBox(height: 12)],
                          )
                          .toList()
                        ..removeLast(),
                );
        },
      ),
    ),
  );
}

class _LearningStats extends StatelessWidget {
  const _LearningStats({
    required this.accent,
    required this.subjects,
    required this.completed,
    required this.gradeEntries,
    required this.average,
  });

  final Color accent;
  final int subjects;
  final int completed;
  final int gradeEntries;
  final double? average;

  @override
  Widget build(BuildContext context) {
    final data = [
      ('Môn học', '$subjects', Icons.menu_book_outlined, accent),
      (
        'Đủ đầu điểm',
        '$completed',
        Icons.verified_outlined,
        const Color(0xFF159A70),
      ),
      (
        'Điểm đã có',
        '$gradeEntries',
        Icons.fact_check_outlined,
        const Color(0xFF6D55D8),
      ),
      (
        'Trung bình',
        average?.toStringAsFixed(1) ?? 'Chưa đủ',
        Icons.analytics_outlined,
        const Color(0xFFE68A2E),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisExtent: 86,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(item.$3, color: item.$4),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

class _StudentGradeTable extends StatelessWidget {
  const _StudentGradeTable({
    required this.accent,
    required this.categories,
    required this.subjects,
    required this.scoresOf,
    required this.averageOf,
  });

  final Color accent;
  final List<Map<String, dynamic>> categories;
  final Map<String, List<Map<String, dynamic>>> subjects;
  final List<double> Function(List<Map<String, dynamic>> items, String category)
  scoresOf;
  final double? Function(List<Map<String, dynamic>> items) averageOf;

  static const subjectWidth = 190.0;
  static const categoryWidth = 145.0;
  static const averageWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    final width =
        subjectWidth + categoryWidth * categories.length + averageWidth;
    final entries = subjects.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.table_chart_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bảng tổng hợp theo môn',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Điểm trung bình chỉ xuất hiện khi đủ tất cả đầu điểm',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Chip(label: Text('Vuốt ngang')),
              ],
            ),
          ),
          const Divider(height: 1),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    _ViewerTableHeader(categories: categories),
                    ...entries.asMap().entries.map(
                      (entry) => _ViewerSubjectRow(
                        index: entry.key,
                        subject: entry.value.key,
                        grades: entry.value.value,
                        categories: categories,
                        accent: accent,
                        scoresOf: scoresOf,
                        average: averageOf(entry.value.value),
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

class _ViewerTableHeader extends StatelessWidget {
  const _ViewerTableHeader({required this.categories});

  final List<Map<String, dynamic>> categories;

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    color: const Color(0xFF11284E),
    child: Row(
      children: [
        const _HeaderCell(
          width: _StudentGradeTable.subjectWidth,
          text: 'MÔN HỌC',
          left: true,
        ),
        ...categories.map(
          (category) => _HeaderCell(
            width: _StudentGradeTable.categoryWidth,
            text: _categoryName(category).toUpperCase(),
          ),
        ),
        const _HeaderCell(
          width: _StudentGradeTable.averageWidth,
          text: 'TB MÔN',
        ),
      ],
    ),
  );
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.width,
    required this.text,
    this.left = false,
  });

  final double width;
  final String text;
  final bool left;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 54,
    alignment: left ? Alignment.centerLeft : Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Color(0x334E6B99))),
    ),
    child: Text(
      text,
      textAlign: left ? TextAlign.left : TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: .3,
      ),
    ),
  );
}

class _ViewerSubjectRow extends StatelessWidget {
  const _ViewerSubjectRow({
    required this.index,
    required this.subject,
    required this.grades,
    required this.categories,
    required this.accent,
    required this.scoresOf,
    required this.average,
  });

  final int index;
  final String subject;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> categories;
  final Color accent;
  final List<double> Function(List<Map<String, dynamic>> items, String category)
  scoresOf;
  final double? average;

  @override
  Widget build(BuildContext context) {
    final background = index.isEven
        ? Theme.of(context).colorScheme.surface
        : (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF111B2B)
              : const Color(0xFFFAFBFD));
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _StudentGradeTable.subjectWidth,
            child: ListTile(
              dense: true,
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_book_outlined, color: accent, size: 18),
              ),
              title: Text(
                subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          ...categories.map((category) {
            final code = '${category['code'] ?? category['id']}';
            final required = math.max(
              1,
              (category['requiredCount'] as num? ?? 1).toInt(),
            );
            final values = scoresOf(grades, code);
            return Container(
              width: _StudentGradeTable.categoryWidth,
              constraints: const BoxConstraints(minHeight: 72),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: List.generate(required, (index) {
                  final score = index < values.length ? values[index] : null;
                  return _ScoreBadge(score: score);
                }),
              ),
            );
          }),
          Container(
            width: _StudentGradeTable.averageWidth,
            constraints: const BoxConstraints(minHeight: 72),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: average == null
                ? const Tooltip(
                    message: 'Chưa đủ đầu điểm',
                    child: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFF9AA5B5),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _scoreColor(
                        average!,
                        context,
                      ).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      average!.toStringAsFixed(1),
                      style: TextStyle(
                        color: _scoreColor(average!, context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double? score;

  @override
  Widget build(BuildContext context) => Container(
    width: 35,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: score == null
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : _scoreColor(score!, context).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      score == null ? '—' : _formatScore(score!),
      style: TextStyle(
        color: score == null
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : _scoreColor(score!, context),
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _GradeNote extends StatelessWidget {
  const _GradeNote();

  @override
  Widget build(BuildContext context) => Card(
    child: const Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF315EFB)),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Điểm trung bình môn và học kỳ được để trống khi chưa đủ đầu điểm theo cấu hình của nhà trường.',
            ),
          ),
        ],
      ),
    ),
  );
}

String _categoryName(Map<String, dynamic> category) {
  final code = '${category['code'] ?? category['id']}';
  return '${category['name'] ?? switch (code) {
        'ORAL' => 'Miệng',
        'QUIZ_15' => '15 phút',
        'ONE_PERIOD' => '1 tiết',
        'MIDTERM' => 'Giữa kỳ',
        'FINAL' => 'Cuối kỳ',
        _ => code,
      }}';
}

String _formatScore(double score) =>
    score == score.toInt() ? '${score.toInt()}' : score.toStringAsFixed(1);

Color _scoreColor(double score, BuildContext context) {
  if (score >= 8) return const Color(0xFF0B8F68);
  if (score >= 6.5) return const Color(0xFF315EFB);
  if (score >= 5) return const Color(0xFFD17A1D);
  return const Color(0xFFD64055);
}
