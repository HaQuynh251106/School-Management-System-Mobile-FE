import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../grades/data/grade_record.dart';

class ParentSubjectDetail extends StatelessWidget {
  const ParentSubjectDetail({
    super.key,
    required this.childName,
    required this.subject,
    required this.subjectId,
    required this.semesterId,
    required this.semester,
    required this.records,
    required this.columns,
    required this.average,
  });

  final String childName;
  final String subject;
  final String subjectId;
  final String semesterId;
  final String semester;
  final Map<String, GradeRecord> records;
  final List<GradeColumn> columns;
  final double? average;

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.parentAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    average?.toStringAsFixed(1) ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
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
          const SectionHeader(title: 'Các đầu điểm từ hệ thống'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: List.generate(columns.length, (index) {
                final column = columns[index];
                final score = records[column.key]?.score;
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (score == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : _scoreColor(score))
                            .withValues(alpha: 0.12),
                        child: Text(score?.toStringAsFixed(1) ?? '—',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: score == null
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : _scoreColor(score))),
                      ),
                      title: Text(column.label),
                      subtitle:
                          Text('Hệ số ${column.weight.toStringAsFixed(0)}'),
                    ),
                    if (index < columns.length - 1) const Divider(height: 0),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
