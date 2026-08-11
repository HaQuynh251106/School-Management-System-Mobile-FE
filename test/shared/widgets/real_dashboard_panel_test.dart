import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/widgets/real_dashboard_panel.dart';

void main() {
  testWidgets('renders real snapshot metadata, metrics, errors and shortcut',
      (tester) async {
    Map<String, dynamic>? selected;
    var retried = false;
    final dashboard = <String, dynamic>{
      'asOf': '2026-08-10T03:15:00Z',
      'scope': {
        'role': 'STUDENT',
        'objectType': 'STUDENT',
        'objectIds': ['u-student-1'],
      },
      'metrics': [
        {
          'key': 'assignments',
          'label': 'Bài tập cần nộp',
          'value': 2,
          'format': 'NUMBER',
          'hint': 'Dữ liệu thật',
          'trend': {
            'direction': 'NONE',
            'label': 'Chưa đủ dữ liệu kỳ trước',
          },
        },
      ],
      'charts': const [],
      'shortcuts': [
        {
          'key': 'upcoming-assignment',
          'label': 'Bài tập sắp đến hạn',
          'target': 'assignments',
          'filters': {'status': 'OPEN'},
        },
      ],
      'errors': [
        {
          'widget': 'exams',
          'message': 'Không tải được dữ liệu khảo thí',
          'retryable': true,
        },
      ],
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RealDashboardPanel(
            dashboard: dashboard,
            accent: Colors.blue,
            onRetry: () => retried = true,
            onShortcut: (value) => selected = value,
          ),
        ),
      ),
    ));

    expect(find.text('Bài tập cần nộp'), findsOneWidget);
    expect(find.text('Bài tập sắp đến hạn'), findsOneWidget);
    expect(find.text('Không tải được dữ liệu khảo thí'), findsOneWidget);
    expect(find.textContaining('Phạm vi 1 hồ sơ'), findsOneWidget);

    await tester.tap(find.text('Bài tập sắp đến hạn'));
    expect(selected?['target'], 'assignments');
    await tester.tap(find.byTooltip('Thử lại'));
    expect(retried, isTrue);
  });
}
