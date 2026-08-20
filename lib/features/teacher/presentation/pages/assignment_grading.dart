import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/domain_realtime.dart';
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

class _TeacherAssignmentGradingState extends State<TeacherAssignmentGrading> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _load();
  late final DomainRealtimeSubscription _domainEvents;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _domainEvents = DomainRealtimeSubscription.listen(
      realtime: sl<RealtimeService>(),
      domains: const {
        MobileDataDomain.assignments,
        MobileDataDomain.notifications,
      },
      onInvalidate: _refresh,
    );
  }

  @override
  void dispose() {
    unawaited(_domainEvents.dispose());
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      _api.assignmentSubmissions(widget.assignmentId);

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Color _statusColor(String status) => switch (status) {
    'GRADED' => AppColors.success,
    'LATE' => AppColors.warning,
    'RESUBMISSION_ALLOWED' => AppColors.warning,
    _ => AppColors.primary,
  };

  String _statusLabel(String status) => switch (status) {
    'GRADED' => 'Đã chấm',
    'LATE' => 'Nộp trễ',
    'RESUBMISSION_ALLOWED' => 'Được nộp lại',
    _ => 'Chờ chấm',
  };

  String _submittedAt(Object? raw) {
    final value = DateTime.tryParse((raw ?? '').toString())?.toLocal();
    if (value == null) return '—';
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  Future<void> _download(String fileId, String fileName) async {
    try {
      final bytes = await _api.downloadFile(fileId);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu bài nộp',
        fileName: fileName,
        bytes: Uint8List.fromList(bytes),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể tải bài nộp. Vui lòng thử lại.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _grade(Map<String, dynamic> submission) async {
    final scoreController = TextEditingController(
      text: submission['score'] == null ? '' : '${submission['score']}',
    );
    final feedbackController = TextEditingController(
      text: (submission['feedback'] ?? '').toString(),
    );
    var saving = false;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (submission['studentName'] ?? 'Học sinh').toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nộp lúc ${_submittedAt(submission['submittedAt'])}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if ((submission['content'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Nội dung bài làm',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(submission['content'].toString()),
                  ),
                ],
                if ((submission['attachmentFileId'] ?? '')
                    .toString()
                    .isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_file_rounded),
                    title: Text(
                      (submission['attachmentName'] ?? 'Bài nộp').toString(),
                    ),
                    trailing: const Icon(Icons.download_rounded),
                    onTap: () => _download(
                      submission['attachmentFileId'].toString(),
                      (submission['attachmentName'] ?? 'bai-nop').toString(),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Điểm (0-10)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Nhận xét'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            final score = double.tryParse(
                              scoreController.text.trim(),
                            );
                            if (score == null || score < 0 || score > 10) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Điểm phải từ 0 đến 10'),
                                ),
                              );
                              return;
                            }
                            setSheetState(() => saving = true);
                            try {
                              await _api.gradeSubmission(
                                submission['id'].toString(),
                                score: score,
                                feedback: feedbackController.text.trim(),
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, true);
                              }
                            } catch (error) {
                              if (!sheetContext.mounted) return;
                              setSheetState(() => saving = false);
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    apiErrorMessage(
                                      error,
                                      fallback:
                                          'Không thể lưu điểm bài tập. Vui lòng thử lại.',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teacherAccent,
                    ),
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(saving ? 'Đang lưu...' : 'Lưu điểm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    scoreController.dispose();
    feedbackController.dispose();
    if (saved == true && mounted) {
      _changed = true;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu điểm và gửi phản hồi')),
      );
    }
  }

  Future<void> _allowResubmit(Map<String, dynamic> submission) async {
    try {
      await _api.allowResubmit(submission['id'].toString());
      if (!mounted) return;
      _changed = true;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cho phép học sinh nộp lại')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể cho phép nộp lại. Vui lòng thử lại.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, _changed),
        ),
        title: const Text('Chấm bài tập'),
        backgroundColor: AppColors.teacherAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                apiErrorMessage(
                  snapshot.error,
                  fallback: 'Không thể tải danh sách bài nộp.',
                ),
              ),
            );
          }
          final submissions = snapshot.data ?? const [];
          final graded = submissions
              .where((item) => item['status'] == 'GRADED')
              .length;
          final pending = submissions.length - graded;
          final missing = (widget.studentCount - submissions.length).clamp(
            0,
            widget.studentCount,
          );
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.teacherAccent.withValues(alpha: .06),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assignmentTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.className} • ${widget.subject} • Hạn ${widget.deadline}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Đã chấm',
                            value: graded,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatBox(
                            label: 'Chờ chấm',
                            value: pending,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatBox(
                            label: 'Chưa nộp',
                            value: missing,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: submissions.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có học sinh nộp bài',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _refresh(),
                        child: ListView.separated(
                          itemCount: submissions.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final submission = submissions[index];
                            final status = (submission['status'] ?? 'SUBMITTED')
                                .toString();
                            final color = _statusColor(status);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: .12),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: color),
                                ),
                              ),
                              title: Text(
                                (submission['studentName'] ?? 'Học sinh')
                                    .toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${_statusLabel(status)} • ${_submittedAt(submission['submittedAt'])}',
                              ),
                              trailing: status == 'GRADED'
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'grade') {
                                          _grade(submission);
                                        }
                                        if (value == 'resubmit') {
                                          _allowResubmit(submission);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'grade',
                                          child: Text('Sửa điểm'),
                                        ),
                                        PopupMenuItem(
                                          value: 'resubmit',
                                          child: Text('Cho nộp lại'),
                                        ),
                                      ],
                                    )
                                  : const Icon(Icons.chevron_right_rounded),
                              onTap: () => _grade(submission),
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
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
