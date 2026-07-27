import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../workflows/assignment_workflow_screen.dart';
import '../workflows/attendance_viewer_screen.dart';
import '../workflows/admin_timetable_screen.dart';
import '../workflows/admin_exam_screen.dart';
import '../workflows/academic_structure_screen.dart';
import '../workflows/child_data_screen.dart';
import '../workflows/exam_workflow_screen.dart';
import '../workflows/fee_periods_screen.dart';
import '../workflows/finance_overview_screen.dart';
import '../workflows/grade_viewer_screen.dart';
import '../workflows/leave_requests_screen.dart';
import '../workflows/teacher_attendance_screen.dart';
import '../workflows/teacher_gradebook_screen.dart';
import '../workflows/teaching_assignment_screen.dart';
import '../workflows/timetable_viewer_screen.dart';
import '../workflows/users_management_screen.dart';
import 'module_hub_screen.dart';
import 'module_list_screen.dart';

Widget buildModuleScreen({
  required AppModule module,
  required Color accent,
}) {
  return Builder(
    builder: (context) {
      final role = context.read<AppSession>().user?.role;
      if (role == 'ADMIN' && module.endpoint == '/timetableSlots') {
        return AdminTimetableScreen(accent: accent);
      }
      if (role == 'ADMIN' && module.endpoint == '/users') {
        return UsersManagementScreen(accent: accent);
      }
      if (role == 'ADMIN' && module.endpoint == '/academicYears') {
        return AcademicStructureScreen(accent: accent);
      }
      if (role == 'ADMIN' && module.endpoint == '/exam-periods') {
        return AdminExamScreen(accent: accent);
      }
      if ((role == 'TEACHER' || role == 'STUDENT' || role == 'PARENT') &&
          module.endpoint == '/me/timetable') {
        return TimetableViewerScreen(
          title: module.title,
          accent: accent,
        );
      }
      if ((role == 'STUDENT' || role == 'PARENT') &&
          module.endpoint == '/grades') {
        return GradeViewerScreen(accent: accent);
      }
      if ((role == 'STUDENT' || role == 'PARENT') &&
          module.endpoint == '/attendance') {
        return AttendanceViewerScreen(accent: accent);
      }
      if (role == 'ADMIN' &&
          module.endpoint == '/teaching-assignments') {
        return TeachingAssignmentScreen(accent: accent);
      }
      if (role == 'ADMIN' && module.endpoint == '/fee-periods') {
        return FeePeriodsScreen(accent: accent);
      }
      if ((role == 'ADMIN' || role == 'TEACHER') &&
          module.endpoint == '/finance/classes') {
        return FinanceOverviewScreen(accent: accent);
      }
      if (module.endpoint == '/leave-requests') {
        return LeaveRequestsScreen(accent: accent);
      }
      if (role == 'TEACHER' && module.endpoint == '/attendance') {
        return TeacherAttendanceScreen(accent: accent);
      }
      if (role == 'TEACHER' && module.endpoint == '/grades') {
        return TeacherGradebookScreen(accent: accent);
      }
      if (role == 'TEACHER' && module.endpoint == '/me/exam-grading') {
        return TeacherExamWorkScreen(accent: accent);
      }
      if (role == 'STUDENT' && module.endpoint == '/me/exam-results') {
        return StudentExamResultsScreen(accent: accent);
      }
      if ((role == 'TEACHER' || role == 'STUDENT') &&
          (module.endpoint == '/assignments' ||
              module.endpoint == '/me/assignments' ||
              module.endpoint == '/me/submissions')) {
        return AssignmentWorkflowScreen(module: module, accent: accent);
      }
      if (role == 'PARENT' &&
          const {
            '/me/children',
            '/me/timetable',
            '/grades',
            '/attendance',
            '/me/assignments',
            '/me/exam-agenda',
            '/invoices',
          }.contains(module.endpoint)) {
        return ChildDataScreen(module: module, accent: accent);
      }
      return ModuleListScreen(module: module, accent: accent);
    },
  );
}
