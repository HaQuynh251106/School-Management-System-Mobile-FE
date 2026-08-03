import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class StudentExamResultsScreen extends StatefulWidget {
  const StudentExamResultsScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<StudentExamResultsScreen> createState() =>
      _StudentExamResultsScreenState();
}

class _StudentExamResultsScreenState extends State<StudentExamResultsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = context.read<AppSession>().api.list('/me/exam-results');
  }

  Future<void> _review(Map<String, dynamic> item) async {
    final reason = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu phúc khảo'),
        content: TextField(
          controller: reason,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Lý do (ít nhất 10 ký tự)',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
    if (accepted != true || reason.text.trim().length < 10 || !mounted) return;
    try {
      await context.read<AppSession>().api.post(
        '/exam-periods/${item['examPeriodId']}/reviews',
        {'resultId': item['resultId'], 'reason': reason.text.trim()},
      );
      if (mounted) {
        setState(
          () =>
              future = context.read<AppSession>().api.list('/me/exam-results'),
        );
      }
    } finally {
      reason.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kết quả thi')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có kết quả thi được công bố.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final reviewStatus = '${item['reviewStatus'] ?? ''}';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: widget.accent.withValues(alpha: .1),
                          child: Icon(
                            Icons.workspace_premium_outlined,
                            color: widget.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['subjectName'] ?? 'Môn thi'}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text('${item['examPeriodName'] ?? ''}'),
                            ],
                          ),
                        ),
                        Text(
                          item['score'] == null ? '—' : '${item['score']}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: widget.accent),
                        ),
                      ],
                    ),
                    if (reviewStatus.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text('Phúc khảo: $reviewStatus'),
                      if ('${item['reviewResolution'] ?? ''}'.isNotEmpty)
                        Text('Kết quả: ${item['reviewResolution']}'),
                    ],
                    if (item['resultId'] != null && reviewStatus.isEmpty) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _review(item),
                        icon: const Icon(Icons.history_edu_outlined),
                        label: const Text('Yêu cầu phúc khảo'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class TeacherExamWorkScreen extends StatefulWidget {
  const TeacherExamWorkScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<TeacherExamWorkScreen> createState() => _TeacherExamWorkScreenState();
}

class _TeacherExamWorkScreenState extends State<TeacherExamWorkScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  late Future<List<Map<String, dynamic>>> grading;
  late Future<List<Map<String, dynamic>>> reviews;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    grading = context.read<AppSession>().api.list('/me/exam-grading');
    reviews = context.read<AppSession>().api.list('/me/exam-reviews');
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  Future<void> _enterScores(Map<String, dynamic> task) async {
    final candidates = (task['candidates'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final controllers = {
      for (final item in candidates)
        '${item['studentId']}': TextEditingController(
          text: '${item['score'] ?? ''}',
        ),
    };
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          8,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          children: [
            const Text(
              'Nhập điểm thi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final item = candidates[index];
                  return ListTile(
                    title: Text('${item['studentName'] ?? item['studentId']}'),
                    subtitle: Text('SBD ${item['candidateNo'] ?? '—'}'),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: controllers['${item['studentId']}'],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(hintText: '0–10'),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lưu điểm'),
              ),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    final entries = <Map<String, dynamic>>[];
    for (final item in candidates) {
      final raw = controllers['${item['studentId']}']!.text.trim();
      if (raw.isEmpty) continue;
      final value = double.tryParse(raw.replaceAll(',', '.'));
      if (value == null || value < 0 || value > 10) return;
      entries.add({
        'studentId': item['studentId'],
        'score': value,
        'expectedVersion': item['version'],
      });
    }
    await context.read<AppSession>().api.dio.put(
      '/exam-periods/${task['examPeriodId']}/results',
      data: {'scheduleId': task['scheduleId'], 'entries': entries},
    );
    if (mounted) setState(_reload);
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> _resolve(Map<String, dynamic> review) async {
    final resolution = TextEditingController();
    final score = TextEditingController(
      text: '${review['requestedScore'] ?? review['originalScore'] ?? ''}',
    );
    String status = 'APPROVED';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xử lý phúc khảo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'APPROVED', child: Text('Chấp nhận')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Từ chối')),
                ],
                onChanged: (value) => setState(() => status = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resolution,
                decoration: const InputDecoration(labelText: 'Kết luận'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: score,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Điểm sau xử lý'),
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
              child: const Text('Hoàn tất'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || resolution.text.trim().length < 5 || !mounted) {
      return;
    }
    await context
        .read<AppSession>()
        .api
        .put('/exam-reviews/${review['id']}/resolve', {
          'status': status,
          'resolution': resolution.text.trim(),
          'resolvedScore': status == 'APPROVED'
              ? double.tryParse(score.text.replaceAll(',', '.'))
              : null,
        });
    if (mounted) setState(_reload);
  }

  Widget _list(
    Future<List<Map<String, dynamic>>> source,
    Widget Function(Map<String, dynamic>) tile,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: source,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      final items = snapshot.data ?? [];
      if (items.isEmpty) {
        return const Center(child: Text('Hiện không có công việc.'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => tile(items[index]),
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Công việc khảo thí'),
      bottom: TabBar(
        controller: tabs,
        tabs: const [
          Tab(text: 'Nhập điểm'),
          Tab(text: 'Phúc khảo'),
        ],
      ),
    ),
    body: TabBarView(
      controller: tabs,
      children: [
        _list(
          grading,
          (item) => Card(
            child: ListTile(
              leading: Icon(Icons.edit_note_outlined, color: widget.accent),
              title: Text('${item['subjectName'] ?? 'Môn thi'}'),
              subtitle: Text(
                '${item['classCode'] ?? ''} · ${item['examDate'] ?? ''} · ${(item['candidates'] as List?)?.length ?? 0} thí sinh',
              ),
              trailing: FilledButton.tonal(
                onPressed: item['scoreEntryLocked'] == true
                    ? null
                    : () => _enterScores(item),
                child: Text(
                  item['scoreEntryLocked'] == true ? 'Đã khóa' : 'Nhập điểm',
                ),
              ),
            ),
          ),
        ),
        _list(
          reviews,
          (item) => Card(
            child: ListTile(
              leading: Icon(Icons.history_edu_outlined, color: widget.accent),
              title: Text('${item['studentName'] ?? 'Học sinh'}'),
              subtitle: Text('${item['reason'] ?? ''}'),
              trailing: '${item['status']}' == 'PENDING'
                  ? FilledButton.tonal(
                      onPressed: () => _resolve(item),
                      child: const Text('Xử lý'),
                    )
                  : Chip(label: Text('${item['status'] ?? ''}')),
            ),
          ),
        ),
      ],
    ),
  );
}
