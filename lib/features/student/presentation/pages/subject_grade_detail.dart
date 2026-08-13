import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../grades/data/grade_record.dart';

class _ExamScore {
  const _ExamScore(this.category, this.label, this.assessmentIndex, this.score,
      this.weight, this.date);
  final String category;
  final String label;
  final int assessmentIndex;
  final double score;
  final double weight;
  final String date;
}

/// Định dạng recordedAt (ISO-8601) -> 'dd/MM/yyyy'. Trả chuỗi gốc nếu không
/// parse được, '' nếu null/blank.
String _formatRecordedAt(Object? raw) {
  final s = (raw ?? '').toString();
  if (s.isEmpty) return '';
  final dt = DateTime.tryParse(s);
  if (dt == null) return s;
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}

_ExamScore _examScoreFromJson(
  Map<String, dynamic> m,
  Map<String, GradeCategoryDefinition> definitions,
) {
  final category = (m['category'] ?? '').toString();
  final rawScore = m['score'];
  final definition = definitions[category];
  return _ExamScore(
    category,
    (m['categoryName'] ?? definition?.name ?? category).toString(),
    (m['assessmentIndex'] as num?)?.toInt() ?? 1,
    rawScore == null ? 0 : (rawScore as num).toDouble(),
    definition?.weight ?? 1.0,
    _formatRecordedAt(m['recordedAt']),
  );
}

class SubjectGradeDetail extends StatefulWidget {
  const SubjectGradeDetail({
    super.key,
    required this.subject,
    required this.subjectId,
    required this.semesterId,
    required this.semester,
    required this.average,
  });

  final String subject;
  final String subjectId;
  final String semesterId;
  final String semester;
  final double? average;

  @override
  State<SubjectGradeDetail> createState() => _SubjectGradeDetailState();
}

class _SubjectGradeDetailState extends State<SubjectGradeDetail> {
  late final Future<List<List<Map<String, dynamic>>>> _future = Future.wait([
    sl<ApiService>().grades(
      subjectId: widget.subjectId,
      semesterId: widget.semesterId,
    ),
    sl<ApiService>().examCategories(),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm — ${widget.subject}'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải chi tiết điểm.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final data = snap.data ?? const [];
          final definitions = {
            for (final definition
                in (data.length > 1 ? data[1] : const <Map<String, dynamic>>[])
                    .map(GradeCategoryDefinition.fromJson))
              definition.code: definition,
          };
          final scores =
              (data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[])
                  .where((grade) =>
                      '${grade['subjectId'] ?? ''}' == widget.subjectId &&
                      '${grade['semesterId'] ?? ''}' == widget.semesterId)
                  .map((grade) => _examScoreFromJson(grade, definitions))
                  .toList();
          return _SubjectGradeView(
            subject: widget.subject,
            semester: widget.semester,
            scores: scores,
            average: widget.average,
          );
        },
      ),
    );
  }
}

class _SubjectGradeView extends StatelessWidget {
  const _SubjectGradeView({
    required this.subject,
    required this.semester,
    required this.scores,
    required this.average,
  });

  final String subject;
  final String semester;
  final List<_ExamScore> scores;
  final double? average;

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6.5) return AppColors.warning;
    if (score >= 5) return AppColors.late;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return Center(
        child: Text('Chưa có điểm',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }
    final avg = average;
    final byCategory = <String, List<_ExamScore>>{};
    for (final s in scores) {
      byCategory.putIfAbsent(s.category, () => []).add(s);
    }

    return ListView(
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
                painter: _LineChartPainter(
                  scores,
                  gridColor: Theme.of(context).colorScheme.outlineVariant,
                  axisColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: Container(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...byCategory.entries
            .map((e) => _buildCategorySection(context, e.key, e.value)),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Kết quả môn học'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in byCategory.entries)
                  _FormulaRow(
                    entry.value.first.label,
                    'hệ số ${entry.value.first.weight.toStringAsFixed(0)}',
                  ),
                const Divider(),
                Row(
                  children: [
                    const Text('Trung bình môn',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      avg?.toStringAsFixed(1) ?? 'Chưa đủ đầu điểm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: avg == null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : _scoreColor(avg),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double? avg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.studentAccent,
            AppColors.studentAccent.withValues(alpha: 0.7),
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                avg?.toStringAsFixed(1) ?? '—',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    avg == null
                        ? 'Chưa đủ đầu điểm'
                        : avg >= 8
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

  Widget _buildCategorySection(
      BuildContext context, String category, List<_ExamScore> scores) {
    final categoryName = const {
          'ORAL': 'Điểm miệng',
          '15M': 'Điểm 15 phút',
          'MID': 'Điểm giữa kỳ',
          'FINAL': 'Điểm cuối kỳ',
        }[category] ??
        (category.isEmpty ? 'Khác' : category);

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
                        color: _scoreColor(scores[i].score)
                            .withValues(alpha: 0.12),
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
                    title: Text(
                        '${scores[i].label} ${scores[i].assessmentIndex}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(
                      '${scores[i].date} • hệ số ${scores[i].weight.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
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
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(
    this.scores, {
    required this.gridColor,
    required this.axisColor,
  });
  final List<_ExamScore> scores;
  final Color gridColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final axisStyle = TextStyle(
      color: axisColor,
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
          AppColors.studentAccent.withValues(alpha: 0.25),
          AppColors.studentAccent.withValues(alpha: 0.0),
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
