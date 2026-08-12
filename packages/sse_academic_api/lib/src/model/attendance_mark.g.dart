// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_mark.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttendanceMarkCWProxy {
  AttendanceMark studentId(String studentId);

  AttendanceMark status(AttendanceStatus status);

  AttendanceMark note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceMark(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceMark(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceMark call({
    String studentId,
    AttendanceStatus status,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttendanceMark.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttendanceMark.copyWith.fieldName(...)`
class _$AttendanceMarkCWProxyImpl implements _$AttendanceMarkCWProxy {
  const _$AttendanceMarkCWProxyImpl(this._value);

  final AttendanceMark _value;

  @override
  AttendanceMark studentId(String studentId) => this(studentId: studentId);

  @override
  AttendanceMark status(AttendanceStatus status) => this(status: status);

  @override
  AttendanceMark note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceMark(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceMark(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceMark call({
    Object? studentId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return AttendanceMark(
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AttendanceStatus,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $AttendanceMarkCopyWith on AttendanceMark {
  /// Returns a callable class that can be used as follows: `instanceOfAttendanceMark.copyWith(...)` or like so:`instanceOfAttendanceMark.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttendanceMarkCWProxy get copyWith => _$AttendanceMarkCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceMark _$AttendanceMarkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AttendanceMark', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['studentId', 'status']);
      final val = AttendanceMark(
        studentId: $checkedConvert('studentId', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$AttendanceStatusEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AttendanceMarkToJson(AttendanceMark instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'note': ?instance.note,
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.LATE: 'LATE',
  AttendanceStatus.ABSENT_UNEXCUSED: 'ABSENT_UNEXCUSED',
  AttendanceStatus.ABSENT_EXCUSED: 'ABSENT_EXCUSED',
};
