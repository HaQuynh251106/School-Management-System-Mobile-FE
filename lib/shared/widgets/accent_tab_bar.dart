import 'package:flutter/material.dart';

/// Tab bar đặt trong AppBar màu thương hiệu.
///
/// Tab được chọn dùng nền trắng và chữ theo màu vai trò để luôn đủ tương phản
/// ở cả giao diện sáng và tối. Widget này cũng tránh việc TabBarTheme toàn cục
/// tạo nền bạc hà nhưng màn hình lại ép chữ trắng.
class AccentTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AccentTabBar({
    super.key,
    required this.accent,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  final Color accent;
  final List<Widget> tabs;
  final TabController? controller;
  final bool isScrollable;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) => TabBar(
    controller: controller,
    isScrollable: isScrollable,
    dividerColor: Colors.transparent,
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    indicator: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    labelColor: accent,
    unselectedLabelColor: Colors.white.withValues(alpha: .78),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    tabs: tabs,
  );
}
