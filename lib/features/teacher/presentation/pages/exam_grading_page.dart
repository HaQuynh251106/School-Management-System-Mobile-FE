import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class ExamGradingPage extends StatefulWidget {
  const ExamGradingPage({super.key});

  @override
  State<ExamGradingPage> createState() => _ExamGradingPageState();
}

class _ExamGradingPageState extends State<ExamGradingPage> {
  final _api = sl<ApiService>();
  late Future<List<List<Map<String, dynamic>>>> _future = _load();

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
    _api.examGradingTasks(),
    _api.examReviews(status: 'PENDING'),
  ]);

  Future<void> _reload() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chấm thi và phúc khảo'),
      backgroundColor: AppColors.teacherAccent,
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ExamError(error: snapshot.error, retry: _reload);
        }
        final data = snapshot.data ?? const [];
        final tasks = data.isEmpty ? <Map<String, dynamic>>[] : data[0];
        final reviews = data.length < 2 ? <Map<String, dynamic>>[] : data[1];
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Danh sách chấm thi',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (tasks.isEmpty)
                const _EmptyExam(text: 'Chưa có môn-lớp được phân công chấm.')
              else
                ...tasks.map(
                  (task) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.teacherAccent.withValues(
                          alpha: .12,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.teacherAccent,
                        ),
                      ),
                      title: Text(
                        '${task['subjectName']} · ${task['classCode']}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${task['examPeriodName']}\n${task['candidates'] is List ? (task['candidates'] as List).length : 0} thí sinh · ${task['scoreEntryLocked'] == true
                            ? 'Đã khóa điểm'
                            : task['scoreEntryAvailable'] == true
                            ? 'Được nhập điểm'
                            : 'Chưa đến giờ nhập'}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExamScoreEntryPage(task: task),
                          ),
                        );
                        await _reload();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Phúc khảo chờ xử lý',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (reviews.isNotEmpty)
                    Badge(label: Text('${reviews.length}')),
                ],
              ),
              const SizedBox(height: 8),
              if (reviews.isEmpty)
                const _EmptyExam(text: 'Không có yêu cầu phúc khảo đang chờ.')
              else
                ...reviews.map(
                  (review) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.rate_review_outlined),
                      title: Text(
                        '${review['studentName']} · ${review['subjectName']}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Điểm cũ: ${review['originalScore'] ?? '—'}\n${review['reason']}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final changed = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => _ResolveReviewSheet(review: review),
                        );
                        if (changed == true) await _reload();
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class ExamScoreEntryPage extends StatefulWidget {
  const ExamScoreEntryPage({super.key, required this.task});
  final Map<String, dynamic> task;

  @override
  State<ExamScoreEntryPage> createState() => _ExamScoreEntryPageState();
}

class _ExamScoreEntryPageState extends State<ExamScoreEntryPage> {
  final _api = sl<ApiService>();
  late final List<Map<String, dynamic>> _candidates =
      (widget.task['candidates'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
  late final List<TextEditingController> _scores = _candidates
      .map(
        (item) => TextEditingController(text: item['score']?.toString() ?? ''),
      )
      .toList();
  late final List<TextEditingController> _notes = _candidates
      .map(
        (item) => TextEditingController(text: item['note']?.toString() ?? ''),
      )
      .toList();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [..._scores, ..._notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final entries = <Map<String, dynamic>>[];
    for (var i = 0; i < _candidates.length; i++) {
      final text = _scores[i].text.trim().replaceAll(',', '.');
      final score = text.isEmpty ? null : double.tryParse(text);
      if (text.isNotEmpty && (score == null || score < 0 || score > 10)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Điểm của ${_candidates[i]['studentName']} phải từ 0 đến 10.',
            ),
          ),
        );
        return;
      }
      entries.add({
        'studentId': _candidates[i]['studentId'],
        'score': score,
        'note': _notes[i].text.trim(),
        'expectedVersion': _candidates[i]['version'],
      });
    }
    setState(() => _saving = true);
    try {
      final saved = await _api.saveExamResults(
        periodId: widget.task['examPeriodId'].toString(),
        scheduleId: widget.task['scheduleId'].toString(),
        entries: entries,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu điểm cho ${saved.length} học sinh.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu điểm: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editable =
        widget.task['scoreEntryAvailable'] == true &&
        widget.task['scoreEntryLocked'] != true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.task['subjectName']} · ${widget.task['classCode']}',
        ),
        backgroundColor: AppColors.teacherAccent,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: editable && !_saving ? _save : null,
            icon: const Icon(Icons.save_rounded),
            label: Text(
              _saving
                  ? 'Đang lưu...'
                  : widget.task['scoreEntryLocked'] == true
                  ? 'Điểm đã khóa'
                  : editable
                  ? 'Lưu bảng điểm'
                  : 'Chưa đến giờ nhập điểm',
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _candidates.length,
        itemBuilder: (context, index) {
          final candidate = _candidates[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${candidate['candidateNo'] ?? index + 1} · ${candidate['studentName']}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    candidate['studentCode']?.toString() ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: TextField(
                          controller: _scores[index],
                          enabled: editable,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Điểm',
                            hintText: '0-10',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _notes[index],
                          enabled: editable,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú',
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
  }
}

class _ResolveReviewSheet extends StatefulWidget {
  const _ResolveReviewSheet({required this.review});
  final Map<String, dynamic> review;

  @override
  State<_ResolveReviewSheet> createState() => _ResolveReviewSheetState();
}

class _ResolveReviewSheetState extends State<_ResolveReviewSheet> {
  final _api = sl<ApiService>();
  final _resolution = TextEditingController();
  late final _score = TextEditingController(
    text: widget.review['originalScore']?.toString() ?? '',
  );
  bool _approved = true;
  bool _saving = false;

  @override
  void dispose() {
    _resolution.dispose();
    _score.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final resolution = _resolution.text.trim();
    final score = double.tryParse(_score.text.trim().replaceAll(',', '.'));
    if (resolution.length < 5 ||
        (_approved && (score == null || score < 0 || score > 10))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nhập kết luận ít nhất 5 ký tự và điểm hợp lệ từ 0 đến 10.',
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.resolveExamReview(
        widget.review['id'].toString(),
        approved: _approved,
        resolution: resolution,
        resolvedScore: _approved ? score : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể xử lý: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      MediaQuery.viewInsetsOf(context).bottom + 16,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Xử lý phúc khảo',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.review['studentName']} · ${widget.review['subjectName']} · Điểm cũ ${widget.review['originalScore']}',
        ),
        Text(widget.review['reason'].toString()),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('Chấp nhận'),
              icon: Icon(Icons.check_rounded),
            ),
            ButtonSegment(
              value: false,
              label: Text('Từ chối'),
              icon: Icon(Icons.close_rounded),
            ),
          ],
          selected: {_approved},
          onSelectionChanged: (value) =>
              setState(() => _approved = value.first),
        ),
        if (_approved) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _score,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Điểm sau phúc khảo'),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _resolution,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Kết luận'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Đang xử lý...' : 'Xác nhận kết quả'),
        ),
      ],
    ),
  );
}

class _EmptyExam extends StatelessWidget {
  const _EmptyExam({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Center(child: Text(text, textAlign: TextAlign.center)),
    ),
  );
}

class _ExamError extends StatelessWidget {
  const _ExamError({required this.error, required this.retry});
  final Object? error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Không thể tải dữ liệu kỳ thi.\n$error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
