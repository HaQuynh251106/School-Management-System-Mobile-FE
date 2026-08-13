const attendanceAbsentStatuses = {
  'ABSENT_EXCUSED',
  'ABSENT_UNEXCUSED',
};

bool isAbsentAttendanceStatus(Object? status) =>
    attendanceAbsentStatuses.contains('$status');

bool isAttendancePresence(Object? status) =>
    const {'PRESENT', 'LATE'}.contains('$status');

class AttendanceMetrics {
  const AttendanceMetrics({
    required this.presentOrLate,
    required this.absent,
    required this.late,
  });

  final int presentOrLate;
  final int absent;
  final int late;

  factory AttendanceMetrics.fromRecords(
    Iterable<Map<String, dynamic>> records,
  ) {
    var presentOrLate = 0;
    var absent = 0;
    var late = 0;
    for (final record in records) {
      final status = record['status'];
      if (isAttendancePresence(status)) presentOrLate++;
      if (isAbsentAttendanceStatus(status)) absent++;
      if ('$status' == 'LATE') late++;
    }
    return AttendanceMetrics(
      presentOrLate: presentOrLate,
      absent: absent,
      late: late,
    );
  }
}
