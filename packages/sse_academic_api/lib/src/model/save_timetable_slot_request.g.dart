// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_timetable_slot_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveTimetableSlotRequestCWProxy {
  SaveTimetableSlotRequest id(String? id);

  SaveTimetableSlotRequest classId(String classId);

  SaveTimetableSlotRequest subjectId(String subjectId);

  SaveTimetableSlotRequest teacherId(String teacherId);

  SaveTimetableSlotRequest roomCode(String? roomCode);

  SaveTimetableSlotRequest dayOfWeek(String dayOfWeek);

  SaveTimetableSlotRequest periodNo(int periodNo);

  SaveTimetableSlotRequest startTime(String startTime);

  SaveTimetableSlotRequest endTime(String endTime);

  SaveTimetableSlotRequest semesterId(String semesterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveTimetableSlotRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveTimetableSlotRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveTimetableSlotRequest call({
    String? id,
    String classId,
    String subjectId,
    String teacherId,
    String? roomCode,
    String dayOfWeek,
    int periodNo,
    String startTime,
    String endTime,
    String semesterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveTimetableSlotRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveTimetableSlotRequest.copyWith.fieldName(...)`
class _$SaveTimetableSlotRequestCWProxyImpl
    implements _$SaveTimetableSlotRequestCWProxy {
  const _$SaveTimetableSlotRequestCWProxyImpl(this._value);

  final SaveTimetableSlotRequest _value;

  @override
  SaveTimetableSlotRequest id(String? id) => this(id: id);

  @override
  SaveTimetableSlotRequest classId(String classId) => this(classId: classId);

  @override
  SaveTimetableSlotRequest subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  SaveTimetableSlotRequest teacherId(String teacherId) =>
      this(teacherId: teacherId);

  @override
  SaveTimetableSlotRequest roomCode(String? roomCode) =>
      this(roomCode: roomCode);

  @override
  SaveTimetableSlotRequest dayOfWeek(String dayOfWeek) =>
      this(dayOfWeek: dayOfWeek);

  @override
  SaveTimetableSlotRequest periodNo(int periodNo) => this(periodNo: periodNo);

  @override
  SaveTimetableSlotRequest startTime(String startTime) =>
      this(startTime: startTime);

  @override
  SaveTimetableSlotRequest endTime(String endTime) => this(endTime: endTime);

  @override
  SaveTimetableSlotRequest semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveTimetableSlotRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveTimetableSlotRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveTimetableSlotRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? teacherId = const $CopyWithPlaceholder(),
    Object? roomCode = const $CopyWithPlaceholder(),
    Object? dayOfWeek = const $CopyWithPlaceholder(),
    Object? periodNo = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? endTime = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
  }) {
    return SaveTimetableSlotRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      teacherId: teacherId == const $CopyWithPlaceholder()
          ? _value.teacherId
          // ignore: cast_nullable_to_non_nullable
          : teacherId as String,
      roomCode: roomCode == const $CopyWithPlaceholder()
          ? _value.roomCode
          // ignore: cast_nullable_to_non_nullable
          : roomCode as String?,
      dayOfWeek: dayOfWeek == const $CopyWithPlaceholder()
          ? _value.dayOfWeek
          // ignore: cast_nullable_to_non_nullable
          : dayOfWeek as String,
      periodNo: periodNo == const $CopyWithPlaceholder()
          ? _value.periodNo
          // ignore: cast_nullable_to_non_nullable
          : periodNo as int,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as String,
      endTime: endTime == const $CopyWithPlaceholder()
          ? _value.endTime
          // ignore: cast_nullable_to_non_nullable
          : endTime as String,
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
    );
  }
}

extension $SaveTimetableSlotRequestCopyWith on SaveTimetableSlotRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveTimetableSlotRequest.copyWith(...)` or like so:`instanceOfSaveTimetableSlotRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveTimetableSlotRequestCWProxy get copyWith =>
      _$SaveTimetableSlotRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveTimetableSlotRequest _$SaveTimetableSlotRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveTimetableSlotRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'classId',
      'subjectId',
      'teacherId',
      'dayOfWeek',
      'periodNo',
      'startTime',
      'endTime',
      'semesterId',
    ],
  );
  final val = SaveTimetableSlotRequest(
    id: $checkedConvert('id', (v) => v as String?),
    classId: $checkedConvert('classId', (v) => v as String),
    subjectId: $checkedConvert('subjectId', (v) => v as String),
    teacherId: $checkedConvert('teacherId', (v) => v as String),
    roomCode: $checkedConvert('roomCode', (v) => v as String?),
    dayOfWeek: $checkedConvert('dayOfWeek', (v) => v as String),
    periodNo: $checkedConvert('periodNo', (v) => (v as num).toInt()),
    startTime: $checkedConvert('startTime', (v) => v as String),
    endTime: $checkedConvert('endTime', (v) => v as String),
    semesterId: $checkedConvert('semesterId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SaveTimetableSlotRequestToJson(
  SaveTimetableSlotRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'classId': instance.classId,
  'subjectId': instance.subjectId,
  'teacherId': instance.teacherId,
  'roomCode': ?instance.roomCode,
  'dayOfWeek': instance.dayOfWeek,
  'periodNo': instance.periodNo,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'semesterId': instance.semesterId,
};
