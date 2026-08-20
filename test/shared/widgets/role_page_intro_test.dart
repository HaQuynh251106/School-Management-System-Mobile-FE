import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/theme/app_colors.dart';
import 'package:sse_mobile/core/theme/app_theme.dart';
import 'package:sse_mobile/shared/widgets/role_page_intro.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('thẻ giới thiệu hiển thị rõ ở ${brightness.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: RolePageIntro(
                  title: 'Lịch dạy trong ngày',
                  subtitle: 'Hai tiết dạy cần chuẩn bị.',
                  accent: AppColors.teacherAccent,
                  icon: Icons.co_present_rounded,
                  badges: ['2 tiết dạy', '1 lớp'],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lịch dạy trong ngày'), findsOneWidget);
      expect(find.text('Hai tiết dạy cần chuẩn bị.'), findsOneWidget);
      expect(find.text('2 tiết dạy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
