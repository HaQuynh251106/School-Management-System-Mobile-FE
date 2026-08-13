import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/widgets/school_day_status.dart';

void main() {
  test('schoolWeekDates returns Monday through Saturday across months', () {
    final dates = schoolWeekDates(DateTime(2026, 9, 3));

    expect(dates, hasLength(6));
    expect(dates.first, DateTime(2026, 8, 31));
    expect(dates.last, DateTime(2026, 9, 5));
  });

  testWidgets('holiday banner shows title, range, reason and policy', (
    tester,
  ) async {
    final status = SchoolDayStatus(
      date: DateTime(2026, 9, 2),
      attendanceRequired: false,
      title: 'Nghỉ Quốc khánh',
      reason: 'Nhà trường nghỉ theo lịch chung.',
      holidayStartDate: DateTime(2026, 9, 1),
      holidayEndDate: DateTime(2026, 9, 2),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SchoolHolidayBanner(status: status, accent: Colors.blue),
        ),
      ),
    );

    expect(find.text('Nghỉ toàn trường'), findsOneWidget);
    expect(find.text('Nghỉ Quốc khánh'), findsOneWidget);
    expect(find.text('01/09/2026 - 02/09/2026'), findsOneWidget);
    expect(find.text('Nhà trường nghỉ theo lịch chung.'), findsOneWidget);
    expect(
      find.text(
        'Không xếp tiết học và không yêu cầu điểm danh trong thời gian này.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('regular school day renders no banner', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SchoolHolidayBanner(
          status: SchoolDayStatus.regular(DateTime(2026, 9, 3)),
          accent: Colors.blue,
        ),
      ),
    );

    expect(find.text('Nghỉ toàn trường'), findsNothing);
  });
}
