// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_room_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateRoomRequestCWProxy {
  CreateRoomRequest id(String? id);

  CreateRoomRequest code(String code);

  CreateRoomRequest name(String? name);

  CreateRoomRequest capacity(int? capacity);

  CreateRoomRequest supportsMorning(bool? supportsMorning);

  CreateRoomRequest supportsAfternoon(bool? supportsAfternoon);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateRoomRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateRoomRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateRoomRequest call({
    String? id,
    String code,
    String? name,
    int? capacity,
    bool? supportsMorning,
    bool? supportsAfternoon,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateRoomRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateRoomRequest.copyWith.fieldName(...)`
class _$CreateRoomRequestCWProxyImpl implements _$CreateRoomRequestCWProxy {
  const _$CreateRoomRequestCWProxyImpl(this._value);

  final CreateRoomRequest _value;

  @override
  CreateRoomRequest id(String? id) => this(id: id);

  @override
  CreateRoomRequest code(String code) => this(code: code);

  @override
  CreateRoomRequest name(String? name) => this(name: name);

  @override
  CreateRoomRequest capacity(int? capacity) => this(capacity: capacity);

  @override
  CreateRoomRequest supportsMorning(bool? supportsMorning) =>
      this(supportsMorning: supportsMorning);

  @override
  CreateRoomRequest supportsAfternoon(bool? supportsAfternoon) =>
      this(supportsAfternoon: supportsAfternoon);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateRoomRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateRoomRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateRoomRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? supportsMorning = const $CopyWithPlaceholder(),
    Object? supportsAfternoon = const $CopyWithPlaceholder(),
  }) {
    return CreateRoomRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      supportsMorning: supportsMorning == const $CopyWithPlaceholder()
          ? _value.supportsMorning
          // ignore: cast_nullable_to_non_nullable
          : supportsMorning as bool?,
      supportsAfternoon: supportsAfternoon == const $CopyWithPlaceholder()
          ? _value.supportsAfternoon
          // ignore: cast_nullable_to_non_nullable
          : supportsAfternoon as bool?,
    );
  }
}

extension $CreateRoomRequestCopyWith on CreateRoomRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateRoomRequest.copyWith(...)` or like so:`instanceOfCreateRoomRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateRoomRequestCWProxy get copyWith =>
      _$CreateRoomRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRoomRequest _$CreateRoomRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateRoomRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code']);
      final val = CreateRoomRequest(
        id: $checkedConvert('id', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt()),
        supportsMorning: $checkedConvert('supportsMorning', (v) => v as bool?),
        supportsAfternoon: $checkedConvert(
          'supportsAfternoon',
          (v) => v as bool?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreateRoomRequestToJson(CreateRoomRequest instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'code': instance.code,
      'name': ?instance.name,
      'capacity': ?instance.capacity,
      'supportsMorning': ?instance.supportsMorning,
      'supportsAfternoon': ?instance.supportsAfternoon,
    };
