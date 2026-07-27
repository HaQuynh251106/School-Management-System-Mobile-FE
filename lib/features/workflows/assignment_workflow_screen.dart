import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../modules/create_record_sheet.dart';
import '../modules/module_hub_screen.dart';

class AssignmentWorkflowScreen extends StatefulWidget {
  const AssignmentWorkflowScreen({
    super.key,
    required this.module,
    required this.accent,
  });
  final AppModule module;
  final Color accent;

  @override
  State<AssignmentWorkflowScreen> createState() =>
      _AssignmentWorkflowScreenState();
}

class _AssignmentWorkflowScreenState extends State<AssignmentWorkflowScreen> {
  late Future<List<Map<String, dynamic>>> future;

  String get role => context.read<AppSession>().user?.role ?? '';
  bool get isTeacher => role == 'TEACHER' || role == 'ADMIN';
  bool get isSubmissionList => widget.module.endpoint == '/me/submissions';

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      context.read<AppSession>().api.list(widget.module.endpoint);

  void _reload() => setState(() => future = _load());

  Future<void> _create() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          CreateRecordSheet(kind: 'assignment', accent: widget.accent),
    );
    if (changed == true) _reload();
  }

  Future<void> _action(String path, [Object? body]) async {
    try {
      await context.read<AppSession>().api.post(path, body ?? const {});
      if (!mounted) return;
      _message('Đã cập nhật.');
      _reload();
    } catch (error) {
      if (mounted) _message('$error');
    }
  }

  Future<void> _delete(String id) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài tập?'),
        content: const Text('Thao tác này không thể hoàn tác.'),
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
      await context.read<AppSession>().api.delete('/assignments/$id');
      if (mounted) {
        _message('Đã xóa bài tập.');
        _reload();
      }
    } catch (error) {
      if (mounted) _message('$error');
    }
  }

  Future<void> _extend(String id) async {
    final initial = DateTime.now().add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: initial,
    );
    if (date == null) return;
    await _action('/assignments/$id/extend', {
      'deadline': DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
      ).toUtc().toIso8601String(),
    });
  }

  Future<void> _submit(Map<String, dynamic> assignment) async {
    final content = TextEditingController();
    PlatformFile? selected;
    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nộp bài: ${assignment['title'] ?? ''}'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: content,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung bài làm',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      withData: true,
                    );
                    if (result != null) {
                      setDialogState(() => selected = result.files.single);
                    }
                  },
                  icon: const Icon(Icons.attach_file_rounded),
                  label: Text(selected?.name ?? 'Đính kèm tệp (tối đa 10 MB)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      ),
    );
    if (sent != true || !mounted) {
      content.dispose();
      return;
    }
    final api = context.read<AppSession>().api;
    try {
      String? fileId;
      if (selected != null) {
        final bytes = selected!.bytes;
        if (bytes == null) throw StateError('Không đọc được tệp đã chọn.');
        final file = await api.upload(
          '/files',
          bytes,
          selected!.name,
        );
        fileId = '${file['id']}';
      }
      await api.post(
        '/assignments/${assignment['id']}/submit',
        {'content': content.text.trim(), 'attachmentFileId': fileId},
      );
      if (mounted) {
        _message('Đã nộp bài thành công.');
        _reload();
      }
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      content.dispose();
    }
  }

  Future<void> _openSubmissions(Map<String, dynamic> assignment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubmissionScreen(
          assignment: assignment,
          accent: widget.accent,
        ),
      ),
    );
    _reload();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.module.title),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    floatingActionButton: isTeacher && !isSubmissionList
        ? FloatingActionButton.extended(
            onPressed: _create,
            backgroundColor: widget.accent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Giao bài'),
          )
        : null,
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(error: '${snapshot.error}', retry: _reload);
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có bài tập hoặc bài đã nộp.'));
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final status = '${item['status'] ?? ''}';
              return Card(
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
                              isSubmissionList
                                  ? Icons.cloud_done_outlined
                                  : Icons.assignment_outlined,
                              color: widget.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['title'] ?? item['assignmentTitle'] ?? 'Bài tập'}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Hạn: ${item['deadline'] ?? 'Không giới hạn'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (status.isNotEmpty) Chip(label: Text(status)),
                        ],
                      ),
                      if ('${item['description'] ?? ''}'.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('${item['description']}'),
                      ],
                      if (isSubmissionList) ...[
                        const Divider(height: 24),
                        Text(
                          item['score'] == null
                              ? 'Giáo viên chưa chấm'
                              : 'Điểm: ${item['score']}/10',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if ('${item['feedback'] ?? ''}'.isNotEmpty)
                          Text('Nhận xét: ${item['feedback']}'),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: isTeacher
                            ? [
                                if (status == 'DRAFT')
                                  FilledButton.tonalIcon(
                                    onPressed: () => _action(
                                      '/assignments/${item['id']}/publish',
                                    ),
                                    icon: const Icon(Icons.publish_rounded),
                                    label: const Text('Phát hành'),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () => _openSubmissions(item),
                                  icon: const Icon(Icons.fact_check_outlined),
                                  label: const Text('Bài đã nộp'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _extend('${item['id']}'),
                                  icon: const Icon(Icons.update_rounded),
                                  label: const Text('Gia hạn'),
                                ),
                                IconButton(
                                  tooltip: 'Xóa',
                                  onPressed: () => _delete('${item['id']}'),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ]
                            : isSubmissionList
                            ? const []
                            : [
                                FilledButton.icon(
                                  onPressed: () => _submit(item),
                                  icon: const Icon(Icons.upload_file_rounded),
                                  label: const Text('Nộp bài'),
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
      },
    ),
  );
}

class _SubmissionScreen extends StatefulWidget {
  const _SubmissionScreen({required this.assignment, required this.accent});
  final Map<String, dynamic> assignment;
  final Color accent;

  @override
  State<_SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<_SubmissionScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() => context
      .read<AppSession>()
      .api
      .list('/assignments/${widget.assignment['id']}/submissions');

  Future<void> _grade(Map<String, dynamic> submission) async {
    final score = TextEditingController(text: '${submission['score'] ?? ''}');
    final feedback =
        TextEditingController(text: '${submission['feedback'] ?? ''}');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chấm bài'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: score,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Điểm /10'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedback,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Nhận xét'),
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
    if (accepted != true || !mounted) return;
    final value = double.tryParse(score.text.replaceAll(',', '.'));
    if (value == null || value < 0 || value > 10) return;
    await context.read<AppSession>().api.post(
      '/submissions/${submission['id']}/grade',
      {'score': value, 'feedback': feedback.text.trim()},
    );
    if (mounted) setState(() => future = _load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.assignment['title'] ?? 'Bài đã nộp'}')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có học sinh nộp bài.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(
                  '${item['studentName'] ?? item['studentId'] ?? 'Học sinh'}',
                ),
                subtitle: Text(
                  item['score'] == null
                      ? '${item['content'] ?? 'Chưa chấm'}'
                      : 'Điểm ${item['score']}/10 · ${item['feedback'] ?? ''}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'grade') _grade(item);
                    if (value == 'resubmit') {
                      context.read<AppSession>().api.post(
                        '/submissions/${item['id']}/allow-resubmit',
                        const {},
                      ).then((_) => setState(() => future = _load()));
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'grade', child: Text('Chấm bài')),
                    PopupMenuItem(
                      value: 'resubmit',
                      child: Text('Cho phép nộp lại'),
                    ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.retry});
  final String error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: retry, child: const Text('Thử lại')),
        ],
      ),
    ),
  );
}
