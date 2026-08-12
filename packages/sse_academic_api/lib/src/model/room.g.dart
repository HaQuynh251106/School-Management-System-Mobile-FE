// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoomCWProxy {
  Room id(String id);

  Room code(String code);

  Room name(String name);

  Room capacity(int? capacity);

  Room supportsMorning(bool supportsMorning);

  Room supportsAfternoon(bool supportsAfternoon);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Room(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Room(...).copyWith(id: 12, name: "My name")
  /// ````
  Room call({
    String id,
    String code,
    String name,
    int? capacity,
    bool supportsMorning,
    bool supportsAfternoon,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRoom.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRoom.copyWith.fieldName(...)`
class _$RoomCWProxyImpl implements _$RoomCWProxy {
  const _$RoomCWProxyImpl(this._value);

  final Room _value;

  @override
  Room id(String id) => this(id: id);

  @override
  Room code(String code) => this(code: code);

  @override
  Room name(String name) => this(name: name);

  @override
  Room capacity(int? capacity) => this(capacity: capacity);

  @override
  Room supportsMorning(bool supportsMorning) =>
      this(supportsMorning: supportsMorning);

  @override
  Room supportsAfternoon(bool supportsAfternoon) =>
      this(supportsAfternoon: supportsAfternoon);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Room(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Room(...).copyWith(id: 12, name: "My name")
  /// ````
  Room call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? supportsMorning = const $CopyWithPlaceholder(),
    Object? supportsAfternoon = const $CopyWithPlaceholder(),
  }) {
    return Room(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      supportsMorning: supportsMorning == const $CopyWithPlaceholder()
          ? _value.supportsMorning
          // ignore: cast_nullable_to_non_nullable
          : supportsMorning as bool,
      supportsAfternoon: supportsAfternoon == const $CopyWithPlaceholder()
          ? _value.supportsAfternoon
          // ignore: cast_nullable_to_non_nullable
          : supportsAfternoon as bool,
    );
  }
}

extension $RoomCopyWith on Room {
  /// Returns a callable class that can be used as follows: `instanceOfRoom.copyWith(...)` or like so:`instanceOfRoom.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoomCWProxy get copyWith => _$RoomCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => $checkedCreate('Room', json, (
  $checkedConvert,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'code',
      'name',
      'supportsMorning',
      'supportsAfternoon',
    ],
  );
  final val = Room(
    id: $checkedConvert('id', (v) => v as String),
    code: $checkedConvert('code', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt()),
    supportsMorning: $checkedConvert('supportsMorning', (v) => v as bool),
    supportsAfternoon: $checkedConvert('supportsAfternoon', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'capacity': ?instance.capacity,
  'supportsMorning': instance.supportsMorning,
  'supportsAfternoon': instance.supportsAfternoon,
};
