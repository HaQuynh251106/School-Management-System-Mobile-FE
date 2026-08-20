import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/theme/app_colors.dart';
import 'package:sse_mobile/core/theme/app_theme.dart';
import 'package:sse_mobile/shared/widgets/accent_tab_bar.dart';

void main() {
  for (final entry in <String, ThemeData>{
    'sáng': AppTheme.light,
    'tối': AppTheme.dark,
  }.entries) {
    testWidgets('tab AppBar có chữ chọn dễ đọc ở giao diện ${entry.key}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: entry.value,
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.adminAccent,
                bottom: const AccentTabBar(
                  accent: AppColors.adminAccent,
                  tabs: [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Giáo viên'),
                  ],
                ),
              ),
              body: const TabBarView(children: [SizedBox(), SizedBox()]),
            ),
          ),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.labelColor, AppColors.adminAccent);
      expect(tabBar.unselectedLabelColor, isNot(equals(Colors.transparent)));
      final indicator = tabBar.indicator! as BoxDecoration;
      expect(indicator.color, Colors.white);
      expect(
        _contrast(indicator.color!, tabBar.labelColor!),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}

double _contrast(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + .05) / (darker + .05);
}
