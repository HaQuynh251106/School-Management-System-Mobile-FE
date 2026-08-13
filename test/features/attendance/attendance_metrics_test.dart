import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/attendance/data/attendance_metrics.dart';

void main() {
  test('đi muộn không bị tính thành vắng trong dashboard', () {
    final metrics = AttendanceMetrics.fromRecords(const [
      {'status': 'PRESENT'},
      {'status': 'LATE'},
      {'status': 'ABSENT_EXCUSED'},
      {'status': 'ABSENT_UNEXCUSED'},
    ]);

    expect(metrics.presentOrLate, 2);
    expect(metrics.late, 1);
    expect(metrics.absent, 2);
  });

  test('chỉ hai trạng thái absent kích hoạt cảnh báo vắng', () {
    expect(isAbsentAttendanceStatus('PRESENT'), isFalse);
    expect(isAbsentAttendanceStatus('LATE'), isFalse);
    expect(isAbsentAttendanceStatus('ABSENT_EXCUSED'), isTrue);
    expect(isAbsentAttendanceStatus('ABSENT_UNEXCUSED'), isTrue);
  });
}
