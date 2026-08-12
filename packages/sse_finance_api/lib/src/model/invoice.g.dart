// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvoiceCWProxy {
  Invoice id(String id);

  Invoice code(String code);

  Invoice studentId(String studentId);

  Invoice studentName(String? studentName);

  Invoice classId(String? classId);

  Invoice classCode(String? classCode);

  Invoice gradeLevel(String? gradeLevel);

  Invoice parentId(String? parentId);

  Invoice parentName(String? parentName);

  Invoice feePeriodId(String? feePeriodId);

  Invoice totalAmount(int totalAmount);

  Invoice paidAmount(int paidAmount);

  Invoice refundedAmount(int refundedAmount);

  Invoice status(InvoiceStatus status);

  Invoice issuedAt(DateTime? issuedAt);

  Invoice dueDate(DateTime? dueDate);

  Invoice version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invoice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invoice(...).copyWith(id: 12, name: "My name")
  /// ````
  Invoice call({
    String id,
    String code,
    String studentId,
    String? studentName,
    String? classId,
    String? classCode,
    String? gradeLevel,
    String? parentId,
    String? parentName,
    String? feePeriodId,
    int totalAmount,
    int paidAmount,
    int refundedAmount,
    InvoiceStatus status,
    DateTime? issuedAt,
    DateTime? dueDate,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvoice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvoice.copyWith.fieldName(...)`
class _$InvoiceCWProxyImpl implements _$InvoiceCWProxy {
  const _$InvoiceCWProxyImpl(this._value);

  final Invoice _value;

  @override
  Invoice id(String id) => this(id: id);

  @override
  Invoice code(String code) => this(code: code);

  @override
  Invoice studentId(String studentId) => this(studentId: studentId);

  @override
  Invoice studentName(String? studentName) => this(studentName: studentName);

  @override
  Invoice classId(String? classId) => this(classId: classId);

  @override
  Invoice classCode(String? classCode) => this(classCode: classCode);

  @override
  Invoice gradeLevel(String? gradeLevel) => this(gradeLevel: gradeLevel);

  @override
  Invoice parentId(String? parentId) => this(parentId: parentId);

  @override
  Invoice parentName(String? parentName) => this(parentName: parentName);

  @override
  Invoice feePeriodId(String? feePeriodId) => this(feePeriodId: feePeriodId);

  @override
  Invoice totalAmount(int totalAmount) => this(totalAmount: totalAmount);

  @override
  Invoice paidAmount(int paidAmount) => this(paidAmount: paidAmount);

  @override
  Invoice refundedAmount(int refundedAmount) =>
      this(refundedAmount: refundedAmount);

  @override
  Invoice status(InvoiceStatus status) => this(status: status);

  @override
  Invoice issuedAt(DateTime? issuedAt) => this(issuedAt: issuedAt);

  @override
  Invoice dueDate(DateTime? dueDate) => this(dueDate: dueDate);

  @override
  Invoice version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Invoice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Invoice(...).copyWith(id: 12, name: "My name")
  /// ````
  Invoice call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? studentId = const $CopyWithPlaceholder(),
    Object? studentName = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? gradeLevel = const $CopyWithPlaceholder(),
    Object? parentId = const $CopyWithPlaceholder(),
    Object? parentName = const $CopyWithPlaceholder(),
    Object? feePeriodId = const $CopyWithPlaceholder(),
    Object? totalAmount = const $CopyWithPlaceholder(),
    Object? paidAmount = const $CopyWithPlaceholder(),
    Object? refundedAmount = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? issuedAt = const $CopyWithPlaceholder(),
    Object? dueDate = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return Invoice(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      studentName: studentName == const $CopyWithPlaceholder()
          ? _value.studentName
          // ignore: cast_nullable_to_non_nullable
          : studentName as String?,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String?,
      classCode: classCode == const $CopyWithPlaceholder()
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String?,
      gradeLevel: gradeLevel == const $CopyWithPlaceholder()
          ? _value.gradeLevel
          // ignore: cast_nullable_to_non_nullable
          : gradeLevel as String?,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as String?,
      parentName: parentName == const $CopyWithPlaceholder()
          ? _value.parentName
          // ignore: cast_nullable_to_non_nullable
          : parentName as String?,
      feePeriodId: feePeriodId == const $CopyWithPlaceholder()
          ? _value.feePeriodId
          // ignore: cast_nullable_to_non_nullable
          : feePeriodId as String?,
      totalAmount: totalAmount == const $CopyWithPlaceholder()
          ? _value.totalAmount
          // ignore: cast_nullable_to_non_nullable
          : totalAmount as int,
      paidAmount: paidAmount == const $CopyWithPlaceholder()
          ? _value.paidAmount
          // ignore: cast_nullable_to_non_nullable
          : paidAmount as int,
      refundedAmount: refundedAmount == const $CopyWithPlaceholder()
          ? _value.refundedAmount
          // ignore: cast_nullable_to_non_nullable
          : refundedAmount as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as InvoiceStatus,
      issuedAt: issuedAt == const $CopyWithPlaceholder()
          ? _value.issuedAt
          // ignore: cast_nullable_to_non_nullable
          : issuedAt as DateTime?,
      dueDate: dueDate == const $CopyWithPlaceholder()
          ? _value.dueDate
          // ignore: cast_nullable_to_non_nullable
          : dueDate as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $InvoiceCopyWith on Invoice {
  /// Returns a callable class that can be used as follows: `instanceOfInvoice.copyWith(...)` or like so:`instanceOfInvoice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvoiceCWProxy get copyWith => _$InvoiceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Invoice', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'code',
          'studentId',
          'totalAmount',
          'paidAmount',
          'refundedAmount',
          'status',
          'version',
        ],
      );
      final val = Invoice(
        id: $checkedConvert('id', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        studentId: $checkedConvert('studentId', (v) => v as String),
        studentName: $checkedConvert('studentName', (v) => v as String?),
        classId: $checkedConvert('classId', (v) => v as String?),
        classCode: $checkedConvert('classCode', (v) => v as String?),
        gradeLevel: $checkedConvert('gradeLevel', (v) => v as String?),
        parentId: $checkedConvert('parentId', (v) => v as String?),
        parentName: $checkedConvert('parentName', (v) => v as String?),
        feePeriodId: $checkedConvert('feePeriodId', (v) => v as String?),
        totalAmount: $checkedConvert('totalAmount', (v) => (v as num).toInt()),
        paidAmount: $checkedConvert('paidAmount', (v) => (v as num).toInt()),
        refundedAmount: $checkedConvert(
          'refundedAmount',
          (v) => (v as num).toInt(),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$InvoiceStatusEnumMap, v),
        ),
        issuedAt: $checkedConvert(
          'issuedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        dueDate: $checkedConvert(
          'dueDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        version: $checkedConvert('version', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'studentId': instance.studentId,
  'studentName': ?instance.studentName,
  'classId': ?instance.classId,
  'classCode': ?instance.classCode,
  'gradeLevel': ?instance.gradeLevel,
  'parentId': ?instance.parentId,
  'parentName': ?instance.parentName,
  'feePeriodId': ?instance.feePeriodId,
  'totalAmount': instance.totalAmount,
  'paidAmount': instance.paidAmount,
  'refundedAmount': instance.refundedAmount,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'issuedAt': ?instance.issuedAt?.toIso8601String(),
  'dueDate': ?instance.dueDate?.toIso8601String(),
  'version': instance.version,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.UNPAID: 'UNPAID',
  InvoiceStatus.PARTIAL: 'PARTIAL',
  InvoiceStatus.PAID: 'PAID',
  InvoiceStatus.OVERDUE: 'OVERDUE',
  InvoiceStatus.CANCELLED: 'CANCELLED',
  InvoiceStatus.PARTIALLY_REFUNDED: 'PARTIALLY_REFUNDED',
  InvoiceStatus.REFUNDED: 'REFUNDED',
};
