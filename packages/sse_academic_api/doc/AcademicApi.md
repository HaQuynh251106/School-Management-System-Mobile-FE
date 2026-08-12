# sse_academic_api.api.AcademicApi

## Load the API package
```dart
import 'package:sse_academic_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**allocateExamCandidates**](AcademicApi.md#allocateexamcandidates) | **POST** /exam-rooms/{id}/allocate |
[**bulkMarkAttendance**](AcademicApi.md#bulkmarkattendance) | **POST** /attendance/bulk |
[**bulkUpsertGrades**](AcademicApi.md#bulkupsertgrades) | **POST** /grades/bulk |
[**confirmExamPeriod**](AcademicApi.md#confirmexamperiod) | **POST** /exam-periods/{id}/confirm |
[**createClass**](AcademicApi.md#createclass) | **POST** /classes |
[**createExamCategory**](AcademicApi.md#createexamcategory) | **POST** /exam-categories |
[**createExamPeriod**](AcademicApi.md#createexamperiod) | **POST** /exam-periods |
[**createExamRoom**](AcademicApi.md#createexamroom) | **POST** /exam-schedules/{id}/rooms |
[**createExamSchedule**](AcademicApi.md#createexamschedule) | **POST** /exam-periods/{id}/schedules |
[**createGrade**](AcademicApi.md#creategrade) | **POST** /grades |
[**createRoom**](AcademicApi.md#createroom) | **POST** /rooms |
[**createSubject**](AcademicApi.md#createsubject) | **POST** /subjects |
[**createTeachingAssignment**](AcademicApi.md#createteachingassignment) | **POST** /teaching-assignments |
[**createTimetableSlot**](AcademicApi.md#createtimetableslot) | **POST** /timetableSlots |
[**deleteExamCategory**](AcademicApi.md#deleteexamcategory) | **DELETE** /exam-categories/{id} |
[**deleteExamPeriod**](AcademicApi.md#deleteexamperiod) | **DELETE** /exam-periods/{id} |
[**deleteExamRoom**](AcademicApi.md#deleteexamroom) | **DELETE** /exam-rooms/{id} |
[**deleteExamSchedule**](AcademicApi.md#deleteexamschedule) | **DELETE** /exam-schedules/{id} |
[**finalizeAcademicYear**](AcademicApi.md#finalizeacademicyear) | **POST** /academic-years/{id}/finalize |
[**getAttendanceDayStatus**](AcademicApi.md#getattendancedaystatus) | **GET** /attendance/day-status |
[**getAttendanceSessionStatus**](AcademicApi.md#getattendancesessionstatus) | **GET** /attendance/session-status |
[**getChildYearlySummary**](AcademicApi.md#getchildyearlysummary) | **GET** /academic-years/{id}/children/{studentId}/summary |
[**getHomeroomYearlySummaries**](AcademicApi.md#gethomeroomyearlysummaries) | **GET** /academic-years/{id}/homeroom-summaries |
[**getMyExamAgenda**](AcademicApi.md#getmyexamagenda) | **GET** /me/exam-agenda |
[**getMyExamGradingTasks**](AcademicApi.md#getmyexamgradingtasks) | **GET** /me/exam-grading |
[**getMyExamResults**](AcademicApi.md#getmyexamresults) | **GET** /me/exam-results |
[**getMyExamReviews**](AcademicApi.md#getmyexamreviews) | **GET** /me/exam-reviews |
[**getMyTimetable**](AcademicApi.md#getmytimetable) | **GET** /me/timetable |
[**getMyYearlySummary**](AcademicApi.md#getmyyearlysummary) | **GET** /academic-years/{id}/my-summary |
[**getPromotionPreview**](AcademicApi.md#getpromotionpreview) | **GET** /academic-years/{id}/promotion-preview |
[**getTeacherGradebookContext**](AcademicApi.md#getteachergradebookcontext) | **GET** /me/gradebook-context |
[**getYearRolloverPreview**](AcademicApi.md#getyearrolloverpreview) | **GET** /academic-years/{id}/rollover-preview |
[**listAcademicYears**](AcademicApi.md#listacademicyears) | **GET** /academicYears |
[**listApprovedLeavesForAttendance**](AcademicApi.md#listapprovedleavesforattendance) | **GET** /attendance/approved-leaves |
[**listAttendance**](AcademicApi.md#listattendance) | **GET** /attendance |
[**listClasses**](AcademicApi.md#listclasses) | **GET** /classes |
[**listEligibleExamGraders**](AcademicApi.md#listeligibleexamgraders) | **GET** /exam-schedules/{id}/eligible-graders |
[**listExamCategories**](AcademicApi.md#listexamcategories) | **GET** /exam-categories |
[**listExamGraders**](AcademicApi.md#listexamgraders) | **GET** /exam-schedules/{id}/graders |
[**listExamPeriods**](AcademicApi.md#listexamperiods) | **GET** /exam-periods |
[**listExamResults**](AcademicApi.md#listexamresults) | **GET** /exam-periods/{id}/results |
[**listExamReviews**](AcademicApi.md#listexamreviews) | **GET** /exam-periods/{id}/reviews |
[**listExamRooms**](AcademicApi.md#listexamrooms) | **GET** /exam-schedules/{id}/rooms |
[**listExamSchedules**](AcademicApi.md#listexamschedules) | **GET** /exam-periods/{id}/schedules |
[**listExamScoreAdjustments**](AcademicApi.md#listexamscoreadjustments) | **GET** /exam-periods/{id}/adjustments |
[**listGradeChangeLogs**](AcademicApi.md#listgradechangelogs) | **GET** /grades/{id}/change-logs |
[**listGrades**](AcademicApi.md#listgrades) | **GET** /grades |
[**listRooms**](AcademicApi.md#listrooms) | **GET** /rooms |
[**listSemesters**](AcademicApi.md#listsemesters) | **GET** /semesters |
[**listSubjects**](AcademicApi.md#listsubjects) | **GET** /subjects |
[**listTeachingAssignments**](AcademicApi.md#listteachingassignments) | **GET** /teaching-assignments |
[**listTimetableSlots**](AcademicApi.md#listtimetableslots) | **GET** /timetableSlots |
[**lockExamScores**](AcademicApi.md#lockexamscores) | **POST** /exam-periods/{id}/lock-scores |
[**publishExamSchedule**](AcademicApi.md#publishexamschedule) | **POST** /exam-periods/{id}/publish-schedule |
[**requestExamReview**](AcademicApi.md#requestexamreview) | **POST** /exam-periods/{id}/reviews |
[**resolveExamReview**](AcademicApi.md#resolveexamreview) | **PUT** /exam-reviews/{id}/resolve |
[**rolloverAcademicYear**](AcademicApi.md#rolloveracademicyear) | **POST** /academic-years/{id}/rollover |
[**saveExamGrader**](AcademicApi.md#saveexamgrader) | **PUT** /exam-schedules/{id}/graders |
[**saveExamResults**](AcademicApi.md#saveexamresults) | **PUT** /exam-periods/{id}/results |
[**setStudentConduct**](AcademicApi.md#setstudentconduct) | **PUT** /academic-years/{id}/students/{studentId}/conduct |
[**unlockExamScores**](AcademicApi.md#unlockexamscores) | **POST** /exam-periods/{id}/unlock-scores |
[**unlockLateAttendance**](AcademicApi.md#unlocklateattendance) | **POST** /attendance/unlock |
[**updateExamCategory**](AcademicApi.md#updateexamcategory) | **PUT** /exam-categories/{id} |
[**updateExamPeriod**](AcademicApi.md#updateexamperiod) | **PUT** /exam-periods/{id} |
[**updateExamSchedule**](AcademicApi.md#updateexamschedule) | **PUT** /exam-schedules/{id} |
[**updateGrade**](AcademicApi.md#updategrade) | **PUT** /grades/{id} |


# **allocateExamCandidates**
> List<ExamCandidate> allocateExamCandidates(id, allocateExamCandidatesRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final AllocateExamCandidatesRequest allocateExamCandidatesRequest = ; // AllocateExamCandidatesRequest |

try {
    final response = api.allocateExamCandidates(id, allocateExamCandidatesRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->allocateExamCandidates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **allocateExamCandidatesRequest** | [**AllocateExamCandidatesRequest**](AllocateExamCandidatesRequest.md)|  |

### Return type

[**List&lt;ExamCandidate&gt;**](ExamCandidate.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bulkMarkAttendance**
> List<AttendanceRecord> bulkMarkAttendance(bulkAttendanceRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final BulkAttendanceRequest bulkAttendanceRequest = ; // BulkAttendanceRequest |

try {
    final response = api.bulkMarkAttendance(bulkAttendanceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->bulkMarkAttendance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bulkAttendanceRequest** | [**BulkAttendanceRequest**](BulkAttendanceRequest.md)|  |

### Return type

[**List&lt;AttendanceRecord&gt;**](AttendanceRecord.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bulkUpsertGrades**
> List<Grade> bulkUpsertGrades(bulkGradeRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final BulkGradeRequest bulkGradeRequest = ; // BulkGradeRequest |

try {
    final response = api.bulkUpsertGrades(bulkGradeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->bulkUpsertGrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bulkGradeRequest** | [**BulkGradeRequest**](BulkGradeRequest.md)|  |

### Return type

[**List&lt;Grade&gt;**](Grade.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmExamPeriod**
> ExamPeriod confirmExamPeriod(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.confirmExamPeriod(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->confirmExamPeriod: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createClass**
> SchoolClass createClass(createClassRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final CreateClassRequest createClassRequest = ; // CreateClassRequest |

try {
    final response = api.createClass(createClassRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createClass: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createClassRequest** | [**CreateClassRequest**](CreateClassRequest.md)|  |

### Return type

[**SchoolClass**](SchoolClass.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExamCategory**
> ExamCategory createExamCategory(saveExamCategoryRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final SaveExamCategoryRequest saveExamCategoryRequest = ; // SaveExamCategoryRequest |

try {
    final response = api.createExamCategory(saveExamCategoryRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createExamCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **saveExamCategoryRequest** | [**SaveExamCategoryRequest**](SaveExamCategoryRequest.md)|  |

### Return type

[**ExamCategory**](ExamCategory.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExamPeriod**
> ExamPeriod createExamPeriod(saveExamPeriodRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final SaveExamPeriodRequest saveExamPeriodRequest = ; // SaveExamPeriodRequest |

try {
    final response = api.createExamPeriod(saveExamPeriodRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createExamPeriod: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **saveExamPeriodRequest** | [**SaveExamPeriodRequest**](SaveExamPeriodRequest.md)|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExamRoom**
> ExamRoom createExamRoom(id, saveExamRoomRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamRoomRequest saveExamRoomRequest = ; // SaveExamRoomRequest |

try {
    final response = api.createExamRoom(id, saveExamRoomRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createExamRoom: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamRoomRequest** | [**SaveExamRoomRequest**](SaveExamRoomRequest.md)|  |

### Return type

[**ExamRoom**](ExamRoom.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExamSchedule**
> ExamSchedule createExamSchedule(id, saveExamScheduleRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamScheduleRequest saveExamScheduleRequest = ; // SaveExamScheduleRequest |

try {
    final response = api.createExamSchedule(id, saveExamScheduleRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createExamSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamScheduleRequest** | [**SaveExamScheduleRequest**](SaveExamScheduleRequest.md)|  |

### Return type

[**ExamSchedule**](ExamSchedule.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createGrade**
> Grade createGrade(createGradeRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final CreateGradeRequest createGradeRequest = ; // CreateGradeRequest |

try {
    final response = api.createGrade(createGradeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createGrade: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createGradeRequest** | [**CreateGradeRequest**](CreateGradeRequest.md)|  |

### Return type

[**Grade**](Grade.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRoom**
> Room createRoom(createRoomRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final CreateRoomRequest createRoomRequest = ; // CreateRoomRequest |

try {
    final response = api.createRoom(createRoomRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createRoom: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRoomRequest** | [**CreateRoomRequest**](CreateRoomRequest.md)|  |

### Return type

[**Room**](Room.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSubject**
> Subject createSubject(createSubjectRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final CreateSubjectRequest createSubjectRequest = ; // CreateSubjectRequest |

try {
    final response = api.createSubject(createSubjectRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createSubject: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSubjectRequest** | [**CreateSubjectRequest**](CreateSubjectRequest.md)|  |

### Return type

[**Subject**](Subject.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTeachingAssignment**
> TeachingAssignment createTeachingAssignment(saveTeachingAssignmentRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final SaveTeachingAssignmentRequest saveTeachingAssignmentRequest = ; // SaveTeachingAssignmentRequest |

try {
    final response = api.createTeachingAssignment(saveTeachingAssignmentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createTeachingAssignment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **saveTeachingAssignmentRequest** | [**SaveTeachingAssignmentRequest**](SaveTeachingAssignmentRequest.md)|  |

### Return type

[**TeachingAssignment**](TeachingAssignment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTimetableSlot**
> TimetableSlot createTimetableSlot(saveTimetableSlotRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final SaveTimetableSlotRequest saveTimetableSlotRequest = ; // SaveTimetableSlotRequest |

try {
    final response = api.createTimetableSlot(saveTimetableSlotRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->createTimetableSlot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **saveTimetableSlotRequest** | [**SaveTimetableSlotRequest**](SaveTimetableSlotRequest.md)|  |

### Return type

[**TimetableSlot**](TimetableSlot.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExamCategory**
> deleteExamCategory(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    api.deleteExamCategory(id);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->deleteExamCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExamPeriod**
> deleteExamPeriod(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    api.deleteExamPeriod(id);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->deleteExamPeriod: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExamRoom**
> deleteExamRoom(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    api.deleteExamRoom(id);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->deleteExamRoom: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExamSchedule**
> deleteExamSchedule(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    api.deleteExamSchedule(id);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->deleteExamSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **finalizeAcademicYear**
> List<StudentYearlySummary> finalizeAcademicYear(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.finalizeAcademicYear(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->finalizeAcademicYear: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;StudentYearlySummary&gt;**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttendanceDayStatus**
> AttendanceDayStatus getAttendanceDayStatus(date)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.getAttendanceDayStatus(date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getAttendanceDayStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **DateTime**|  |

### Return type

[**AttendanceDayStatus**](AttendanceDayStatus.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttendanceSessionStatus**
> AttendanceSessionStatus getAttendanceSessionStatus(slotId, date)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String slotId = slotId_example; // String |
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.getAttendanceSessionStatus(slotId, date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getAttendanceSessionStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slotId** | **String**|  |
 **date** | **DateTime**|  |

### Return type

[**AttendanceSessionStatus**](AttendanceSessionStatus.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChildYearlySummary**
> StudentYearlySummary getChildYearlySummary(id, studentId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final String studentId = studentId_example; // String |

try {
    final response = api.getChildYearlySummary(id, studentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getChildYearlySummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **studentId** | **String**|  |

### Return type

[**StudentYearlySummary**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHomeroomYearlySummaries**
> List<StudentYearlySummary> getHomeroomYearlySummaries(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.getHomeroomYearlySummaries(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getHomeroomYearlySummaries: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;StudentYearlySummary&gt;**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyExamAgenda**
> List<ExamAgendaItem> getMyExamAgenda(childId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String childId = childId_example; // String |

try {
    final response = api.getMyExamAgenda(childId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyExamAgenda: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **childId** | **String**|  | [optional]

### Return type

[**List&lt;ExamAgendaItem&gt;**](ExamAgendaItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyExamGradingTasks**
> List<TeacherGradingTask> getMyExamGradingTasks()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.getMyExamGradingTasks();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyExamGradingTasks: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;TeacherGradingTask&gt;**](TeacherGradingTask.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyExamResults**
> List<StudentExamResult> getMyExamResults()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.getMyExamResults();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyExamResults: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;StudentExamResult&gt;**](StudentExamResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyExamReviews**
> List<ExamReview> getMyExamReviews(status)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String status = status_example; // String |

try {
    final response = api.getMyExamReviews(status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyExamReviews: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | **String**|  | [optional]

### Return type

[**List&lt;ExamReview&gt;**](ExamReview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyTimetable**
> List<TimetableSlot> getMyTimetable()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.getMyTimetable();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyTimetable: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;TimetableSlot&gt;**](TimetableSlot.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyYearlySummary**
> StudentYearlySummary getMyYearlySummary(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.getMyYearlySummary(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getMyYearlySummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**StudentYearlySummary**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPromotionPreview**
> List<StudentYearlySummary> getPromotionPreview(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.getPromotionPreview(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getPromotionPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;StudentYearlySummary&gt;**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeacherGradebookContext**
> TeacherGradebookContext getTeacherGradebookContext(classId, semesterId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String classId = classId_example; // String |
final String semesterId = semesterId_example; // String |

try {
    final response = api.getTeacherGradebookContext(classId, semesterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getTeacherGradebookContext: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  |
 **semesterId** | **String**|  |

### Return type

[**TeacherGradebookContext**](TeacherGradebookContext.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getYearRolloverPreview**
> YearRolloverPreview getYearRolloverPreview(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.getYearRolloverPreview(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->getYearRolloverPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**YearRolloverPreview**](YearRolloverPreview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAcademicYears**
> List<AcademicYear> listAcademicYears()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.listAcademicYears();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listAcademicYears: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;AcademicYear&gt;**](AcademicYear.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listApprovedLeavesForAttendance**
> List<ApprovedLeave> listApprovedLeavesForAttendance(slotId, date)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String slotId = slotId_example; // String |
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.listApprovedLeavesForAttendance(slotId, date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listApprovedLeavesForAttendance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slotId** | **String**|  |
 **date** | **DateTime**|  |

### Return type

[**List&lt;ApprovedLeave&gt;**](ApprovedLeave.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAttendance**
> List<AttendanceRecord> listAttendance(studentId, classId, slotId, date)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String studentId = studentId_example; // String |
final String classId = classId_example; // String |
final String slotId = slotId_example; // String |
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.listAttendance(studentId, classId, slotId, date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listAttendance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional]
 **classId** | **String**|  | [optional]
 **slotId** | **String**|  | [optional]
 **date** | **DateTime**|  | [optional]

### Return type

[**List&lt;AttendanceRecord&gt;**](AttendanceRecord.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listClasses**
> List<SchoolClass> listClasses(academicYearId, gradeLevel)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String academicYearId = academicYearId_example; // String |
final String gradeLevel = gradeLevel_example; // String |

try {
    final response = api.listClasses(academicYearId, gradeLevel);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listClasses: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **academicYearId** | **String**|  | [optional]
 **gradeLevel** | **String**|  | [optional]

### Return type

[**List&lt;SchoolClass&gt;**](SchoolClass.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEligibleExamGraders**
> List<EligibleExamGrader> listEligibleExamGraders(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listEligibleExamGraders(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listEligibleExamGraders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;EligibleExamGrader&gt;**](EligibleExamGrader.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamCategories**
> List<ExamCategory> listExamCategories()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.listExamCategories();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamCategories: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;ExamCategory&gt;**](ExamCategory.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamGraders**
> List<ExamGradingAssignment> listExamGraders(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listExamGraders(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamGraders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;ExamGradingAssignment&gt;**](ExamGradingAssignment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamPeriods**
> List<ExamPeriodSummary> listExamPeriods(academicYearId, semesterId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String academicYearId = academicYearId_example; // String |
final String semesterId = semesterId_example; // String |

try {
    final response = api.listExamPeriods(academicYearId, semesterId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamPeriods: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **academicYearId** | **String**|  | [optional]
 **semesterId** | **String**|  | [optional]

### Return type

[**List&lt;ExamPeriodSummary&gt;**](ExamPeriodSummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamResults**
> List<ExamResult> listExamResults(id, scheduleId, studentId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final String scheduleId = scheduleId_example; // String |
final String studentId = studentId_example; // String |

try {
    final response = api.listExamResults(id, scheduleId, studentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamResults: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **scheduleId** | **String**|  | [optional]
 **studentId** | **String**|  | [optional]

### Return type

[**List&lt;ExamResult&gt;**](ExamResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamReviews**
> List<ExamReview> listExamReviews(id, status)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final String status = status_example; // String |

try {
    final response = api.listExamReviews(id, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamReviews: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **status** | **String**|  | [optional]

### Return type

[**List&lt;ExamReview&gt;**](ExamReview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamRooms**
> List<ExamRoom> listExamRooms(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listExamRooms(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamRooms: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;ExamRoom&gt;**](ExamRoom.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamSchedules**
> List<ExamSchedule> listExamSchedules(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listExamSchedules(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamSchedules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;ExamSchedule&gt;**](ExamSchedule.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExamScoreAdjustments**
> List<ExamScoreAdjustment> listExamScoreAdjustments(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listExamScoreAdjustments(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listExamScoreAdjustments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;ExamScoreAdjustment&gt;**](ExamScoreAdjustment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGradeChangeLogs**
> List<GradeChangeLog> listGradeChangeLogs(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.listGradeChangeLogs(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listGradeChangeLogs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**List&lt;GradeChangeLog&gt;**](GradeChangeLog.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrades**
> List<Grade> listGrades(studentId, subjectId, semesterId, category, classId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String studentId = studentId_example; // String |
final String subjectId = subjectId_example; // String |
final String semesterId = semesterId_example; // String |
final String category = category_example; // String |
final String classId = classId_example; // String |

try {
    final response = api.listGrades(studentId, subjectId, semesterId, category, classId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listGrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional]
 **subjectId** | **String**|  | [optional]
 **semesterId** | **String**|  | [optional]
 **category** | **String**|  | [optional]
 **classId** | **String**|  | [optional]

### Return type

[**List&lt;Grade&gt;**](Grade.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRooms**
> List<Room> listRooms()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.listRooms();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listRooms: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Room&gt;**](Room.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSemesters**
> List<Semester> listSemesters(academicYearId)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String academicYearId = academicYearId_example; // String |

try {
    final response = api.listSemesters(academicYearId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listSemesters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **academicYearId** | **String**|  | [optional]

### Return type

[**List&lt;Semester&gt;**](Semester.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSubjects**
> List<Subject> listSubjects()



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();

try {
    final response = api.listSubjects();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listSubjects: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Subject&gt;**](Subject.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTeachingAssignments**
> List<TeachingAssignment> listTeachingAssignments(classId, subjectId, teacherId, semesterId, dayOfWeek, periodNo)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String classId = classId_example; // String |
final String subjectId = subjectId_example; // String |
final String teacherId = teacherId_example; // String |
final String semesterId = semesterId_example; // String |
final String dayOfWeek = dayOfWeek_example; // String |
final int periodNo = 56; // int |

try {
    final response = api.listTeachingAssignments(classId, subjectId, teacherId, semesterId, dayOfWeek, periodNo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listTeachingAssignments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  | [optional]
 **subjectId** | **String**|  | [optional]
 **teacherId** | **String**|  | [optional]
 **semesterId** | **String**|  | [optional]
 **dayOfWeek** | **String**|  | [optional]
 **periodNo** | **int**|  | [optional]

### Return type

[**List&lt;TeachingAssignment&gt;**](TeachingAssignment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTimetableSlots**
> List<TimetableSlot> listTimetableSlots(classId, teacherId, semesterId, dayOfWeek)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String classId = classId_example; // String |
final String teacherId = teacherId_example; // String |
final String semesterId = semesterId_example; // String |
final String dayOfWeek = dayOfWeek_example; // String |

try {
    final response = api.listTimetableSlots(classId, teacherId, semesterId, dayOfWeek);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->listTimetableSlots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  | [optional]
 **teacherId** | **String**|  | [optional]
 **semesterId** | **String**|  | [optional]
 **dayOfWeek** | **String**|  | [optional]

### Return type

[**List&lt;TimetableSlot&gt;**](TimetableSlot.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **lockExamScores**
> ExamPeriod lockExamScores(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.lockExamScores(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->lockExamScores: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishExamSchedule**
> ExamPeriod publishExamSchedule(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.publishExamSchedule(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->publishExamSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestExamReview**
> ExamReview requestExamReview(id, createExamReviewRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final CreateExamReviewRequest createExamReviewRequest = ; // CreateExamReviewRequest |

try {
    final response = api.requestExamReview(id, createExamReviewRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->requestExamReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **createExamReviewRequest** | [**CreateExamReviewRequest**](CreateExamReviewRequest.md)|  |

### Return type

[**ExamReview**](ExamReview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolveExamReview**
> ExamReview resolveExamReview(id, resolveExamReviewRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final ResolveExamReviewRequest resolveExamReviewRequest = ; // ResolveExamReviewRequest |

try {
    final response = api.resolveExamReview(id, resolveExamReviewRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->resolveExamReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **resolveExamReviewRequest** | [**ResolveExamReviewRequest**](ResolveExamReviewRequest.md)|  |

### Return type

[**ExamReview**](ExamReview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rolloverAcademicYear**
> YearRolloverResult rolloverAcademicYear(id, yearRolloverRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final YearRolloverRequest yearRolloverRequest = ; // YearRolloverRequest |

try {
    final response = api.rolloverAcademicYear(id, yearRolloverRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->rolloverAcademicYear: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **yearRolloverRequest** | [**YearRolloverRequest**](YearRolloverRequest.md)|  |

### Return type

[**YearRolloverResult**](YearRolloverResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveExamGrader**
> ExamGradingAssignment saveExamGrader(id, saveExamGraderRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamGraderRequest saveExamGraderRequest = ; // SaveExamGraderRequest |

try {
    final response = api.saveExamGrader(id, saveExamGraderRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->saveExamGrader: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamGraderRequest** | [**SaveExamGraderRequest**](SaveExamGraderRequest.md)|  |

### Return type

[**ExamGradingAssignment**](ExamGradingAssignment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveExamResults**
> List<ExamResult> saveExamResults(id, saveExamResultsRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamResultsRequest saveExamResultsRequest = ; // SaveExamResultsRequest |

try {
    final response = api.saveExamResults(id, saveExamResultsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->saveExamResults: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamResultsRequest** | [**SaveExamResultsRequest**](SaveExamResultsRequest.md)|  |

### Return type

[**List&lt;ExamResult&gt;**](ExamResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setStudentConduct**
> StudentYearlySummary setStudentConduct(id, studentId, conductRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final String studentId = studentId_example; // String |
final ConductRequest conductRequest = ; // ConductRequest |

try {
    final response = api.setStudentConduct(id, studentId, conductRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->setStudentConduct: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **studentId** | **String**|  |
 **conductRequest** | [**ConductRequest**](ConductRequest.md)|  |

### Return type

[**StudentYearlySummary**](StudentYearlySummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlockExamScores**
> ExamPeriod unlockExamScores(id)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |

try {
    final response = api.unlockExamScores(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->unlockExamScores: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlockLateAttendance**
> AttendanceSessionStatus unlockLateAttendance(unlockAttendanceRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final UnlockAttendanceRequest unlockAttendanceRequest = ; // UnlockAttendanceRequest |

try {
    final response = api.unlockLateAttendance(unlockAttendanceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->unlockLateAttendance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **unlockAttendanceRequest** | [**UnlockAttendanceRequest**](UnlockAttendanceRequest.md)|  |

### Return type

[**AttendanceSessionStatus**](AttendanceSessionStatus.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateExamCategory**
> ExamCategory updateExamCategory(id, saveExamCategoryRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamCategoryRequest saveExamCategoryRequest = ; // SaveExamCategoryRequest |

try {
    final response = api.updateExamCategory(id, saveExamCategoryRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->updateExamCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamCategoryRequest** | [**SaveExamCategoryRequest**](SaveExamCategoryRequest.md)|  |

### Return type

[**ExamCategory**](ExamCategory.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateExamPeriod**
> ExamPeriod updateExamPeriod(id, saveExamPeriodRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamPeriodRequest saveExamPeriodRequest = ; // SaveExamPeriodRequest |

try {
    final response = api.updateExamPeriod(id, saveExamPeriodRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->updateExamPeriod: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamPeriodRequest** | [**SaveExamPeriodRequest**](SaveExamPeriodRequest.md)|  |

### Return type

[**ExamPeriod**](ExamPeriod.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateExamSchedule**
> ExamSchedule updateExamSchedule(id, saveExamScheduleRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final SaveExamScheduleRequest saveExamScheduleRequest = ; // SaveExamScheduleRequest |

try {
    final response = api.updateExamSchedule(id, saveExamScheduleRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->updateExamSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **saveExamScheduleRequest** | [**SaveExamScheduleRequest**](SaveExamScheduleRequest.md)|  |

### Return type

[**ExamSchedule**](ExamSchedule.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGrade**
> Grade updateGrade(id, updateGradeRequest)



### Example
```dart
import 'package:sse_academic_api/api.dart';

final api = SseAcademicApi().getAcademicApi();
final String id = id_example; // String |
final UpdateGradeRequest updateGradeRequest = ; // UpdateGradeRequest |

try {
    final response = api.updateGrade(id, updateGradeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AcademicApi->updateGrade: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **updateGradeRequest** | [**UpdateGradeRequest**](UpdateGradeRequest.md)|  |

### Return type

[**Grade**](Grade.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
