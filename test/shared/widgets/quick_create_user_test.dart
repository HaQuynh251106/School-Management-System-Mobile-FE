import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/di/service_locator.dart';
import 'package:sse_mobile/core/network/api_service.dart';
import 'package:sse_mobile/shared/widgets/quick_create.dart';

void main() {
  late Dio dio;

  setUp(() async {
    await sl.reset();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:4000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final data = switch (options.path) {
            '/classes' => <Map<String, dynamic>>[
              {
                'id': 'class-10a1',
                'code': '10A1',
                'name': 'Lớp 10A1',
                'gradeLevel': 'K10',
                'studyShift': 'MORNING',
                'capacity': 40,
                'studentCount': 0,
              },
            ],
            '/subjects' => <Map<String, dynamic>>[
              {
                'id': 'subject-math',
                'code': 'TOAN',
                'name': 'Toán',
                'coefficient': 1,
              },
            ],
            _ => <String, dynamic>{'id': 'created-id'},
          };
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: data),
          );
        },
      ),
    );
    sl.registerSingleton<ApiService>(ApiService(dio));
  });

  tearDown(() async => sl.reset());

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuickCreateButton(role: 'ADMIN', accent: Colors.teal),
        ),
      ),
    );
    await tester.tap(find.text('Thêm mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Người dùng'));
    await tester.pumpAndSettle();
  }

  testWidgets('user form requires email and phone and hides manual codes', (
    tester,
  ) async {
    await openForm(tester);

    await tester.enterText(
      find.byKey(const ValueKey('quick-create-name')),
      'Học sinh kiểm thử',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quick-create-username')),
      'hs.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quick-create-password')),
      'Password123@',
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-create-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-create-phone')), findsOneWidget);
    expect(
      find.text('Mã học sinh sẽ được hệ thống tự tạo để tránh trùng.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('quick-create-studentCode')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('quick-create-teacherCode')),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Tạo mới'));
    await tester.pump();

    expect(find.text('Vui lòng nhập Email'), findsOneWidget);
    expect(find.text('Vui lòng nhập Số điện thoại'), findsOneWidget);
  });

  testWidgets('teacher chooses its main subject from the school catalog', (
    tester,
  ) async {
    await openForm(tester);

    await tester.tap(find.text('Học sinh').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giáo viên').last);
    await tester.pumpAndSettle();

    expect(find.text('Môn giảng dạy chính'), findsOneWidget);
    expect(find.text('TOAN'), findsOneWidget);
    expect(
      find.text('Mã giáo viên sẽ được hệ thống tự tạo để tránh trùng.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('quick-create-mainSubject')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('quick-create-teacherCode')),
      findsNothing,
    );
  });
}
