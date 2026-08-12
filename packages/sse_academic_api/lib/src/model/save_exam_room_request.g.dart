// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_room_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamRoomRequestCWProxy {
  SaveExamRoomRequest id(String? id);

  SaveExamRoomRequest roomCode(String roomCode);

  SaveExamRoomRequest capacity(int capacity);

  SaveExamRoomRequest proctorOneId(String? proctorOneId);

  SaveExamRoomRequest proctorTwoId(String? proctorTwoId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamRoomRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamRoomRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamRoomRequest call({
    String? id,
    String roomCode,
    int capacity,
    String? proctorOneId,
    String? proctorTwoId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamRoomRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamRoomRequest.copyWith.fieldName(...)`
class _$SaveExamRoomRequestCWProxyImpl implements _$SaveExamRoomRequestCWProxy {
  const _$SaveExamRoomRequestCWProxyImpl(this._value);

  final SaveExamRoomRequest _value;

  @override
  SaveExamRoomRequest id(String? id) => this(id: id);

  @override
  SaveExamRoomRequest roomCode(String roomCode) => this(roomCode: roomCode);

  @override
  SaveExamRoomRequest capacity(int capacity) => this(capacity: capacity);

  @override
  SaveExamRoomRequest proctorOneId(String? proctorOneId) =>
      this(proctorOneId: proctorOneId);

  @override
  SaveExamRoomRequest proctorTwoId(String? proctorTwoId) =>
      this(proctorTwoId: proctorTwoId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamRoomRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamRoomRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamRoomRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? roomCode = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? proctorOneId = const $CopyWithPlaceholder(),
    Object? proctorTwoId = const $CopyWithPlaceholder(),
  }) {
    return SaveExamRoomRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
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
      proctorTwoId: proctorTwoId == const $CopyWithPlaceholder()
          ? _value.proctorTwoId
          // ignore: cast_nullable_to_non_nullable
          : proctorTwoId as String?,
    );
  }
}

extension $SaveExamRoomRequestCopyWith on SaveExamRoomRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamRoomRequest.copyWith(...)` or like so:`instanceOfSaveExamRoomRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamRoomRequestCWProxy get copyWith =>
      _$SaveExamRoomRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamRoomRequest _$SaveExamRoomRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SaveExamRoomRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['roomCode', 'capacity']);
      final val = SaveExamRoomRequest(
        id: $checkedConvert('id', (v) => v as String?),
        roomCode: $checkedConvert('roomCode', (v) => v as String),
        capacity: $checkedConvert('capacity', (v) => (v as num).toInt()),
        proctorOneId: $checkedConvert('proctorOneId', (v) => v as String?),
        proctorTwoId: $checkedConvert('proctorTwoId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SaveExamRoomRequestToJson(
  SaveExamRoomRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'roomCode': instance.roomCode,
  'capacity': instance.capacity,
  'proctorOneId': ?instance.proctorOneId,
  'proctorTwoId': ?instance.proctorTwoId,
};
