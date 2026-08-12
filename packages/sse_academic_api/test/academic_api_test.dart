import 'package:test/test.dart';
import 'package:sse_academic_api/sse_academic_api.dart';


/// tests for AcademicApi
void main() {
  final instance = SseAcademicApi().getAcademicApi();

  group(AcademicApi, () {
    //Future<List<ExamCandidate>> allocateExamCandidates(String id, AllocateExamCandidatesRequest allocateExamCandidatesRequest) async
    test('test allocateExamCandidates', () async {
      // TODO
    });

    //Future<List<AttendanceRecord>> bulkMarkAttendance(BulkAttendanceRequest bulkAttendanceRequest) async
    test('test bulkMarkAttendance', () async {
      // TODO
    });

    //Future<List<Grade>> bulkUpsertGrades(BulkGradeRequest bulkGradeRequest) async
    test('test bulkUpsertGrades', () async {
      // TODO
    });

    //Future<ExamPeriod> confirmExamPeriod(String id) async
    test('test confirmExamPeriod', () async {
      // TODO
    });

    //Future<SchoolClass> createClass(CreateClassRequest createClassRequest) async
    test('test createClass', () async {
      // TODO
    });

    //Future<ExamCategory> createExamCategory(SaveExamCategoryRequest saveExamCategoryRequest) async
    test('test createExamCategory', () async {
      // TODO
    });

    //Future<ExamPeriod> createExamPeriod(SaveExamPeriodRequest saveExamPeriodRequest) async
    test('test createExamPeriod', () async {
      // TODO
    });

    //Future<ExamRoom> createExamRoom(String id, SaveExamRoomRequest saveExamRoomRequest) async
    test('test createExamRoom', () async {
      // TODO
    });

    //Future<ExamSchedule> createExamSchedule(String id, SaveExamScheduleRequest saveExamScheduleRequest) async
    test('test createExamSchedule', () async {
      // TODO
    });

    //Future<Grade> createGrade(CreateGradeRequest createGradeRequest) async
    test('test createGrade', () async {
      // TODO
    });

    //Future<Room> createRoom(CreateRoomRequest createRoomRequest) async
    test('test createRoom', () async {
      // TODO
    });

    //Future<Subject> createSubject(CreateSubjectRequest createSubjectRequest) async
    test('test createSubject', () async {
      // TODO
    });

    //Future<TeachingAssignment> createTeachingAssignment(SaveTeachingAssignmentRequest saveTeachingAssignmentRequest) async
    test('test createTeachingAssignment', () async {
      // TODO
    });

    //Future<TimetableSlot> createTimetableSlot(SaveTimetableSlotRequest saveTimetableSlotRequest) async
    test('test createTimetableSlot', () async {
      // TODO
    });

    //Future deleteExamCategory(String id) async
    test('test deleteExamCategory', () async {
      // TODO
    });

    //Future deleteExamPeriod(String id) async
    test('test deleteExamPeriod', () async {
      // TODO
    });

    //Future deleteExamRoom(String id) async
    test('test deleteExamRoom', () async {
      // TODO
    });

    //Future deleteExamSchedule(String id) async
    test('test deleteExamSchedule', () async {
      // TODO
    });

    //Future<List<StudentYearlySummary>> finalizeAcademicYear(String id) async
    test('test finalizeAcademicYear', () async {
      // TODO
    });

    //Future<AttendanceDayStatus> getAttendanceDayStatus(DateTime date) async
    test('test getAttendanceDayStatus', () async {
      // TODO
    });

    //Future<AttendanceSessionStatus> getAttendanceSessionStatus(String slotId, DateTime date) async
    test('test getAttendanceSessionStatus', () async {
      // TODO
    });

    //Future<StudentYearlySummary> getChildYearlySummary(String id, String studentId) async
    test('test getChildYearlySummary', () async {
      // TODO
    });

    //Future<List<StudentYearlySummary>> getHomeroomYearlySummaries(String id) async
    test('test getHomeroomYearlySummaries', () async {
      // TODO
    });

    //Future<List<ExamAgendaItem>> getMyExamAgenda({ String childId }) async
    test('test getMyExamAgenda', () async {
      // TODO
    });

    //Future<List<TeacherGradingTask>> getMyExamGradingTasks() async
    test('test getMyExamGradingTasks', () async {
      // TODO
    });

    //Future<List<StudentExamResult>> getMyExamResults() async
    test('test getMyExamResults', () async {
      // TODO
    });

    //Future<List<ExamReview>> getMyExamReviews({ String status }) async
    test('test getMyExamReviews', () async {
      // TODO
    });

    //Future<List<TimetableSlot>> getMyTimetable() async
    test('test getMyTimetable', () async {
      // TODO
    });

    //Future<StudentYearlySummary> getMyYearlySummary(String id) async
    test('test getMyYearlySummary', () async {
      // TODO
    });

    //Future<List<StudentYearlySummary>> getPromotionPreview(String id) async
    test('test getPromotionPreview', () async {
      // TODO
    });

    //Future<TeacherGradebookContext> getTeacherGradebookContext(String classId, String semesterId) async
    test('test getTeacherGradebookContext', () async {
      // TODO
    });

    //Future<YearRolloverPreview> getYearRolloverPreview(String id) async
    test('test getYearRolloverPreview', () async {
      // TODO
    });

    //Future<List<AcademicYear>> listAcademicYears() async
    test('test listAcademicYears', () async {
      // TODO
    });

    //Future<List<ApprovedLeave>> listApprovedLeavesForAttendance(String slotId, DateTime date) async
    test('test listApprovedLeavesForAttendance', () async {
      // TODO
    });

    //Future<List<AttendanceRecord>> listAttendance({ String studentId, String classId, String slotId, DateTime date }) async
    test('test listAttendance', () async {
      // TODO
    });

    //Future<List<SchoolClass>> listClasses({ String academicYearId, String gradeLevel }) async
    test('test listClasses', () async {
      // TODO
    });

    //Future<List<EligibleExamGrader>> listEligibleExamGraders(String id) async
    test('test listEligibleExamGraders', () async {
      // TODO
    });

    //Future<List<ExamCategory>> listExamCategories() async
    test('test listExamCategories', () async {
      // TODO
    });

    //Future<List<ExamGradingAssignment>> listExamGraders(String id) async
    test('test listExamGraders', () async {
      // TODO
    });

    //Future<List<ExamPeriodSummary>> listExamPeriods({ String academicYearId, String semesterId }) async
    test('test listExamPeriods', () async {
      // TODO
    });

    //Future<List<ExamResult>> listExamResults(String id, { String scheduleId, String studentId }) async
    test('test listExamResults', () async {
      // TODO
    });

    //Future<List<ExamReview>> listExamReviews(String id, { String status }) async
    test('test listExamReviews', () async {
      // TODO
    });

    //Future<List<ExamRoom>> listExamRooms(String id) async
    test('test listExamRooms', () async {
      // TODO
    });

    //Future<List<ExamSchedule>> listExamSchedules(String id) async
    test('test listExamSchedules', () async {
      // TODO
    });

    //Future<List<ExamScoreAdjustment>> listExamScoreAdjustments(String id) async
    test('test listExamScoreAdjustments', () async {
      // TODO
    });

    //Future<List<GradeChangeLog>> listGradeChangeLogs(String id) async
    test('test listGradeChangeLogs', () async {
      // TODO
    });

    //Future<List<Grade>> listGrades({ String studentId, String subjectId, String semesterId, String category, String classId }) async
    test('test listGrades', () async {
      // TODO
    });

    //Future<List<Room>> listRooms() async
    test('test listRooms', () async {
      // TODO
    });

    //Future<List<Semester>> listSemesters({ String academicYearId }) async
    test('test listSemesters', () async {
      // TODO
    });

    //Future<List<Subject>> listSubjects() async
    test('test listSubjects', () async {
      // TODO
    });

    //Future<List<TeachingAssignment>> listTeachingAssignments({ String classId, String subjectId, String teacherId, String semesterId, String dayOfWeek, int periodNo }) async
    test('test listTeachingAssignments', () async {
      // TODO
    });

    //Future<List<TimetableSlot>> listTimetableSlots({ String classId, String teacherId, String semesterId, String dayOfWeek }) async
    test('test listTimetableSlots', () async {
      // TODO
    });

    //Future<ExamPeriod> lockExamScores(String id) async
    test('test lockExamScores', () async {
      // TODO
    });

    //Future<ExamPeriod> publishExamSchedule(String id) async
    test('test publishExamSchedule', () async {
      // TODO
    });

    //Future<ExamReview> requestExamReview(String id, CreateExamReviewRequest createExamReviewRequest) async
    test('test requestExamReview', () async {
      // TODO
    });

    //Future<ExamReview> resolveExamReview(String id, ResolveExamReviewRequest resolveExamReviewRequest) async
    test('test resolveExamReview', () async {
      // TODO
    });

    //Future<YearRolloverResult> rolloverAcademicYear(String id, YearRolloverRequest yearRolloverRequest) async
    test('test rolloverAcademicYear', () async {
      // TODO
    });

    //Future<ExamGradingAssignment> saveExamGrader(String id, SaveExamGraderRequest saveExamGraderRequest) async
    test('test saveExamGrader', () async {
      // TODO
    });

    //Future<List<ExamResult>> saveExamResults(String id, SaveExamResultsRequest saveExamResultsRequest) async
    test('test saveExamResults', () async {
      // TODO
    });

    //Future<StudentYearlySummary> setStudentConduct(String id, String studentId, ConductRequest conductRequest) async
    test('test setStudentConduct', () async {
      // TODO
    });

    //Future<ExamPeriod> unlockExamScores(String id) async
    test('test unlockExamScores', () async {
      // TODO
    });

    //Future<AttendanceSessionStatus> unlockLateAttendance(UnlockAttendanceRequest unlockAttendanceRequest) async
    test('test unlockLateAttendance', () async {
      // TODO
    });

    //Future<ExamCategory> updateExamCategory(String id, SaveExamCategoryRequest saveExamCategoryRequest) async
    test('test updateExamCategory', () async {
      // TODO
    });

    //Future<ExamPeriod> updateExamPeriod(String id, SaveExamPeriodRequest saveExamPeriodRequest) async
    test('test updateExamPeriod', () async {
      // TODO
    });

    //Future<ExamSchedule> updateExamSchedule(String id, SaveExamScheduleRequest saveExamScheduleRequest) async
    test('test updateExamSchedule', () async {
      // TODO
    });

    //Future<Grade> updateGrade(String id, UpdateGradeRequest updateGradeRequest) async
    test('test updateGrade', () async {
      // TODO
    });

  });
}
