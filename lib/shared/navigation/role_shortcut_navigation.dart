import 'package:flutter/material.dart';

import '../widgets/mobile_workspace_page.dart';
import '../widgets/notification_center.dart';

enum RoleShortcutKind { mainTab, notifications, workspace }

class RoleShortcutDestination {
  const RoleShortcutDestination._(this.kind, this.tabIndex);

  const RoleShortcutDestination.mainTab(int tabIndex)
    : this._(RoleShortcutKind.mainTab, tabIndex);

  const RoleShortcutDestination.notifications()
    : this._(RoleShortcutKind.notifications, null);

  const RoleShortcutDestination.workspace()
    : this._(RoleShortcutKind.workspace, null);

  final RoleShortcutKind kind;
  final int? tabIndex;
}

RoleShortcutDestination resolveRoleShortcut({
  required String role,
  required String target,
}) {
  final normalizedRole = role.trim().toUpperCase();
  final normalizedTarget = target.trim().toLowerCase();
  if (normalizedTarget == 'notifications') {
    return const RoleShortcutDestination.notifications();
  }
  if (normalizedTarget == 'exams') {
    return const RoleShortcutDestination.workspace();
  }

  final tab = switch ((normalizedRole, normalizedTarget)) {
    ('TEACHER', 'timetable') => 0,
    ('TEACHER', 'attendance') => 1,
    ('TEACHER', 'grades') => 2,
    ('TEACHER', 'assignments') => 3,
    ('STUDENT', 'timetable') => 0,
    ('STUDENT', 'assignments') => 1,
    ('STUDENT', 'grades') => 2,
    ('STUDENT', 'attendance') => 3,
    ('PARENT', 'grades') => 1,
    ('PARENT', 'attendance') => 2,
    ('PARENT', 'finance') => 3,
    _ => null,
  };
  return tab == null
      ? const RoleShortcutDestination.workspace()
      : RoleShortcutDestination.mainTab(tab);
}

Future<void> openRoleWorkspace({
  required BuildContext context,
  required String role,
  required Color accent,
  required ValueChanged<int> onNavigate,
  String? childId,
}) async {
  final shortcut = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      builder: (_) =>
          MobileWorkspacePage(role: role, accent: accent, childId: childId),
    ),
  );
  if (!context.mounted || shortcut == null) return;

  final destination = resolveRoleShortcut(
    role: role,
    target: '${shortcut['target'] ?? ''}',
  );
  switch (destination.kind) {
    case RoleShortcutKind.mainTab:
      onNavigate(destination.tabIndex!);
    case RoleShortcutKind.notifications:
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NotificationCenter(accent: accent)),
      );
    case RoleShortcutKind.workspace:
      break;
  }
}
