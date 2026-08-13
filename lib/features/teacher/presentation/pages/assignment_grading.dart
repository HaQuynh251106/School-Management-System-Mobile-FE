import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';

class TeacherAssignmentGrading extends StatefulWidget {
  const TeacherAssignmentGrading({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.subject,
    required this.className,
    required this.deadline,
    required this.studentCount,
  });

  final String assignmentId;
  final String assignmentTitle;
  final String subject;
  final String className;
  final String deadline;
  final int studentCount;

  @override
  State<TeacherAssignmentGrading> createState() =>
      _TeacherAssignmentGradingState();
}

class _TeacherAssignmentGradingState extends State<TeacherAssignmentGrading>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future = _load();
  StreamSubscription<RealtimeEvent>? _assignmentEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _assignmentEvents = realtime.events
        .where((event) =>
            event.type == 'ASSIGNMENT_UPDATED' &&
            '${event.data['assignmentId'] ?? ''}' == widget.assignmentId)
        .listen((_) => _reload());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _assignmentEvents?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      sl<ApiService>().assignmentSubmissions(widget.assignmentId);

  void _reload() => setState(() => _future = _load());

  String _time(Object? raw) {
    final value = DateTime.tryParse('${raw ?? ''}');
    return value == null
        ? '—'
        : DateFormat('dd/MM HH:mm').format(value.toLocal());
  }

  Color _statusColor(String status) => switch (status) {
        'GRADED' => AppColors.success,
        'SUBMITTED' => AppColors.primary,
        'LATE' => AppColors.warning,
        'RESUBMISSION_ALLOWED' => AppColors.warning,
        _ => AppColors.error,
      };

  String _statusLabel(String status) => switch (status) {
        'GRADED' => 'Đã chấm',
        'SUBMITTED' => 'Chờ chấm',
        'LATE' => 'Nộp trễ',
        'RESUBMISSION_ALLOWED' => 'Được nộp lại',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm bài tập'),
        backgroundColor: AppColors.teacherAccent,
        actions: [
          IconButton(
              onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _reload);
          }
          final submissions = snapshot.data ?? const [];
          final graded =
              submissions.where((item) => item['status'] == 'GRADED').length;
          final pending = submissions
              .where((item) =>
                  item['status'] == 'SUBMITTED' || item['status'] == 'LATE')
              .length;
          final missing = (widget.studentCount - submissions.length)
              .clamp(0, widget.studentCount);
          return Column(
            children: [
              _Header(
                title: widget.assignmentTitle,
                detail:
                    '${widget.className} • ${widget.subject} • Hạn ${widget.deadline}',
                graded: graded,
                pending: pending,
                missing: missing,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: submissions.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Chưa có học sinh nộp bài')),
                        ])
                      : ListView.separated(
                          itemCount: submissions.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (_, index) {
                            final submission = submissions[index];
                            final status =
                                '${submission['status'] ?? 'SUBMITTED'}';
                            final color = _statusColor(status);
                            final score =
                                (submission['score'] as num?)?.toDouble();
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.12),
                                child: Text('${index + 1}',
                                    style: TextStyle(color: color)),
                              ),
                              title: Text(
                                  '${submission['studentName'] ?? submission['studentId'] ?? ''}'),
                              subtitle: Text(
                                  '${_statusLabel(status)} • ${_time(submission['submittedAt'])}'),
                              trailing: score == null
                                  ? const Icon(Icons.chevron_right_rounded)
                                  : Text(score.toStringAsFixed(1),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                              onTap: status == 'RESUBMISSION_ALLOWED'
                                  ? null
                                  : () => _openSubmission(submission),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSubmission(Map<String, dynamic> submission) async {
    final attempts = await sl<ApiService>()
        .submissionAttempts('${submission['id']}')
        .catchError((_) => <Map<String, dynamic>>[]);
    if (!mounted) return;
    final status = '${submission['status'] ?? ''}';
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${submission['studentName'] ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                if ('${submission['content'] ?? ''}'.trim().isNotEmpty)
                  Text('${submission['content']}',
                      style: const TextStyle(height: 1.45)),
                if ('${submission['attachmentName'] ?? ''}'.trim().isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_file_rounded),
                    title: Text('${submission['attachmentName']}'),
                    subtitle: const Text('Tệp bài làm đã lưu trên hệ thống'),
                  ),
                if (attempts.isNotEmpty) ...[
                  const Divider(height: 28),
                  Text('Lịch sử ${attempts.length} lần nộp',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  ...attempts.map((attempt) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text('${attempt['attemptNumber'] ?? ''}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                        title: Text(_statusLabel('${attempt['status']}')),
                        subtitle: Text(_time(attempt['submittedAt'])),
                        trailing: attempt['score'] is num
                            ? Text(
                                (attempt['score'] as num).toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              )
                            : null,
                      )),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  if (status == 'GRADED') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(sheetContext, 'resubmit'),
                        child: const Text('Cho nộp lại'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: status == 'RESUBMISSION_ALLOWED'
                          ? null
                          : () => Navigator.pop(sheetContext, 'grade'),
                      child: Text(status == 'GRADED' ? 'Sửa điểm' : 'Chấm bài'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    if (action == 'grade') {
      await _grade(submission);
    } else if (action == 'resubmit') {
      try {
        await sl<ApiService>().allowSubmissionResubmit('${submission['id']}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã cho phép học sinh nộp lại bài.'),
          backgroundColor: AppColors.success,
        ));
        _reload();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không thể cho nộp lại. Vui lòng thử lại.'),
          ));
        }
      }
    }
  }

  Future<void> _grade(Map<String, dynamic> submission) async {
    final scoreController = TextEditingController(
      text: (submission['score'] as num?)?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: '${submission['feedback'] ?? ''}',
    );
    final value = await showModalBottomSheet<(double, String)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chấm bài — ${submission['studentName'] ?? ''}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: scoreController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Điểm (0–10)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Nhận xét'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final score = double.tryParse(scoreController.text.trim());
                  if (score == null || score < 0 || score > 10) return;
                  Navigator.pop(
                      context, (score, feedbackController.text.trim()));
                },
                child: const Text('Lưu điểm'),
              ),
            ),
          ],
        ),
      ),
    );
    scoreController.dispose();
    feedbackController.dispose();
    if (value == null || !mounted) return;
    try {
      await sl<ApiService>().gradeSubmission(
        '${submission['id']}',
        score: value.$1,
        feedback: value.$2,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã lưu điểm và phản hồi.'),
        backgroundColor: AppColors.success,
      ));
      _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể lưu điểm. Vui lòng thử lại.'),
        ));
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.detail,
    required this.graded,
    required this.pending,
    required this.missing,
  });
  final String title;
  final String detail;
  final int graded;
  final int pending;
  final int missing;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: AppColors.teacherAccent.withValues(alpha: 0.06),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(children: [
            _Stat('Đã chấm', graded, AppColors.success),
            const SizedBox(width: 8),
            _Stat('Chờ chấm', pending, AppColors.primary),
            const SizedBox(width: 8),
            _Stat('Chưa nộp', missing, AppColors.error),
          ]),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Text('$value',
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10)),
          ]),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tải lại bài nộp'),
        ),
      );
}
