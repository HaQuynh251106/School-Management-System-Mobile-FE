import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/timetable/data/timetable_slot.dart';

void main() {
  test('maps a published timetable slot without raw casts in the UI', () {
    final slot = TimetableSlot.fromJson({
      'id': 'slot-1',
      'classId': 'class-1',
      'classCode': '10A1',
      'subjectId': 'subject-1',
      'subjectName': 'Toán',
      'teacherId': 'teacher-1',
      'teacherName': 'Nguyễn Minh',
      'roomCode': 'P201',
      'dayOfWeek': 'MON',
      'periodNo': 2,
      'startTime': '07:50',
      'endTime': '08:35',
      'semesterId': 'semester-1',
      'publishedPlanId': 'plan-1',
    });

    expect(slot.subjectName, 'Toán');
    expect(slot.periodNo, 2);
    expect(slot.publishedPlanId, 'plan-1');
  });
}
