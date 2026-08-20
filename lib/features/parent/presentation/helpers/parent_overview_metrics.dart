class ParentOverviewMetrics {
  const ParentOverviewMetrics({
    required this.averageScore,
    required this.presentCount,
    required this.absentCount,
    required this.attendanceCount,
  });

  final double? averageScore;
  final int presentCount;
  final int absentCount;
  final int attendanceCount;

  bool get hasAttendance => attendanceCount > 0;
}

/// Builds the Parent overview from the same grade and attendance sources used
/// by the detail tabs. `LATE` means the student attended and is never counted
/// as absent.
ParentOverviewMetrics buildParentOverviewMetrics({
  required List<Map<String, dynamic>> gradeSummaries,
  required List<Map<String, dynamic>> attendance,
}) {
  final average = averageFromGradeSummaries(gradeSummaries);

  var present = 0;
  var absent = 0;
  for (final record in attendance) {
    switch ('${record['status'] ?? ''}'.toUpperCase()) {
      case 'PRESENT':
      case 'LATE':
        present++;
      case 'ABSENT_EXCUSED':
      case 'ABSENT_UNEXCUSED':
        absent++;
    }
  }

  return ParentOverviewMetrics(
    averageScore: average,
    presentCount: present,
    absentCount: absent,
    attendanceCount: attendance.length,
  );
}

double? averageFromGradeSummaries(List<Map<String, dynamic>> gradeSummaries) {
  final averages = gradeSummaries
      .map((item) => item['average'])
      .whereType<num>()
      .map((value) => value.toDouble())
      .toList();
  return averages.isEmpty
      ? null
      : averages.reduce((left, right) => left + right) / averages.length;
}
