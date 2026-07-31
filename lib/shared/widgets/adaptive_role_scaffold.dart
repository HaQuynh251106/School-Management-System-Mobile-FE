import 'package:flutter/material.dart';

class RoleDestination {
  const RoleDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Khung điều hướng chung: thanh dưới trên điện thoại, NavigationRail trên
/// máy tính bảng. IndexedStack giữ nguyên dữ liệu và vị trí cuộn giữa các tab.
class AdaptiveRoleScaffold extends StatelessWidget {
  const AdaptiveRoleScaffold({
    super.key,
    required this.index,
    required this.onSelected,
    required this.pages,
    required this.destinations,
    required this.accent,
    this.floatingActionButton,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final List<Widget> pages;
  final List<RoleDestination> destinations;
  final Color accent;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final stack = IndexedStack(index: index, children: pages);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Scaffold(
            floatingActionButton: floatingActionButton,
            body: Row(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                    child: NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: onSelected,
                      groupAlignment: -0.82,
                      labelType: constraints.maxWidth >= 1050
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      extended: constraints.maxWidth >= 1050,
                      minExtendedWidth: 220,
                      useIndicator: true,
                      indicatorColor: accent.withValues(alpha: 0.14),
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent,
                                Color.lerp(accent, Colors.black, .2)!
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child:
                                Icon(Icons.school_rounded, color: Colors.white),
                          ),
                        ),
                      ),
                      destinations: destinations
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon:
                                  Icon(item.selectedIcon, color: accent),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
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
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: onSelected,
              indicatorColor: accent.withValues(alpha: 0.14),
              destinations: destinations
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon, color: accent),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
