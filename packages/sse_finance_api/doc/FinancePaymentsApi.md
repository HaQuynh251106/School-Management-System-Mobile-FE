# sse_finance_api.api.FinancePaymentsApi

## Load the API package
```dart
import 'package:sse_finance_api/api.dart';
```

All URIs are relative to *http://localhost:4000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**confirmVietQrPayment**](FinancePaymentsApi.md#confirmvietqrpayment) | **POST** /payments/{paymentId}/confirm-vietqr | Reconcile a VietQR transfer and issue a receipt
[**createVietQrPayment**](FinancePaymentsApi.md#createvietqrpayment) | **POST** /payments | Create or reuse a pending VietQR transaction
[**getInvoiceDetail**](FinancePaymentsApi.md#getinvoicedetail) | **GET** /invoices/{invoiceId} | Get an invoice with items, payments and refunds
[**listInvoicePayments**](FinancePaymentsApi.md#listinvoicepayments) | **GET** /payments | List payments of one invoice
[**listInvoices**](FinancePaymentsApi.md#listinvoices) | **GET** /invoices | List invoices visible to the current role
[**listPendingVietQrPayments**](FinancePaymentsApi.md#listpendingvietqrpayments) | **GET** /payments/vietqr/pending | List VietQR transfers awaiting reconciliation
[**markVietQrSubmitted**](FinancePaymentsApi.md#markvietqrsubmitted) | **POST** /payments/{paymentId}/submitted | Mark that the payer has submitted a VietQR transfer
[**recordCashPayment**](FinancePaymentsApi.md#recordcashpayment) | **POST** /payments/cash | Record a cash payment and issue a receipt
[**refundInvoice**](FinancePaymentsApi.md#refundinvoice) | **POST** /invoices/{invoiceId}/refund | Refund part or all of a paid invoice
[**rejectVietQrPayment**](FinancePaymentsApi.md#rejectvietqrpayment) | **POST** /payments/{paymentId}/reject-vietqr | Reject an invalid pending VietQR transfer


# **confirmVietQrPayment**
> VietQrCallbackResult confirmVietQrPayment(paymentId, vietQrConfirmationRequest)

Reconcile a VietQR transfer and issue a receipt

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String paymentId = paymentId_example; // String |
final VietQrConfirmationRequest vietQrConfirmationRequest = ; // VietQrConfirmationRequest |

try {
    final response = api.confirmVietQrPayment(paymentId, vietQrConfirmationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->confirmVietQrPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentId** | **String**|  |
 **vietQrConfirmationRequest** | [**VietQrConfirmationRequest**](VietQrConfirmationRequest.md)|  | [optional]

### Return type

[**VietQrCallbackResult**](VietQrCallbackResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createVietQrPayment**
> VietQrPaymentResult createVietQrPayment(payRequest)

Create or reuse a pending VietQR transaction

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final PayRequest payRequest = ; // PayRequest |

try {
    final response = api.createVietQrPayment(payRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->createVietQrPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **payRequest** | [**PayRequest**](PayRequest.md)|  |

### Return type

[**VietQrPaymentResult**](VietQrPaymentResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvoiceDetail**
> InvoiceDetail getInvoiceDetail(invoiceId)

Get an invoice with items, payments and refunds

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String invoiceId = invoiceId_example; // String |

try {
    final response = api.getInvoiceDetail(invoiceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->getInvoiceDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invoiceId** | **String**|  |

### Return type

[**InvoiceDetail**](InvoiceDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInvoicePayments**
> List<Payment> listInvoicePayments(invoiceId)

List payments of one invoice

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String invoiceId = invoiceId_example; // String |

try {
    final response = api.listInvoicePayments(invoiceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->listInvoicePayments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invoiceId** | **String**|  |

### Return type

[**List&lt;Payment&gt;**](Payment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInvoices**
> List<Invoice> listInvoices(studentId, parentId, status, periodId, q, classId, gradeLevel)

List invoices visible to the current role

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String studentId = studentId_example; // String |
final String parentId = parentId_example; // String |
final InvoiceStatus status = ; // InvoiceStatus |
final String periodId = periodId_example; // String |
final String q = q_example; // String |
final String classId = classId_example; // String |
final String gradeLevel = gradeLevel_example; // String |

try {
    final response = api.listInvoices(studentId, parentId, status, periodId, q, classId, gradeLevel);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->listInvoices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional]
 **parentId** | **String**|  | [optional]
 **status** | [**InvoiceStatus**](.md)|  | [optional]
 **periodId** | **String**|  | [optional]
 **q** | **String**|  | [optional]
 **classId** | **String**|  | [optional]
 **gradeLevel** | **String**|  | [optional]

### Return type

[**List&lt;Invoice&gt;**](Invoice.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPendingVietQrPayments**
> List<VietQrPaymentResult> listPendingVietQrPayments()

List VietQR transfers awaiting reconciliation

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();

try {
    final response = api.listPendingVietQrPayments();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->listPendingVietQrPayments: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;VietQrPaymentResult&gt;**](VietQrPaymentResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markVietQrSubmitted**
> VietQrCallbackResult markVietQrSubmitted(paymentId)

Mark that the payer has submitted a VietQR transfer

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String paymentId = paymentId_example; // String |

try {
    final response = api.markVietQrSubmitted(paymentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->markVietQrSubmitted: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentId** | **String**|  |

### Return type

[**VietQrCallbackResult**](VietQrCallbackResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordCashPayment**
> PaymentMutationResult recordCashPayment(cashPaymentRequest)

Record a cash payment and issue a receipt

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final CashPaymentRequest cashPaymentRequest = ; // CashPaymentRequest |

try {
    final response = api.recordCashPayment(cashPaymentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->recordCashPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cashPaymentRequest** | [**CashPaymentRequest**](CashPaymentRequest.md)|  |

### Return type

[**PaymentMutationResult**](PaymentMutationResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refundInvoice**
> RefundMutationResult refundInvoice(invoiceId, refundInvoiceRequest)

Refund part or all of a paid invoice

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String invoiceId = invoiceId_example; // String |
final RefundInvoiceRequest refundInvoiceRequest = ; // RefundInvoiceRequest |

try {
    final response = api.refundInvoice(invoiceId, refundInvoiceRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->refundInvoice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invoiceId** | **String**|  |
 **refundInvoiceRequest** | [**RefundInvoiceRequest**](RefundInvoiceRequest.md)|  |

### Return type

[**RefundMutationResult**](RefundMutationResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectVietQrPayment**
> VietQrCallbackResult rejectVietQrPayment(paymentId)

Reject an invalid pending VietQR transfer

### Example
```dart
import 'package:sse_finance_api/api.dart';

final api = SseFinanceApi().getFinancePaymentsApi();
final String paymentId = paymentId_example; // String |

try {
    final response = api.rejectVietQrPayment(paymentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FinancePaymentsApi->rejectVietQrPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentId** | **String**|  |

### Return type

[**VietQrCallbackResult**](VietQrCallbackResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
