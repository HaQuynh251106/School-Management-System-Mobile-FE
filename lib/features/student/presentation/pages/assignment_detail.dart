import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class StudentAssignmentDetail extends StatefulWidget {
  const StudentAssignmentDetail({
    super.key,
    required this.assignmentId,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status,
    required this.onSubmit,
    this.description,
    this.assignmentAttachmentFileId,
    this.assignmentAttachmentName,
    this.submissionContent,
    this.submissionAttachmentFileId,
    this.submissionAttachmentName,
    this.score,
    this.feedback,
  });

  final String assignmentId;
  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String status;
  final String? description;
  final String? assignmentAttachmentFileId;
  final String? assignmentAttachmentName;
  final String? submissionContent;
  final String? submissionAttachmentFileId;
  final String? submissionAttachmentName;
  final double? score;
  final String? feedback;
  final Future<bool> Function() onSubmit;

  @override
  State<StudentAssignmentDetail> createState() =>
      _StudentAssignmentDetailState();
}

class _StudentAssignmentDetailState extends State<StudentAssignmentDetail> {
  late String _status = widget.status;
  bool _submitting = false;

  Color get _statusColor => switch (_status) {
    'GRADED' => AppColors.success,
    'SUBMITTED' => AppColors.primary,
    'LATE' => AppColors.warning,
    'RESUBMISSION_ALLOWED' => AppColors.warning,
    'LATE_ALLOWED' => AppColors.warning,
    'OVERDUE' => AppColors.error,
    'CLOSED' => AppColors.textSecondary,
    _ => AppColors.error,
  };

  String get _statusLabel => switch (_status) {
    'GRADED' => 'Đã chấm',
    'SUBMITTED' => 'Đã nộp',
    'LATE' => 'Nộp trễ',
    'RESUBMISSION_ALLOWED' => 'Được nộp lại',
    'LATE_ALLOWED' => 'Nộp muộn',
    'OVERDUE' => 'Quá hạn',
    'CLOSED' => 'Đã đóng',
    _ => 'Chưa nộp',
  };

  bool get _canSubmit =>
      _status == 'PENDING' ||
      _status == 'LATE_ALLOWED' ||
      _status == 'RESUBMISSION_ALLOWED';

  Future<void> _download(String fileId, String fileName) async {
    try {
      final bytes = await sl<ApiService>().downloadFile(fileId);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu tệp',
        fileName: fileName,
        bytes: Uint8List.fromList(bytes),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải tệp: $error')));
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final submitted = await widget.onSubmit();
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (submitted) _status = 'SUBMITTED';
    });
    if (submitted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final assignmentFileId = widget.assignmentAttachmentFileId ?? '';
    final submissionFileId = widget.submissionAttachmentFileId ?? '';
    final description = (widget.description ?? '').trim();
    final submissionContent = (widget.submissionContent ?? '').trim();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài tập'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(
                  title: widget.title,
                  subject: widget.subject,
                  teacher: widget.teacher,
                  deadline: widget.deadline,
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Đề bài'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    description.isEmpty
                        ? 'Giáo viên chưa nhập mô tả.'
                        : description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
                if (assignmentFileId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Tài liệu đính kèm'),
                  const SizedBox(height: 8),
                  _FileTile(
                    fileName: widget.assignmentAttachmentName ?? 'Tài liệu',
                    onDownload: () => _download(
                      assignmentFileId,
                      widget.assignmentAttachmentName ?? 'tai-lieu',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const SectionHeader(title: 'Bài làm của bạn'),
                const SizedBox(height: 8),
                if (submissionContent.isEmpty && submissionFileId.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      _canSubmit ? 'Bạn chưa nộp bài.' : 'Không có bài nộp.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else ...[
                  if (submissionContent.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(submissionContent),
                    ),
                  if (submissionFileId.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _FileTile(
                      fileName: widget.submissionAttachmentName ?? 'Bài nộp',
                      onDownload: () => _download(
                        submissionFileId,
                        widget.submissionAttachmentName ?? 'bai-nop',
                      ),
                    ),
                  ],
                ],
                if (_status == 'GRADED' && widget.score != null) ...[
                  const SizedBox(height: 16),
                  _GradeCard(score: widget.score!, feedback: widget.feedback),
                ],
              ],
            ),
          ),
          if (_canSubmit)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.studentAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: Text(_submitting ? 'Đang nộp...' : 'Nộp bài'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.statusLabel,
    required this.statusColor,
  });

  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.studentAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$teacher • Hạn $deadline',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.fileName, required this.onDownload});

  final String fileName;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.description_outlined,
          color: AppColors.studentAccent,
        ),
        title: Text(fileName),
        trailing: IconButton(
          tooltip: 'Tải xuống',
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.score, this.feedback});

  final double score;
  final String? feedback;

  @override
  Widget build(BuildContext context) {
    final color = score >= 8
        ? AppColors.success
        : score >= 6.5
        ? AppColors.warning
        : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Điểm bài tập',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${score.toStringAsFixed(1)} / 10',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if ((feedback ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(feedback!, style: const TextStyle(height: 1.4)),
          ],
        ],
      ),
    );
  }
}
