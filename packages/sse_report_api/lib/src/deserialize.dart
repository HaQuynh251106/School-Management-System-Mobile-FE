import 'package:sse_report_api/src/model/api_error.dart';
import 'package:sse_report_api/src/model/attendance_summary.dart';
import 'package:sse_report_api/src/model/dashboard.dart';
import 'package:sse_report_api/src/model/dashboard_chart.dart';
import 'package:sse_report_api/src/model/dashboard_datum.dart';
import 'package:sse_report_api/src/model/dashboard_metric.dart';
import 'package:sse_report_api/src/model/dashboard_scope.dart';
import 'package:sse_report_api/src/model/dashboard_shortcut.dart';
import 'package:sse_report_api/src/model/dashboard_trend.dart';
import 'package:sse_report_api/src/model/dashboard_widget_error.dart';
import 'package:sse_report_api/src/model/finance_summary.dart';
import 'package:sse_report_api/src/model/grade_band.dart';
import 'package:sse_report_api/src/model/personal_report.dart';
import 'package:sse_report_api/src/model/report_overview.dart';
import 'package:sse_report_api/src/model/revenue_report.dart';

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
    case 'ApiError':
      return ApiError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AttendanceSummary':
      return AttendanceSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Dashboard':
      return Dashboard.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'DashboardChart':
      return DashboardChart.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardDatum':
      return DashboardDatum.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardMetric':
      return DashboardMetric.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardScope':
      return DashboardScope.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardShortcut':
      return DashboardShortcut.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardTrend':
      return DashboardTrend.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DashboardWidgetError':
      return DashboardWidgetError.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FinanceSummary':
      return FinanceSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GradeBand':
      return GradeBand.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PersonalReport':
      return PersonalReport.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportOverview':
      return ReportOverview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RevenueReport':
      return RevenueReport.fromJson(value as Map<String, dynamic>)
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
