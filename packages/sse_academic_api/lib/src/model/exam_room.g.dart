// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_room.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamRoomCWProxy {
  ExamRoom id(String id);

  ExamRoom scheduleId(String scheduleId);

  ExamRoom roomCode(String roomCode);

  ExamRoom capacity(int capacity);

  ExamRoom proctorOneId(String? proctorOneId);

  ExamRoom proctorOneName(String? proctorOneName);

  ExamRoom proctorTwoId(String? proctorTwoId);

  ExamRoom proctorTwoName(String? proctorTwoName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamRoom(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamRoom(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamRoom call({
    String id,
    String scheduleId,
    String roomCode,
    int capacity,
    String? proctorOneId,
    String? proctorOneName,
    String? proctorTwoId,
    String? proctorTwoName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamRoom.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamRoom.copyWith.fieldName(...)`
class _$ExamRoomCWProxyImpl implements _$ExamRoomCWProxy {
  const _$ExamRoomCWProxyImpl(this._value);

  final ExamRoom _value;

  @override
  ExamRoom id(String id) => this(id: id);

  @override
  ExamRoom scheduleId(String scheduleId) => this(scheduleId: scheduleId);

  @override
  ExamRoom roomCode(String roomCode) => this(roomCode: roomCode);

  @override
  ExamRoom capacity(int capacity) => this(capacity: capacity);

  @override
  ExamRoom proctorOneId(String? proctorOneId) =>
      this(proctorOneId: proctorOneId);

  @override
  ExamRoom proctorOneName(String? proctorOneName) =>
      this(proctorOneName: proctorOneName);

  @override
  ExamRoom proctorTwoId(String? proctorTwoId) =>
      this(proctorTwoId: proctorTwoId);

  @override
  ExamRoom proctorTwoName(String? proctorTwoName) =>
      this(proctorTwoName: proctorTwoName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamRoom(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamRoom(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamRoom call({
    Object? id = const $CopyWithPlaceholder(),
    Object? scheduleId = const $CopyWithPlaceholder(),
    Object? roomCode = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? proctorOneId = const $CopyWithPlaceholder(),
    Object? proctorOneName = const $CopyWithPlaceholder(),
    Object? proctorTwoId = const $CopyWithPlaceholder(),
    Object? proctorTwoName = const $CopyWithPlaceholder(),
  }) {
    return ExamRoom(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      scheduleId: scheduleId == const $CopyWithPlaceholder()
          ? _value.scheduleId
          // ignore: cast_nullable_to_non_nullable
          : scheduleId as String,
      roomCode: roomCode == const $CopyWithPlaceholder()
          ? _value.roomCode
          // ignore: cast_nullable_to_non_nullable
          : roomCode as String,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int,
      proctorOneId: proctorOneId == const $CopyWithPlaceholder()
          ? _value.proctorOneId
          // ignore: cast_nullable_to_non_nullable
          : proctorOneId as String?,
      proctorOneName: proctorOneName == const $CopyWithPlaceholder()
          ? _value.proctorOneName
          // ignore: cast_nullable_to_non_nullable
          : proctorOneName as String?,
      proctorTwoId: proctorTwoId == const $CopyWithPlaceholder()
          ? _value.proctorTwoId
          // ignore: cast_nullable_to_non_nullable
          : proctorTwoId as String?,
      proctorTwoName: proctorTwoName == const $CopyWithPlaceholder()
          ? _value.proctorTwoName
          // ignore: cast_nullable_to_non_nullable
          : proctorTwoName as String?,
    );
  }
}

extension $ExamRoomCopyWith on ExamRoom {
  /// Returns a callable class that can be used as follows: `instanceOfExamRoom.copyWith(...)` or like so:`instanceOfExamRoom.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamRoomCWProxy get copyWith => _$ExamRoomCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamRoom _$ExamRoomFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamRoom', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'scheduleId', 'roomCode', 'capacity'],
      );
      final val = ExamRoom(
        id: $checkedConvert('id', (v) => v as String),
        scheduleId: $checkedConvert('scheduleId', (v) => v as String),
        roomCode: $checkedConvert('roomCode', (v) => v as String),
        capacity: $checkedConvert('capacity', (v) => (v as num).toInt()),
        proctorOneId: $checkedConvert('proctorOneId', (v) => v as String?),
        proctorOneName: $checkedConvert('proctorOneName', (v) => v as String?),
        proctorTwoId: $checkedConvert('proctorTwoId', (v) => v as String?),
        proctorTwoName: $checkedConvert('proctorTwoName', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ExamRoomToJson(ExamRoom instance) => <String, dynamic>{
  'id': instance.id,
  'scheduleId': instance.scheduleId,
  'roomCode': instance.roomCode,
  'capacity': instance.capacity,
  'proctorOneId': ?instance.proctorOneId,
  'proctorOneName': ?instance.proctorOneName,
  'proctorTwoId': ?instance.proctorTwoId,
  'proctorTwoName': ?instance.proctorTwoName,
};
