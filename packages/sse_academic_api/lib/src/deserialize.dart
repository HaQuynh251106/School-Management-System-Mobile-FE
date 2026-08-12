import 'package:sse_academic_api/src/model/academic_year.dart';
import 'package:sse_academic_api/src/model/allocate_exam_candidates_request.dart';
import 'package:sse_academic_api/src/model/api_error.dart';
import 'package:sse_academic_api/src/model/approved_leave.dart';
import 'package:sse_academic_api/src/model/attendance_day_status.dart';
import 'package:sse_academic_api/src/model/attendance_mark.dart';
import 'package:sse_academic_api/src/model/attendance_record.dart';
import 'package:sse_academic_api/src/model/attendance_session_status.dart';
import 'package:sse_academic_api/src/model/bulk_attendance_request.dart';
import 'package:sse_academic_api/src/model/bulk_grade_request.dart';
import 'package:sse_academic_api/src/model/conduct_request.dart';
import 'package:sse_academic_api/src/model/create_class_request.dart';
import 'package:sse_academic_api/src/model/create_exam_review_request.dart';
import 'package:sse_academic_api/src/model/create_grade_request.dart';
import 'package:sse_academic_api/src/model/create_room_request.dart';
import 'package:sse_academic_api/src/model/create_subject_request.dart';
import 'package:sse_academic_api/src/model/eligible_exam_grader.dart';
import 'package:sse_academic_api/src/model/exam_agenda_item.dart';
import 'package:sse_academic_api/src/model/exam_candidate.dart';
import 'package:sse_academic_api/src/model/exam_category.dart';
import 'package:sse_academic_api/src/model/exam_grading_assignment.dart';
import 'package:sse_academic_api/src/model/exam_period.dart';
import 'package:sse_academic_api/src/model/exam_period_summary.dart';
import 'package:sse_academic_api/src/model/exam_result.dart';
import 'package:sse_academic_api/src/model/exam_result_entry.dart';
import 'package:sse_academic_api/src/model/exam_review.dart';
import 'package:sse_academic_api/src/model/exam_room.dart';
import 'package:sse_academic_api/src/model/exam_schedule.dart';
import 'package:sse_academic_api/src/model/exam_score_adjustment.dart';
import 'package:sse_academic_api/src/model/grade.dart';
import 'package:sse_academic_api/src/model/grade_change_log.dart';
import 'package:sse_academic_api/src/model/grade_entry.dart';
import 'package:sse_academic_api/src/model/gradebook_subject.dart';
import 'package:sse_academic_api/src/model/resolve_exam_review_request.dart';
import 'package:sse_academic_api/src/model/room.dart';
import 'package:sse_academic_api/src/model/save_exam_category_request.dart';
import 'package:sse_academic_api/src/model/save_exam_grader_request.dart';
import 'package:sse_academic_api/src/model/save_exam_period_request.dart';
import 'package:sse_academic_api/src/model/save_exam_results_request.dart';
import 'package:sse_academic_api/src/model/save_exam_room_request.dart';
import 'package:sse_academic_api/src/model/save_exam_schedule_request.dart';
import 'package:sse_academic_api/src/model/save_teaching_assignment_request.dart';
import 'package:sse_academic_api/src/model/save_timetable_slot_request.dart';
import 'package:sse_academic_api/src/model/school_class.dart';
import 'package:sse_academic_api/src/model/semester.dart';
import 'package:sse_academic_api/src/model/student_exam_result.dart';
import 'package:sse_academic_api/src/model/student_yearly_summary.dart';
import 'package:sse_academic_api/src/model/subject.dart';
import 'package:sse_academic_api/src/model/teacher_exam_candidate.dart';
import 'package:sse_academic_api/src/model/teacher_gradebook_context.dart';
import 'package:sse_academic_api/src/model/teacher_grading_task.dart';
import 'package:sse_academic_api/src/model/teaching_assignment.dart';
import 'package:sse_academic_api/src/model/timetable_slot.dart';
import 'package:sse_academic_api/src/model/unlock_attendance_request.dart';
import 'package:sse_academic_api/src/model/update_grade_request.dart';
import 'package:sse_academic_api/src/model/year_rollover_class_plan.dart';
import 'package:sse_academic_api/src/model/year_rollover_preview.dart';
import 'package:sse_academic_api/src/model/year_rollover_request.dart';
import 'package:sse_academic_api/src/model/year_rollover_result.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AcademicYear':
      return AcademicYear.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AllocateExamCandidatesRequest':
      return AllocateExamCandidatesRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiError':
      return ApiError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ApprovedLeave':
      return ApprovedLeave.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttendanceDayStatus':
      return AttendanceDayStatus.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttendanceMark':
      return AttendanceMark.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttendanceRecord':
      return AttendanceRecord.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttendanceSessionStatus':
      return AttendanceSessionStatus.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttendanceStatus':
    case 'BulkAttendanceRequest':
      return BulkAttendanceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'BulkGradeRequest':
      return BulkGradeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ConductRequest':
      return ConductRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateClassRequest':
      return CreateClassRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateExamReviewRequest':
      return CreateExamReviewRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateGradeRequest':
      return CreateGradeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateRoomRequest':
      return CreateRoomRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateSubjectRequest':
      return CreateSubjectRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EligibleExamGrader':
      return EligibleExamGrader.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamAgendaItem':
      return ExamAgendaItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamCandidate':
      return ExamCandidate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamCategory':
      return ExamCategory.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamGradingAssignment':
      return ExamGradingAssignment.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamPeriod':
      return ExamPeriod.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamPeriodSummary':
      return ExamPeriodSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamResult':
      return ExamResult.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamResultEntry':
      return ExamResultEntry.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExamReview':
      return ExamReview.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamRoom':
      return ExamRoom.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamSchedule':
      return ExamSchedule.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExamScoreAdjustment':
      return ExamScoreAdjustment.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Grade':
      return Grade.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GradeChangeLog':
      return GradeChangeLog.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GradeEntry':
      return GradeEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GradebookSubject':
      return GradebookSubject.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResolveExamReviewRequest':
      return ResolveExamReviewRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Room':
      return Room.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SaveExamCategoryRequest':
      return SaveExamCategoryRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveExamGraderRequest':
      return SaveExamGraderRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveExamPeriodRequest':
      return SaveExamPeriodRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveExamResultsRequest':
      return SaveExamResultsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveExamRoomRequest':
      return SaveExamRoomRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveExamScheduleRequest':
      return SaveExamScheduleRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SaveTeachingAssignmentRequest':
      return SaveTeachingAssignmentRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SaveTimetableSlotRequest':
      return SaveTimetableSlotRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SchoolClass':
      return SchoolClass.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Semester':
      return Semester.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'StudentExamResult':
      return StudentExamResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StudentYearlySummary':
      return StudentYearlySummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Subject':
      return Subject.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'TeacherExamCandidate':
      return TeacherExamCandidate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TeacherGradebookContext':
      return TeacherGradebookContext.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TeacherGradingTask':
      return TeacherGradingTask.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TeachingAssignment':
      return TeachingAssignment.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TimetableSlot':
      return TimetableSlot.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UnlockAttendanceRequest':
      return UnlockAttendanceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateGradeRequest':
      return UpdateGradeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'YearRolloverClassPlan':
      return YearRolloverClassPlan.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'YearRolloverPreview':
      return YearRolloverPreview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'YearRolloverRequest':
      return YearRolloverRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'YearRolloverResult':
      return YearRolloverResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
