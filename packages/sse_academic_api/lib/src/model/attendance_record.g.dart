// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttendanceRecordCWProxy {
  AttendanceRecord id(String id);

  AttendanceRecord studentId(String studentId);

  AttendanceRecord classId(String classId);

  AttendanceRecord slotId(String slotId);

  AttendanceRecord date(DateTime date);

  AttendanceRecord status(AttendanceStatus status);

  AttendanceRecord note(String? note);

  AttendanceRecord subjectName(String? subjectName);

  AttendanceRecord periodNo(int? periodNo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceRecord call({
    String id,
    String studentId,
    String classId,
    String slotId,
    DateTime date,
    AttendanceStatus status,
    String? note,
    String? subjectName,
    int? periodNo,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttendanceRecord.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttendanceRecord.copyWith.fieldName(...)`
class _$AttendanceRecordCWProxyImpl implements _$AttendanceRecordCWProxy {
  const _$AttendanceRecordCWProxyImpl(this._value);

  final AttendanceRecord _value;

  @override
  AttendanceRecord id(String id) => this(id: id);

  @override
  AttendanceRecord studentId(String studentId) => this(studentId: studentId);

  @override
  AttendanceRecord classId(String classId) => this(classId: classId);

  @override
  AttendanceRecord slotId(String slotId) => this(slotId: slotId);

  @override
  AttendanceRecord date(DateTime date) => this(date: date);

  @override
  AttendanceRecord status(AttendanceStatus status) => this(status: status);

  @override
  AttendanceRecord note(String? note) => this(note: note);

  @override
  AttendanceRecord subjectName(String? subjectName) =>
      this(subjectName: subjectName);

  @override
  AttendanceRecord periodNo(int? periodNo) => this(periodNo: periodNo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceRecord(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceRecord(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceRecord call({
    Object? id = const $CopyWithPlaceholder(),
    Object? studentId = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? slotId = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? periodNo = const $CopyWithPlaceholder(),
  }) {
    return AttendanceRecord(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      slotId: slotId == const $CopyWithPlaceholder()
          ? _value.slotId
          // ignore: cast_nullable_to_non_nullable
          : slotId as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AttendanceStatus,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String?,
      periodNo: periodNo == const $CopyWithPlaceholder()
          ? _value.periodNo
          // ignore: cast_nullable_to_non_nullable
          : periodNo as int?,
    );
  }
}

extension $AttendanceRecordCopyWith on AttendanceRecord {
  /// Returns a callable class that can be used as follows: `instanceOfAttendanceRecord.copyWith(...)` or like so:`instanceOfAttendanceRecord.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttendanceRecordCWProxy get copyWith => _$AttendanceRecordCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AttendanceRecord', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'studentId',
          'classId',
          'slotId',
          'date',
          'status',
        ],
      );
      final val = AttendanceRecord(
        id: $checkedConvert('id', (v) => v as String),
        studentId: $checkedConvert('studentId', (v) => v as String),
        classId: $checkedConvert('classId', (v) => v as String),
        slotId: $checkedConvert('slotId', (v) => v as String),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$AttendanceStatusEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String?),
        subjectName: $checkedConvert('subjectName', (v) => v as String?),
        periodNo: $checkedConvert('periodNo', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'slotId': instance.slotId,
      'date': instance.date.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'note': ?instance.note,
      'subjectName': ?instance.subjectName,
      'periodNo': ?instance.periodNo,
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.LATE: 'LATE',
  AttendanceStatus.ABSENT_UNEXCUSED: 'ABSENT_UNEXCUSED',
  AttendanceStatus.ABSENT_EXCUSED: 'ABSENT_EXCUSED',
};
