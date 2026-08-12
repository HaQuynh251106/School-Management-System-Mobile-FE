# sse_finance_api.model.Invoice

## Load the model package
```dart
import 'package:sse_finance_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**code** | **String** |  |
**studentId** | **String** |  |
**studentName** | **String** |  | [optional]
**classId** | **String** |  | [optional]
**classCode** | **String** |  | [optional]
**gradeLevel** | **String** |  | [optional]
**parentId** | **String** |  | [optional]
**parentName** | **String** |  | [optional]
**feePeriodId** | **String** |  | [optional]
**totalAmount** | **int** |  |
**paidAmount** | **int** |  |
**refundedAmount** | **int** |  |
**status** | [**InvoiceStatus**](InvoiceStatus.md) |  |
**issuedAt** | [**DateTime**](DateTime.md) |  | [optional]
**dueDate** | [**DateTime**](DateTime.md) |  | [optional]
**version** | **int** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
