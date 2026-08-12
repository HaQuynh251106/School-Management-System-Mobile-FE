//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Invoice {
  /// Returns a new [Invoice] instance.
  Invoice({
    required this.id,

    required this.code,

    required this.studentId,

    this.studentName,

    this.classId,

    this.classCode,

    this.gradeLevel,

    this.parentId,

    this.parentName,

    this.feePeriodId,

    required this.totalAmount,

    required this.paidAmount,

    required this.refundedAmount,

    required this.status,

    this.issuedAt,

    this.dueDate,

    required this.version,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: false, includeIfNull: false)
  final String? studentName;

  @JsonKey(name: r'classId', required: false, includeIfNull: false)
  final String? classId;

  @JsonKey(name: r'classCode', required: false, includeIfNull: false)
  final String? classCode;

  @JsonKey(name: r'gradeLevel', required: false, includeIfNull: false)
  final String? gradeLevel;

  @JsonKey(name: r'parentId', required: false, includeIfNull: false)
  final String? parentId;

  @JsonKey(name: r'parentName', required: false, includeIfNull: false)
  final String? parentName;

  @JsonKey(name: r'feePeriodId', required: false, includeIfNull: false)
  final String? feePeriodId;

  // minimum: 0
  @JsonKey(name: r'totalAmount', required: true, includeIfNull: false)
  final int totalAmount;

  // minimum: 0
  @JsonKey(name: r'paidAmount', required: true, includeIfNull: false)
  final int paidAmount;

  // minimum: 0
  @JsonKey(name: r'refundedAmount', required: true, includeIfNull: false)
  final int refundedAmount;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final InvoiceStatus status;

  @JsonKey(name: r'issuedAt', required: false, includeIfNull: false)
  final DateTime? issuedAt;

  @JsonKey(name: r'dueDate', required: false, includeIfNull: false)
  final DateTime? dueDate;

  // minimum: 0
  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice &&
          other.id == id &&
          other.code == code &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.gradeLevel == gradeLevel &&
          other.parentId == parentId &&
          other.parentName == parentName &&
          other.feePeriodId == feePeriodId &&
          other.totalAmount == totalAmount &&
          other.paidAmount == paidAmount &&
          other.refundedAmount == refundedAmount &&
          other.status == status &&
          other.issuedAt == issuedAt &&
          other.dueDate == dueDate &&
          other.version == version;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      studentId.hashCode +
      (studentName == null ? 0 : studentName.hashCode) +
      (classId == null ? 0 : classId.hashCode) +
      (classCode == null ? 0 : classCode.hashCode) +
      (gradeLevel == null ? 0 : gradeLevel.hashCode) +
      (parentId == null ? 0 : parentId.hashCode) +
      (parentName == null ? 0 : parentName.hashCode) +
      (feePeriodId == null ? 0 : feePeriodId.hashCode) +
      totalAmount.hashCode +
      paidAmount.hashCode +
      refundedAmount.hashCode +
      status.hashCode +
      (issuedAt == null ? 0 : issuedAt.hashCode) +
      (dueDate == null ? 0 : dueDate.hashCode) +
      version.hashCode;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
