import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class TeacherAssignmentGrading extends StatefulWidget {
  const TeacherAssignmentGrading({
    super.key,
    required this.assignmentTitle,
    required this.subject,
    required this.className,
    required this.deadline,
  });

  final String assignmentTitle;
  final String subject;
  final String className;
  final String deadline;

  @override
  State<TeacherAssignmentGrading> createState() =>
      _TeacherAssignmentGradingState();
}

class _Submission {
  _Submission({
    required this.name,
    required this.submittedAt,
    required this.status,
    this.score,
    this.feedback,
  });
  final String name;
  final String submittedAt;
  String status;
  double? score;
  String? feedback;
}

class _TeacherAssignmentGradingState extends State<TeacherAssignmentGrading> {
  late final List<_Submission> _submissions = [
    _Submission(
        name: 'Phạm Hoài An',
        submittedAt: '22/05 14:30',
        status: 'GRADED',
        score: 9.0,
        feedback: 'Bài tốt, trình bày sạch.'),
    _Submission(
        name: 'Nguyễn Minh Châu',
        submittedAt: '22/05 20:15',
        status: 'GRADED',
        score: 8.5,
        feedback: 'Đúng phần lớn, có 1 ý sai nhỏ.'),
    _Submission(
        name: 'Trần Thị Dung',
        submittedAt: '23/05 08:00',
        status: 'SUBMITTED'),
    _Submission(
        name: 'Lê Quang Huy',
        submittedAt: '22/05 23:55',
        status: 'SUBMITTED'),
    _Submission(
        name: 'Võ Thị Kim',
        submittedAt: '24/05 09:12',
        status: 'LATE'),
    _Submission(
        name: 'Đỗ Văn Long',
        submittedAt: '—',
        status: 'NOT_SUBMITTED'),
    _Submission(
        name: 'Hoàng Thị Mai',
        submittedAt: '—',
        status: 'NOT_SUBMITTED'),
    _Submission(
        name: 'Bùi Ngọc Nam',
        submittedAt: '22/05 11:10',
        status: 'SUBMITTED'),
  ];

  Color _statusColor(String status) => switch (status) {
        'GRADED' => AppColors.success,
        'SUBMITTED' => AppColors.primary,
        'LATE' => AppColors.warning,
        _ => AppColors.error,
      };

  String _statusLabel(String status) => switch (status) {
        'GRADED' => 'Đã chấm',
        'SUBMITTED' => 'Chờ chấm',
        'LATE' => 'Nộp trễ',
        _ => 'Chưa nộp',
      };

  @override
  Widget build(BuildContext context) {
    final pending = _submissions
        .where((s) => s.status == 'SUBMITTED' || s.status == 'LATE')
        .length;
    final graded =
        _submissions.where((s) => s.status == 'GRADED').length;
    final missing =
        _submissions.where((s) => s.status == 'NOT_SUBMITTED').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm bài tập'),
        backgroundColor: AppColors.teacherAccent,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.teacherAccent.withOpacity(0.06),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.assignmentTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                    '${widget.className} • ${widget.subject} • Hạn ${widget.deadline}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            label: 'Đã chấm',
                            value: graded,
                            color: AppColors.success)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            label: 'Chờ chấm',
                            value: pending,
                            color: AppColors.primary)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            label: 'Chưa nộp',
                            value: missing,
                            color: AppColors.error)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _submissions.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final s = _submissions[i];
                final color = _statusColor(s.status);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.teacherAccent.withOpacity(0.12),
                    radius: 18,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teacherAccent)),
                  ),
                  title: Text(s.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_statusLabel(s.status),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ),
                      const SizedBox(width: 6),
                      Text(s.submittedAt,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  trailing: s.status == 'NOT_SUBMITTED'
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s.score != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.score!.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 13),
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                  onTap: s.status == 'NOT_SUBMITTED'
                      ? null
                      : () => _gradeSubmission(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gradeSubmission(_Submission s) async {
    final scoreCtrl =
        TextEditingController(text: s.score?.toStringAsFixed(1) ?? '');
    final feedbackCtrl = TextEditingController(text: s.feedback ?? '');
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Nộp: ${s.submittedAt}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const SectionHeader(title: 'File nộp'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded,
                        color: AppColors.teacherAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BaiLam_${s.name}.pdf',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          const Text('1.2 MB',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.download_rounded, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scoreCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Điểm (0–10)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nhận xét',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final score = double.tryParse(scoreCtrl.text);
                    if (score == null || score < 0 || score > 10) return;
                    s.score = score;
                    s.feedback = feedbackCtrl.text.trim();
                    s.status = 'GRADED';
                    Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teacherAccent,
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Lưu điểm + Gửi feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chấm bài cho ${s.name}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(
      {required this.label, required this.value, required this.color});
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
