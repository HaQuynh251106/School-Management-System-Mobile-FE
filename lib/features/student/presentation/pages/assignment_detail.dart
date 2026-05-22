import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class StudentAssignmentDetail extends StatefulWidget {
  const StudentAssignmentDetail({
    super.key,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.deadline,
    required this.status, // PENDING / SUBMITTED / LATE / GRADED
    this.score,
    this.feedback,
  });

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
  late String _status;
  String? _uploadedFile;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  Color get _statusColor => switch (_status) {
        'GRADED' => AppColors.success,
        'SUBMITTED' => AppColors.primary,
        'LATE' => AppColors.warning,
        _ => AppColors.error,
      };

  String get _statusLabel => switch (_status) {
        'GRADED' => 'Đã chấm',
        'SUBMITTED' => 'Đã nộp',
        'LATE' => 'Nộp trễ',
        _ => 'Chưa nộp',
      };

  @override
  Widget build(BuildContext context) {
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
                _buildHeader(),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Đề bài'),
                const SizedBox(height: 8),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'Giải các bài tập trong Chương 3 — Hàm số bậc hai. '
                      'Phần 1: vẽ đồ thị (5 bài). Phần 2: tìm cực trị (3 bài). '
                      'Nộp file PDF hoặc ảnh chụp bài làm tay rõ nét. '
                      'Trình bày sạch đẹp, ghi rõ họ tên + lớp ở đầu trang.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Tài liệu kèm theo'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _AttachmentTile(
                        icon: Icons.picture_as_pdf_rounded,
                        name: 'DeBai_HamSoBacHai.pdf',
                        size: '845 KB',
                      ),
                      Divider(height: 0),
                      _AttachmentTile(
                        icon: Icons.description_outlined,
                        name: 'BangDap_Tham_Khao.docx',
                        size: '120 KB',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Bài làm của bạn'),
                const SizedBox(height: 8),
                if (_uploadedFile == null && _status == 'PENDING')
                  _UploadBox(onUpload: _uploadFile)
                else
                  _SubmissionView(
                    fileName: _uploadedFile ?? 'BaiLam_PhamHoaiAn.pdf',
                    status: _status,
                  ),
                if (_status == 'GRADED' && widget.score != null) ...[
                  const SizedBox(height: 16),
                  _buildGradeCard(),
                ],
              ],
            ),
          ),
          if (_status == 'PENDING' && _uploadedFile != null)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                      top: BorderSide(color: AppColors.divider, width: 0.5)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.studentAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Nộp bài'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.studentAccent,
            AppColors.studentAccent.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(widget.subject,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(widget.teacher,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('Hạn: ${widget.deadline}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard() {
    final score = widget.score!;
    final color = score >= 8
        ? AppColors.success
        : score >= 6.5
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Điểm bài tập',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text(
                '${score.toStringAsFixed(1)} / 10',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          if (widget.feedback != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.feedback!,
                        style: const TextStyle(fontSize: 13, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _uploadFile() {
    setState(() => _uploadedFile = 'BaiLam_PhamHoaiAn.pdf');
  }

  void _submit() {
    setState(() => _status = 'SUBMITTED');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã nộp bài thành công'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.onUpload});
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.studentAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.studentAccent.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.cloud_upload_rounded,
                color: AppColors.studentAccent, size: 36),
            SizedBox(height: 8),
            Text(
              'Tap để chọn file',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.studentAccent),
            ),
            SizedBox(height: 4),
            Text(
              'PDF, DOCX, JPG, PNG — tối đa 10 MB',
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionView extends StatelessWidget {
  const _SubmissionView({required this.fileName, required this.status});
  final String fileName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf_rounded,
            color: AppColors.studentAccent, size: 28),
        title: Text(fileName,
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
          status == 'PENDING'
              ? 'Đã chọn, sẵn sàng nộp'
              : 'Đã nộp lúc 14:30 22/05',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: status == 'PENDING'
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {},
              )
            : const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.icon,
    required this.name,
    required this.size,
  });

  final IconData icon;
  final String name;
  final String size;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.studentAccent),
      title: Text(name,
          style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(size,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.download_rounded, size: 20),
      onTap: () {},
    );
  }
}
