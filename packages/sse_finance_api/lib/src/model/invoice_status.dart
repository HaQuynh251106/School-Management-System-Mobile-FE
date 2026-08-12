//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum InvoiceStatus {
  @JsonValue(r'UNPAID')
  UNPAID(r'UNPAID'),
  @JsonValue(r'PARTIAL')
  PARTIAL(r'PARTIAL'),
  @JsonValue(r'PAID')
  PAID(r'PAID'),
  @JsonValue(r'OVERDUE')
  OVERDUE(r'OVERDUE'),
  @JsonValue(r'CANCELLED')
  CANCELLED(r'CANCELLED'),
  @JsonValue(r'PARTIALLY_REFUNDED')
  PARTIALLY_REFUNDED(r'PARTIALLY_REFUNDED'),
  @JsonValue(r'REFUNDED')
  REFUNDED(r'REFUNDED');

  const InvoiceStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
