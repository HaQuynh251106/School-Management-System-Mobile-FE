# sse_report_api.api.ReportApi

## Load the API package
```dart
import 'package:sse_report_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**exportPersonalReport**](ReportApi.md#exportpersonalreport) | **GET** /me/reports/export |
[**exportReport**](ReportApi.md#exportreport) | **GET** /reports/export |
[**getAttendanceSummary**](ReportApi.md#getattendancesummary) | **GET** /reports/attendance-summary |
[**getDashboard**](ReportApi.md#getdashboard) | **GET** /dashboard |
[**getGradeDistribution**](ReportApi.md#getgradedistribution) | **GET** /reports/grade-distribution |
[**getPersonalReport**](ReportApi.md#getpersonalreport) | **GET** /me/reports |
[**getReportOverview**](ReportApi.md#getreportoverview) | **GET** /reports/overview |
[**getRevenueReport**](ReportApi.md#getrevenuereport) | **GET** /reports/revenue |


# **exportPersonalReport**
> Uint8List exportPersonalReport(childId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String childId = childId_example; // String |

try {
    final response = api.exportPersonalReport(childId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->exportPersonalReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **childId** | **String**|  | [optional]

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportReport**
> Uint8List exportReport(type, format, semesterId, classId, subjectId, startDate, endDate, periodId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String type = type_example; // String |
final String format = format_example; // String |
final String semesterId = semesterId_example; // String |
final String classId = classId_example; // String |
final String subjectId = subjectId_example; // String |
final DateTime startDate = 2013-10-20; // DateTime |
final DateTime endDate = 2013-10-20; // DateTime |
final String periodId = periodId_example; // String |

try {
    final response = api.exportReport(type, format, semesterId, classId, subjectId, startDate, endDate, periodId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->exportReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**|  | [optional] [default to 'overview']
 **format** | **String**|  | [optional] [default to 'csv']
 **semesterId** | **String**|  | [optional]
 **classId** | **String**|  | [optional]
 **subjectId** | **String**|  | [optional]
 **startDate** | **DateTime**|  | [optional]
 **endDate** | **DateTime**|  | [optional]
 **periodId** | **String**|  | [optional]

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/pdf, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttendanceSummary**
> AttendanceSummary getAttendanceSummary(classId, startDate, endDate)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String classId = classId_example; // String |
final DateTime startDate = 2013-10-20; // DateTime |
final DateTime endDate = 2013-10-20; // DateTime |

try {
    final response = api.getAttendanceSummary(classId, startDate, endDate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getAttendanceSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  | [optional]
 **startDate** | **DateTime**|  | [optional]
 **endDate** | **DateTime**|  | [optional]

### Return type

[**AttendanceSummary**](AttendanceSummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDashboard**
> Dashboard getDashboard(childId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String childId = childId_example; // String |

try {
    final response = api.getDashboard(childId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getDashboard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **childId** | **String**|  | [optional]

### Return type

[**Dashboard**](Dashboard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGradeDistribution**
> List<GradeBand> getGradeDistribution(semesterId, classId, subjectId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String semesterId = semesterId_example; // String |
final String classId = classId_example; // String |
final String subjectId = subjectId_example; // String |

try {
    final response = api.getGradeDistribution(semesterId, classId, subjectId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getGradeDistribution: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **semesterId** | **String**|  | [optional]
 **classId** | **String**|  | [optional]
 **subjectId** | **String**|  | [optional]

### Return type

[**List&lt;GradeBand&gt;**](GradeBand.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPersonalReport**
> PersonalReport getPersonalReport(childId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String childId = childId_example; // String |

try {
    final response = api.getPersonalReport(childId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getPersonalReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **childId** | **String**|  | [optional]

### Return type

[**PersonalReport**](PersonalReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReportOverview**
> ReportOverview getReportOverview()



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();

try {
    final response = api.getReportOverview();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getReportOverview: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReportOverview**](ReportOverview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRevenueReport**
> RevenueReport getRevenueReport(periodId, classId)



### Example
```dart
import 'package:sse_report_api/api.dart';

final api = SseReportApi().getReportApi();
final String periodId = periodId_example; // String |
final String classId = classId_example; // String |

try {
    final response = api.getRevenueReport(periodId, classId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportApi->getRevenueReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **periodId** | **String**|  | [optional]
 **classId** | **String**|  | [optional]

### Return type

[**RevenueReport**](RevenueReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
