import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/widgets/upcoming_exam_banner.dart';

void main() {
  testWidgets('hiển thị rõ kỳ thi sắp diễn ra và thông tin phòng thi', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamBanner(
            exams: const [
              {
                'subjectName': 'Toán',
                'examDate': '2026-08-20',
                'startTime': '08:00',
                'roomCode': 'P201',
                'status': 'UPCOMING',
              },
            ],
            accent: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Kỳ thi sắp diễn ra'), findsOneWidget);
    expect(find.textContaining('Toán'), findsOneWidget);
    expect(find.textContaining('Phòng P201'), findsOneWidget);
  });

  testWidgets('phụ huynh thấy tên con khi kỳ thi diễn ra hôm nay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamBanner(
            exams: const [
              {
                'subjectName': 'Ngữ văn',
                'examDate': '2026-08-12',
                'startTime': '07:00',
                'status': 'TODAY',
              },
            ],
            accent: Colors.purple,
            studentName: 'Nguyễn Minh An',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('Kỳ thi diễn ra hôm nay của Nguyễn Minh An'),
      findsOneWidget,
    );
  });

  testWidgets('không cảnh báo kỳ thi đã hoàn thành', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingExamBanner(
            exams: const [
              {'subjectName': 'Toán', 'status': 'COMPLETED'},
            ],
            accent: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Kỳ thi'), findsNothing);
  });
}
