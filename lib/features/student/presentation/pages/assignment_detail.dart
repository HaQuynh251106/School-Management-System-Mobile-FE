import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class StudentAssignmentDetail extends StatefulWidget {
  const StudentAssignmentDetail({
    super.key,
    required this.assignment,
    required this.submission,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status,
    this.score,
    this.feedback,
  });

  final Map<String, dynamic> assignment;
  final Map<String, dynamic>? submission;
  final String title;
  final String subject;
  final String teacher;
  final String deadline;
  final String status;
  final double? score;
  final String? feedback;

  @override
  State<StudentAssignmentDetail> createState() =>
      _StudentAssignmentDetailState();
}

class _StudentAssignmentDetailState extends State<StudentAssignmentDetail> {
  late Map<String, dynamic>? _submission = widget.submission;
  late final TextEditingController _contentController = TextEditingController(
    text: '${widget.submission?['content'] ?? ''}',
  );
  PlatformFile? _pickedFile;
  bool _busy = false;

  String get _status => '${_submission?['status'] ?? widget.status}';
  bool get _canSubmit =>
      _status == 'PENDING' || _status == 'RESUBMISSION_ALLOWED';
  double? get _score =>
      (_submission?['score'] as num?)?.toDouble() ?? widget.score;
  String? get _feedback =>
      _submission?['feedback']?.toString() ?? widget.feedback;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Color get _statusColor => switch (_status) {
        'GRADED' => AppColors.success,
        'SUBMITTED' => AppColors.primary,
        'LATE' => AppColors.warning,
        'RESUBMISSION_ALLOWED' => AppColors.warning,
        'CLOSED' => Theme.of(context).colorScheme.onSurfaceVariant,
        _ => AppColors.error,
      };

  String get _statusLabel => switch (_status) {
        'GRADED' => 'Đã chấm',
        'SUBMITTED' => 'Đã nộp',
        'LATE' => 'Nộp trễ',
        'RESUBMISSION_ALLOWED' => 'Được nộp lại',
        'CLOSED' => 'Đã đóng',
        _ => 'Chưa nộp',
      };

  @override
  Widget build(BuildContext context) {
    final description = '${widget.assignment['description'] ?? ''}'.trim();
    final assignmentAttachment =
        '${widget.assignment['attachmentName'] ?? ''}'.trim();
    final submissionAttachment =
        '${_submission?['attachmentName'] ?? ''}'.trim();
    final submittedAt =
        DateTime.tryParse('${_submission?['submittedAt'] ?? ''}');
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
                _header(),
                const SizedBox(height: 18),
                const SectionHeader(title: 'Yêu cầu'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      description.isEmpty
                          ? 'Giáo viên chưa nhập mô tả.'
                          : description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
                if (assignmentAttachment.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const SectionHeader(title: 'Tệp đề bài'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.attach_file_rounded,
                          color: AppColors.studentAccent),
                      title: Text(assignmentAttachment),
                      subtitle: const Text('Tệp do giáo viên đính kèm'),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const SectionHeader(title: 'Bài làm của bạn'),
                const SizedBox(height: 8),
                if (_canSubmit) ...[
                  TextField(
                    controller: _contentController,
                    minLines: 4,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung bài làm',
                      hintText: 'Nhập nội dung hoặc ghi chú cho tệp bài làm',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pickFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(_pickedFile?.name ?? 'Chọn tệp bài làm'),
                  ),
                ] else
                  Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.check_circle_rounded, color: _statusColor),
                      title: Text(submissionAttachment.isEmpty
                          ? (_submission?['content']
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ==
                                  true
                              ? 'Bài làm dạng nội dung'
                              : 'Đã ghi nhận bài nộp')
                          : submissionAttachment),
                      subtitle: Text(submittedAt == null
                          ? _statusLabel
                          : '$_statusLabel lúc ${DateFormat('dd/MM HH:mm').format(submittedAt.toLocal())}'),
                    ),
                  ),
                if (_status == 'GRADED' && _score != null) ...[
                  const SizedBox(height: 16),
                  _gradeCard(_score!, _feedback),
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
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.studentAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_busy ? 'Đang nộp…' : 'Nộp bài'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.studentAccent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_statusLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
            const Spacer(),
            Text(widget.subject,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Text(widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('${widget.teacher} • Hạn ${widget.deadline}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      );

  Widget _gradeCard(double score, String? feedback) => Card(
        color: AppColors.success.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Điểm bài tập',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${score.toStringAsFixed(1)} / 10',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success)),
            ]),
            if (feedback?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(feedback!, style: const TextStyle(height: 1.4)),
            ],
          ]),
        ),
      );

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || !mounted) return;
    final file = result.files.single;
    if (file.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tệp không được vượt quá 10 MB.')),
      );
      return;
    }
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đọc tệp đã chọn.')),
      );
      return;
    }
    setState(() => _pickedFile = file);
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập nội dung hoặc chọn tệp bài làm.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      String? fileId;
      if (_pickedFile != null) {
        final stored = await sl<ApiService>()
            .uploadFile(_pickedFile!.bytes!, _pickedFile!.name);
        fileId = '${stored['id'] ?? ''}';
      }
      final saved = await sl<ApiService>().submitAssignment(
        '${widget.assignment['id']}',
        content: content.isEmpty ? null : content,
        attachmentFileId: fileId,
      );
      if (!mounted) return;
      setState(() {
        _submission = saved;
        _pickedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã nộp bài thành công.'),
        backgroundColor: AppColors.success,
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể nộp bài. Vui lòng kiểm tra và thử lại.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
