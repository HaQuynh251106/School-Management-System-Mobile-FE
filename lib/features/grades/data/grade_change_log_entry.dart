class GradeChangeLogEntry {
  const GradeChangeLogEntry({
    required this.id,
    required this.gradeId,
    required this.studentName,
    required this.subjectName,
    required this.categoryName,
    required this.action,
    required this.oldScore,
    required this.newScore,
    required this.reason,
    required this.changedAt,
  });

  final String id;
  final String gradeId;
  final String studentName;
  final String subjectName;
  final String categoryName;
  final String action;
  final double? oldScore;
  final double? newScore;
  final String reason;
  final DateTime? changedAt;

  String get subjectCategoryLabel =>
      categoryName.isEmpty ? subjectName : '$subjectName — $categoryName';
}

/// Enriches per-grade audit rows with the corresponding grade and student
/// metadata, then sorts newest first. The backend exposes change logs per
/// grade, so callers collect those responses before using this pure mapper.
List<GradeChangeLogEntry> buildGradeChangeLogEntries({
  required Iterable<Map<String, dynamic>> grades,
  required Map<String, Iterable<Map<String, dynamic>>> logsByGrade,
  required Map<String, String> studentNames,
}) {
  final gradeById = <String, Map<String, dynamic>>{
    for (final grade in grades)
      if ('${grade['id'] ?? ''}'.isNotEmpty) '${grade['id']}': grade,
  };
  final entries = <GradeChangeLogEntry>[];

  for (final item in logsByGrade.entries) {
    final grade = gradeById[item.key];
    if (grade == null) continue;
    final studentId = '${grade['studentId'] ?? ''}';
    for (final log in item.value) {
      final oldScore = log['oldScore'];
      final newScore = log['newScore'];
      entries.add(
        GradeChangeLogEntry(
          id: '${log['id'] ?? ''}',
          gradeId: '${log['gradeId'] ?? item.key}',
          studentName: studentNames[studentId] ?? 'Học sinh',
          subjectName: '${grade['subjectName'] ?? 'Môn học'}',
          categoryName: '${grade['categoryName'] ?? grade['category'] ?? ''}',
          action: '${log['action'] ?? ''}',
          oldScore: oldScore is num ? oldScore.toDouble() : null,
          newScore: newScore is num ? newScore.toDouble() : null,
          reason: '${log['reason'] ?? ''}'.trim(),
          changedAt: DateTime.tryParse('${log['changedAt'] ?? ''}'),
        ),
      );
    }
  }

  entries.sort((left, right) {
    final leftTime = left.changedAt;
    final rightTime = right.changedAt;
    if (leftTime == null && rightTime == null) return 0;
    if (leftTime == null) return 1;
    if (rightTime == null) return -1;
    return rightTime.compareTo(leftTime);
  });
  return entries;
}
