import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class _ExamScore {
  const _ExamScore(this.label, this.score, this.weight, this.date);
  final String label;
  final double score;
  final double weight;
  final String date;
}

class ParentSubjectDetail extends StatelessWidget {
  const ParentSubjectDetail({
    super.key,
    required this.childName,
    required this.subject,
    required this.semester,
  });

  final String childName;
  final String subject;
  final String semester;

  static const _scores = [
    _ExamScore('Miệng', 9.0, 1, '10/09'),
    _ExamScore('15 phút', 8.5, 1, '15/10'),
    _ExamScore('Giữa kỳ', 7.5, 2, '20/10'),
    _ExamScore('Cuối kỳ', 8.8, 3, '15/12'),
  ];

  double get _avg {
    var sum = 0.0;
    var sumW = 0.0;
    for (final s in _scores) {
      sum += s.score * s.weight;
      sumW += s.weight;
    }
    return sum / sumW;
  }

  Color _scoreColor(double s) {
    if (s >= 8) return AppColors.success;
    if (s >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final avg = _avg;
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm — $subject'),
        backgroundColor: AppColors.parentAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.parentAccent,
                  AppColors.parentAccent.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(childName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Text(semester,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Chi tiết từng bài'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < _scores.length; i++) ...[
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _scoreColor(_scores[i].score)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _scores[i].score.toStringAsFixed(1),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _scoreColor(_scores[i].score)),
                        ),
                      ),
                    ),
                    title: Text(_scores[i].label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(
                      '${_scores[i].date} • hệ số ${_scores[i].weight.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  if (i < _scores.length - 1) const Divider(height: 0),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Nhận xét của GVCN'),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.parentAccent,
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trần Thị Hoa',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('GVCN lớp 10A1',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      Spacer(),
                      Text('20/12',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Em An có nhiều tiến bộ ở giữa kỳ, đặc biệt phần hình học. '
                    'Cần luyện thêm bài tập đại số. Nhờ phụ huynh nhắc em ôn '
                    'thêm chương 4 vào dịp cuối tuần.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã mở chat với GV bộ môn.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Trao đổi với GV bộ môn'),
          ),
        ],
      ),
    );
  }
}
