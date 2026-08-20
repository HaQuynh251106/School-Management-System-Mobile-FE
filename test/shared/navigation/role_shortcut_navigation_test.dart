import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/navigation/role_shortcut_navigation.dart';

void main() {
  test('teacher shortcuts map to teacher main tabs', () {
    expect(
      resolveRoleShortcut(role: 'TEACHER', target: 'timetable').tabIndex,
      0,
    );
    expect(
      resolveRoleShortcut(role: 'TEACHER', target: 'attendance').tabIndex,
      1,
    );
    expect(
      resolveRoleShortcut(role: 'TEACHER', target: 'assignments').tabIndex,
      3,
    );
  });

  test('student shortcuts map to timetable assignments and attendance', () {
    expect(
      resolveRoleShortcut(role: 'STUDENT', target: 'timetable').tabIndex,
      0,
    );
    expect(
      resolveRoleShortcut(role: 'STUDENT', target: 'assignments').tabIndex,
      1,
    );
    expect(
      resolveRoleShortcut(role: 'STUDENT', target: 'attendance').tabIndex,
      3,
    );
  });

  test('parent finance and attendance shortcuts map to real tabs', () {
    expect(
      resolveRoleShortcut(role: 'PARENT', target: 'attendance').tabIndex,
      2,
    );
    expect(resolveRoleShortcut(role: 'PARENT', target: 'finance').tabIndex, 3);
  });

  test('notifications open inbox while exams stay in workspace', () {
    expect(
      resolveRoleShortcut(role: 'STUDENT', target: 'notifications').kind,
      RoleShortcutKind.notifications,
    );
    expect(
      resolveRoleShortcut(role: 'PARENT', target: 'exams').kind,
      RoleShortcutKind.workspace,
    );
  });
}
