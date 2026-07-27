import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

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

  bool get isParent =>
      context.read<AppSession>().user?.role == 'PARENT';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final values = await Future.wait([
      context.read<AppSession>().api.list('/semesters'),
      context.read<AppSession>().api.list('/exam-categories'),
    ]);
    semesters = values[0];
    categories = values[1];
    semesterId = semesters.isEmpty ? null : '${semesters.first['id']}';
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    final session = context.read<AppSession>();
    try {
      final values = await session.api.list('/grades', query: {
        if (semesterId != null) 'semesterId': semesterId,
        if (isParent && session.selectedChildId != null)
          'studentId': session.selectedChildId,
      });
      if (!mounted) return;
      setState(() {
        grades = values;
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    }
  }

  String _category(String value) => switch (value) {
    'ORAL' => 'Kiểm tra miệng',
    'QUIZ_15' => 'Kiểm tra 15 phút',
    'ONE_PERIOD' => 'Kiểm tra một tiết',
    'MIDTERM' => 'Giữa kỳ',
    'FINAL' => 'Cuối kỳ',
    _ => value,
  };

  Map<String, List<Map<String, dynamic>>> get bySubject {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final grade in grades) {
      final key = '${grade['subjectName'] ?? grade['subjectId']}';
      result.putIfAbsent(key, () => []).add(grade);
    }
    return result;
  }

  double? _finalAverage(List<Map<String, dynamic>> items) {
    var weighted = 0.0;
    var weights = 0.0;
    for (final category in categories) {
      final code = '${category['code'] ?? category['id']}';
      final required = (category['requiredCount'] as num? ?? 1).toInt();
      final scores = items
          .where((item) => '${item['category']}' == code)
          .map((item) => item['score'])
          .whereType<num>()
          .map((value) => value.toDouble())
          .toList();
      if (scores.length < required) return null;
      final weight = (category['weight'] as num? ?? 1).toDouble();
      final average =
          scores.take(required).reduce((a, b) => a + b) / required;
      weighted += average * weight;
      weights += weight;
    }
    return weights == 0 ? null : weighted / weights;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điểm'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (isParent)
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
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
                              child: Text(
                                '${item['fullName'] ?? item['name']}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        session.selectChild(value);
                        await _reload();
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
                            child: Text('${item['name'] ?? item['code']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      semesterId = value;
                      _reload();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : bySubject.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có điểm trong học kỳ đã chọn.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: bySubject.entries.map((entry) {
                      final average = _finalAverage(entry.value);
                      entry.value.sort(
                        (a, b) =>
                            (a['assessmentIndex'] as num? ?? 1).compareTo(
                              b['assessmentIndex'] as num? ?? 1,
                            ),
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        widget.accent.withValues(alpha: .1),
                                    child: Icon(
                                      Icons.menu_book_outlined,
                                      color: widget.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      average == null
                                          ? 'Chưa đủ đầu điểm'
                                          : 'TB ${average.toStringAsFixed(1)}',
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: entry.value.map((grade) {
                                  return Container(
                                    width: 165,
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_category('${grade['category']}')} ${grade['assessmentIndex'] ?? 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${grade['score'] ?? '—'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: widget.accent,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
