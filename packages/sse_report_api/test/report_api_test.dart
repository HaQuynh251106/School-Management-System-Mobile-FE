import 'package:test/test.dart';
import 'package:sse_report_api/sse_report_api.dart';


/// tests for ReportApi
void main() {
  final instance = SseReportApi().getReportApi();

  group(ReportApi, () {
    //Future<Uint8List> exportPersonalReport({ String childId }) async
    test('test exportPersonalReport', () async {
      // TODO
    });

    //Future<Uint8List> exportReport({ String type, String format, String semesterId, String classId, String subjectId, DateTime startDate, DateTime endDate, String periodId }) async
    test('test exportReport', () async {
      // TODO
    });

    //Future<AttendanceSummary> getAttendanceSummary({ String classId, DateTime startDate, DateTime endDate }) async
    test('test getAttendanceSummary', () async {
      // TODO
    });

    //Future<Dashboard> getDashboard({ String childId }) async
    test('test getDashboard', () async {
      // TODO
    });

    //Future<List<GradeBand>> getGradeDistribution({ String semesterId, String classId, String subjectId }) async
    test('test getGradeDistribution', () async {
      // TODO
    });

    //Future<PersonalReport> getPersonalReport({ String childId }) async
    test('test getPersonalReport', () async {
      // TODO
    });

    //Future<ReportOverview> getReportOverview() async
    test('test getReportOverview', () async {
      // TODO
    });

    //Future<RevenueReport> getRevenueReport({ String periodId, String classId }) async
    test('test getRevenueReport', () async {
      // TODO
    });

  });
}
