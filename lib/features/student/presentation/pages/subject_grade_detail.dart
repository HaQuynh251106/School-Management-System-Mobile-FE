import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class _ExamScore {
  const _ExamScore(this.category, this.label, this.score, this.weight, this.date);
  final String category;
  final String label;
  final double score;
  final double weight;
  final String date;
}

class SubjectGradeDetail extends StatelessWidget {
  const SubjectGradeDetail({
    super.key,
    required this.subject,
    required this.semester,
  });

  final String subject;
  final String semester;

  static const _scores = [
    _ExamScore('ORAL', 'Miệng lần 1', 9.0, 1.0, '10/09/2025'),
    _ExamScore('ORAL', 'Miệng lần 2', 8.0, 1.0, '24/09/2025'),
    _ExamScore('15M', '15 phút lần 1', 8.5, 1.0, '15/10/2025'),
    _ExamScore('15M', '15 phút lần 2', 7.5, 1.0, '05/11/2025'),
    _ExamScore('MID', 'Giữa kỳ', 7.5, 2.0, '20/10/2025'),
    _ExamScore('FINAL', 'Cuối kỳ', 8.8, 3.0, '15/12/2025'),
  ];

  double get _weightedAvg {
    final totalWeight = _scores.fold<double>(0, (s, e) => s + e.weight);
    final weighted = _scores.fold<double>(0, (s, e) => s + e.score * e.weight);
    return weighted / totalWeight;
  }

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6.5) return AppColors.warning;
    if (score >= 5) return AppColors.late;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final avg = _weightedAvg;
    final byCategory = <String, List<_ExamScore>>{};
    for (final s in _scores) {
      byCategory.putIfAbsent(s.category, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm — $subject'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(avg),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Biểu đồ điểm theo thời gian'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
              child: SizedBox(
                height: 160,
                child: CustomPaint(
                  painter: _LineChartPainter(_scores),
                  child: Container(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...byCategory.entries.map((e) => _buildCategorySection(e.key, e.value)),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Trung bình (có trọng số)'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormulaRow('Miệng & 15p', 'hệ số 1'),
                  _FormulaRow('Giữa kỳ', 'hệ số 2'),
                  _FormulaRow('Cuối kỳ', 'hệ số 3'),
                  const Divider(),
                  Row(
                    children: [
                      const Text('Trung bình môn',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(
                        avg.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: _scoreColor(avg),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double avg) {
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
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
                Text(
                  subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  semester,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    avg >= 8
                        ? 'Giỏi'
                        : avg >= 6.5
                            ? 'Khá'
                            : avg >= 5
                                ? 'Trung bình'
                                : 'Yếu',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<_ExamScore> scores) {
    final categoryName = {
      'ORAL': 'Điểm miệng',
      '15M': 'Điểm 15 phút',
      'MID': 'Điểm giữa kỳ',
      'FINAL': 'Điểm cuối kỳ',
    }[category]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: categoryName),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < scores.length; i++) ...[
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _scoreColor(scores[i].score).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          scores[i].score.toStringAsFixed(1),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _scoreColor(scores[i].score)),
                        ),
                      ),
                    ),
                    title: Text(scores[i].label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(
                      '${scores[i].date} • hệ số ${scores[i].weight.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  if (i < scores.length - 1) const Divider(height: 0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.scores);
  final List<_ExamScore> scores;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.5;

    final axisStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
    );

    // Horizontal grid lines for scores 0,2,4,6,8,10
    for (var i = 0; i <= 5; i++) {
      final y = h - (h / 5) * i;
      canvas.drawLine(Offset(28, y), Offset(w, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${i * 2}', style: axisStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    if (scores.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.studentAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = AppColors.studentAccent;
    final dotInner = Paint()..color = Colors.white;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.studentAccent.withOpacity(0.25),
          AppColors.studentAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(28, 0, w - 28, h));

    final path = Path();
    final fillPath = Path();
    final step = (w - 28) / (scores.length - 1).clamp(1, 999);

    for (var i = 0; i < scores.length; i++) {
      final x = 28 + step * i;
      final y = h - (scores[i].score / 10) * h;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (scores.length > 1) {
      fillPath.lineTo(28 + step * (scores.length - 1), h);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < scores.length; i++) {
      final x = 28 + step * i;
      final y = h - (scores[i].score / 10) * h;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
