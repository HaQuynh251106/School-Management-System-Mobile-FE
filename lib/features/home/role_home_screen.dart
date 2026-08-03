import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../app/session.dart';
import '../dashboard/dashboard_screen.dart';
import '../inbox/inbox_screen.dart';
import '../modules/module_hub_screen.dart';
import '../profile/profile_screen.dart';

class RoleHomeScreen extends StatefulWidget {
  const RoleHomeScreen({super.key});

  @override
  State<RoleHomeScreen> createState() => _RoleHomeScreenState();
}

class _RoleHomeScreenState extends State<RoleHomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final user = session.user;
    if (user == null) return const SizedBox.shrink();
    final config = RoleNavigation.forRole(user.role);
    final accent = AppPalette.role(user.role);
    final inboxUnread = session.notificationUnread + session.chatUnread;
    final pages = [
      DashboardScreen(role: user.role, accent: accent),
      ModuleHubScreen(group: config.primaryGroup, accent: accent),
      ModuleHubScreen(group: config.secondaryGroup, accent: accent),
      InboxScreen(accent: accent),
      ProfileScreen(accent: accent),
    ];
    final stack = IndexedStack(index: index, children: pages);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: (value) =>
                        setState(() => index = value),
                    extended: constraints.maxWidth >= 1080,
                    groupAlignment: -.8,
                    minExtendedWidth: 225,
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      child: _AppMark(accent: accent),
                    ),
                    destinations: config.destinations.indexed
                        .map(
                          (entry) => NavigationRailDestination(
                            icon: _NavIcon(
                              icon: entry.$2.icon,
                              count: entry.$1 == 3 ? inboxUnread : 0,
                            ),
                            selectedIcon: _NavIcon(
                              icon: entry.$2.selectedIcon,
                              count: entry.$1 == 3 ? inboxUnread : 0,
                              color: accent,
                            ),
                            label: Text(entry.$2.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: stack),
              ],
            ),
          );
        }
        return Scaffold(
          body: stack,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            indicatorColor: accent.withValues(alpha: .12),
            destinations: config.destinations.indexed
                .map(
                  (entry) => NavigationDestination(
                    icon: _NavIcon(
                      icon: entry.$2.icon,
                      count: entry.$1 == 3 ? inboxUnread : 0,
                    ),
                    selectedIcon: _NavIcon(
                      icon: entry.$2.selectedIcon,
                      count: entry.$1 == 3 ? inboxUnread : 0,
                      color: accent,
                    ),
                    label: entry.$2.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, this.count = 0, this.color});
  final IconData icon;
  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text(count > 99 ? '99+' : '$count'),
    child: Icon(icon, color: color),
  );
}

class _AppMark extends StatelessWidget {
  const _AppMark({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: .22),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: const Icon(Icons.school_rounded, color: Colors.white),
  );
}

class RoleNavigation {
  const RoleNavigation(
    this.destinations,
    this.primaryGroup,
    this.secondaryGroup,
  );
  final List<RoleNavItem> destinations;
  final ModuleGroup primaryGroup;
  final ModuleGroup secondaryGroup;

  static RoleNavigation forRole(String role) => switch (role) {
    'ADMIN' => const RoleNavigation(
      [
        RoleNavItem(
          'Tổng quan',
          Icons.dashboard_outlined,
          Icons.dashboard_rounded,
        ),
        RoleNavItem('Con người', Icons.people_outline, Icons.people_rounded),
        RoleNavItem('Vận hành', Icons.hub_outlined, Icons.hub_rounded),
        RoleNavItem('Hộp thư', Icons.forum_outlined, Icons.forum_rounded),
        RoleNavItem('Cá nhân', Icons.person_outline, Icons.person_rounded),
      ],
      ModuleGroup.adminPeople,
      ModuleGroup.adminOperations,
    ),
    'TEACHER' => const RoleNavigation(
      [
        RoleNavItem('Hôm nay', Icons.today_outlined, Icons.today_rounded),
        RoleNavItem(
          'Giảng dạy',
          Icons.co_present_outlined,
          Icons.co_present_rounded,
        ),
        RoleNavItem(
          'Công việc',
          Icons.task_alt_outlined,
          Icons.task_alt_rounded,
        ),
        RoleNavItem('Trao đổi', Icons.forum_outlined, Icons.forum_rounded),
        RoleNavItem('Cá nhân', Icons.person_outline, Icons.person_rounded),
      ],
      ModuleGroup.teacherTeaching,
      ModuleGroup.teacherWork,
    ),
    'PARENT' => const RoleNavigation(
      [
        RoleNavItem('Tổng quan', Icons.home_outlined, Icons.home_rounded),
        RoleNavItem('Học tập', Icons.school_outlined, Icons.school_rounded),
        RoleNavItem(
          'Tài chính',
          Icons.account_balance_wallet_outlined,
          Icons.account_balance_wallet_rounded,
        ),
        RoleNavItem('Trao đổi', Icons.forum_outlined, Icons.forum_rounded),
        RoleNavItem('Cá nhân', Icons.person_outline, Icons.person_rounded),
      ],
      ModuleGroup.parentLearning,
      ModuleGroup.parentFinance,
    ),
    _ => const RoleNavigation(
      [
        RoleNavItem('Hôm nay', Icons.home_outlined, Icons.home_rounded),
        RoleNavItem('Học tập', Icons.school_outlined, Icons.school_rounded),
        RoleNavItem('Nhiệm vụ', Icons.task_outlined, Icons.task_rounded),
        RoleNavItem('Trao đổi', Icons.forum_outlined, Icons.forum_rounded),
        RoleNavItem('Cá nhân', Icons.person_outline, Icons.person_rounded),
      ],
      ModuleGroup.studentLearning,
      ModuleGroup.studentTasks,
    ),
  };
}

class RoleNavItem {
  const RoleNavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
