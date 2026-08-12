import 'package:sse_finance_api/src/model/api_error.dart';
import 'package:sse_finance_api/src/model/cash_payment_request.dart';
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/invoice_detail.dart';
import 'package:sse_finance_api/src/model/invoice_item.dart';
import 'package:sse_finance_api/src/model/invoice_refund.dart';
import 'package:sse_finance_api/src/model/pay_request.dart';
import 'package:sse_finance_api/src/model/payment.dart';
import 'package:sse_finance_api/src/model/payment_mutation_result.dart';
import 'package:sse_finance_api/src/model/refund_invoice_request.dart';
import 'package:sse_finance_api/src/model/refund_mutation_result.dart';
import 'package:sse_finance_api/src/model/viet_qr_callback_result.dart';
import 'package:sse_finance_api/src/model/viet_qr_confirmation_request.dart';
import 'package:sse_finance_api/src/model/viet_qr_payment_result.dart';

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
    case 'CashPaymentRequest':
      return CashPaymentRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Invoice':
      return Invoice.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'InvoiceDetail':
      return InvoiceDetail.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'InvoiceItem':
      return InvoiceItem.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'InvoiceRefund':
      return InvoiceRefund.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'InvoiceStatus':
    case 'PayRequest':
      return PayRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Payment':
      return Payment.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PaymentMutationResult':
      return PaymentMutationResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefundInvoiceRequest':
      return RefundInvoiceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefundMutationResult':
      return RefundMutationResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VietQrCallbackResult':
      return VietQrCallbackResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VietQrConfirmationRequest':
      return VietQrConfirmationRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VietQrPaymentResult':
      return VietQrPaymentResult.fromJson(value as Map<String, dynamic>)
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
