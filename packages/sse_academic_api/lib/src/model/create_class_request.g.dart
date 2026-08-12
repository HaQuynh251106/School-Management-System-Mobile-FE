// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_class_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateClassRequestCWProxy {
  CreateClassRequest id(String? id);

  CreateClassRequest code(String code);

  CreateClassRequest name(String? name);

  CreateClassRequest gradeLevel(String gradeLevel);

  CreateClassRequest academicYearId(String? academicYearId);

  CreateClassRequest homeroomTeacherId(String? homeroomTeacherId);

  CreateClassRequest studyShift(CreateClassRequestStudyShiftEnum? studyShift);

  CreateClassRequest capacity(int? capacity);

  CreateClassRequest roomId(String? roomId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateClassRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateClassRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateClassRequest call({
    String? id,
    String code,
    String? name,
    String gradeLevel,
    String? academicYearId,
    String? homeroomTeacherId,
    CreateClassRequestStudyShiftEnum? studyShift,
    int? capacity,
    String? roomId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateClassRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateClassRequest.copyWith.fieldName(...)`
class _$CreateClassRequestCWProxyImpl implements _$CreateClassRequestCWProxy {
  const _$CreateClassRequestCWProxyImpl(this._value);

  final CreateClassRequest _value;

  @override
  CreateClassRequest id(String? id) => this(id: id);

  @override
  CreateClassRequest code(String code) => this(code: code);

  @override
  CreateClassRequest name(String? name) => this(name: name);

  @override
  CreateClassRequest gradeLevel(String gradeLevel) =>
      this(gradeLevel: gradeLevel);

  @override
  CreateClassRequest academicYearId(String? academicYearId) =>
      this(academicYearId: academicYearId);

  @override
  CreateClassRequest homeroomTeacherId(String? homeroomTeacherId) =>
      this(homeroomTeacherId: homeroomTeacherId);

  @override
  CreateClassRequest studyShift(CreateClassRequestStudyShiftEnum? studyShift) =>
      this(studyShift: studyShift);

  @override
  CreateClassRequest capacity(int? capacity) => this(capacity: capacity);

  @override
  CreateClassRequest roomId(String? roomId) => this(roomId: roomId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateClassRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateClassRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateClassRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? gradeLevel = const $CopyWithPlaceholder(),
    Object? academicYearId = const $CopyWithPlaceholder(),
    Object? homeroomTeacherId = const $CopyWithPlaceholder(),
    Object? studyShift = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? roomId = const $CopyWithPlaceholder(),
  }) {
    return CreateClassRequest(
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
      gradeLevel: gradeLevel == const $CopyWithPlaceholder()
          ? _value.gradeLevel
          // ignore: cast_nullable_to_non_nullable
          : gradeLevel as String,
      academicYearId: academicYearId == const $CopyWithPlaceholder()
          ? _value.academicYearId
          // ignore: cast_nullable_to_non_nullable
          : academicYearId as String?,
      homeroomTeacherId: homeroomTeacherId == const $CopyWithPlaceholder()
          ? _value.homeroomTeacherId
          // ignore: cast_nullable_to_non_nullable
          : homeroomTeacherId as String?,
      studyShift: studyShift == const $CopyWithPlaceholder()
          ? _value.studyShift
          // ignore: cast_nullable_to_non_nullable
          : studyShift as CreateClassRequestStudyShiftEnum?,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      roomId: roomId == const $CopyWithPlaceholder()
          ? _value.roomId
          // ignore: cast_nullable_to_non_nullable
          : roomId as String?,
    );
  }
}

extension $CreateClassRequestCopyWith on CreateClassRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateClassRequest.copyWith(...)` or like so:`instanceOfCreateClassRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateClassRequestCWProxy get copyWith =>
      _$CreateClassRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateClassRequest _$CreateClassRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateClassRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'gradeLevel']);
      final val = CreateClassRequest(
        id: $checkedConvert('id', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        gradeLevel: $checkedConvert('gradeLevel', (v) => v as String),
        academicYearId: $checkedConvert('academicYearId', (v) => v as String?),
        homeroomTeacherId: $checkedConvert(
          'homeroomTeacherId',
          (v) => v as String?,
        ),
        studyShift: $checkedConvert(
          'studyShift',
          (v) =>
              $enumDecodeNullable(_$CreateClassRequestStudyShiftEnumEnumMap, v),
        ),
        capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt()),
        roomId: $checkedConvert('roomId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreateClassRequestToJson(
  CreateClassRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': instance.code,
  'name': ?instance.name,
  'gradeLevel': instance.gradeLevel,
  'academicYearId': ?instance.academicYearId,
  'homeroomTeacherId': ?instance.homeroomTeacherId,
  'studyShift': ?_$CreateClassRequestStudyShiftEnumEnumMap[instance.studyShift],
  'capacity': ?instance.capacity,
  'roomId': ?instance.roomId,
};

const _$CreateClassRequestStudyShiftEnumEnumMap = {
  CreateClassRequestStudyShiftEnum.MORNING: 'MORNING',
  CreateClassRequestStudyShiftEnum.AFTERNOON: 'AFTERNOON',
};
