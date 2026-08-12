// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_attendance_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BulkAttendanceRequestCWProxy {
  BulkAttendanceRequest slotId(String slotId);

  BulkAttendanceRequest classId(String? classId);

  BulkAttendanceRequest date(DateTime date);

  BulkAttendanceRequest subjectName(String? subjectName);

  BulkAttendanceRequest periodNo(int? periodNo);

  BulkAttendanceRequest marks(List<AttendanceMark> marks);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BulkAttendanceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BulkAttendanceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BulkAttendanceRequest call({
    String slotId,
    String? classId,
    DateTime date,
    String? subjectName,
    int? periodNo,
    List<AttendanceMark> marks,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBulkAttendanceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBulkAttendanceRequest.copyWith.fieldName(...)`
class _$BulkAttendanceRequestCWProxyImpl
    implements _$BulkAttendanceRequestCWProxy {
  const _$BulkAttendanceRequestCWProxyImpl(this._value);

  final BulkAttendanceRequest _value;

  @override
  BulkAttendanceRequest slotId(String slotId) => this(slotId: slotId);

  @override
  BulkAttendanceRequest classId(String? classId) => this(classId: classId);

  @override
  BulkAttendanceRequest date(DateTime date) => this(date: date);

  @override
  BulkAttendanceRequest subjectName(String? subjectName) =>
      this(subjectName: subjectName);

  @override
  BulkAttendanceRequest periodNo(int? periodNo) => this(periodNo: periodNo);

  @override
  BulkAttendanceRequest marks(List<AttendanceMark> marks) => this(marks: marks);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BulkAttendanceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BulkAttendanceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BulkAttendanceRequest call({
    Object? slotId = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? periodNo = const $CopyWithPlaceholder(),
    Object? marks = const $CopyWithPlaceholder(),
  }) {
    return BulkAttendanceRequest(
      slotId: slotId == const $CopyWithPlaceholder()
          ? _value.slotId
          // ignore: cast_nullable_to_non_nullable
          : slotId as String,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String?,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String?,
      periodNo: periodNo == const $CopyWithPlaceholder()
          ? _value.periodNo
          // ignore: cast_nullable_to_non_nullable
          : periodNo as int?,
      marks: marks == const $CopyWithPlaceholder()
          ? _value.marks
          // ignore: cast_nullable_to_non_nullable
          : marks as List<AttendanceMark>,
    );
  }
}

extension $BulkAttendanceRequestCopyWith on BulkAttendanceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBulkAttendanceRequest.copyWith(...)` or like so:`instanceOfBulkAttendanceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BulkAttendanceRequestCWProxy get copyWith =>
      _$BulkAttendanceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkAttendanceRequest _$BulkAttendanceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BulkAttendanceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['slotId', 'date', 'marks']);
  final val = BulkAttendanceRequest(
    slotId: $checkedConvert('slotId', (v) => v as String),
    classId: $checkedConvert('classId', (v) => v as String?),
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    subjectName: $checkedConvert('subjectName', (v) => v as String?),
    periodNo: $checkedConvert('periodNo', (v) => (v as num?)?.toInt()),
    marks: $checkedConvert(
      'marks',
      (v) => (v as List<dynamic>)
          .map((e) => AttendanceMark.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BulkAttendanceRequestToJson(
  BulkAttendanceRequest instance,
) => <String, dynamic>{
  'slotId': instance.slotId,
  'classId': ?instance.classId,
  'date': instance.date.toIso8601String(),
  'subjectName': ?instance.subjectName,
  'periodNo': ?instance.periodNo,
  'marks': instance.marks.map((e) => e.toJson()).toList(),
};
