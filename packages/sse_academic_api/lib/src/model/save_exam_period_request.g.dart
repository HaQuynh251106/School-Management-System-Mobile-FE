// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_period_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamPeriodRequestCWProxy {
  SaveExamPeriodRequest id(String? id);

  SaveExamPeriodRequest code(String code);

  SaveExamPeriodRequest name(String name);

  SaveExamPeriodRequest academicYearId(String academicYearId);

  SaveExamPeriodRequest semesterId(String semesterId);

  SaveExamPeriodRequest gradeLevel(String? gradeLevel);

  SaveExamPeriodRequest startDate(DateTime startDate);

  SaveExamPeriodRequest endDate(DateTime endDate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamPeriodRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamPeriodRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamPeriodRequest call({
    String? id,
    String code,
    String name,
    String academicYearId,
    String semesterId,
    String? gradeLevel,
    DateTime startDate,
    DateTime endDate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamPeriodRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamPeriodRequest.copyWith.fieldName(...)`
class _$SaveExamPeriodRequestCWProxyImpl
    implements _$SaveExamPeriodRequestCWProxy {
  const _$SaveExamPeriodRequestCWProxyImpl(this._value);

  final SaveExamPeriodRequest _value;

  @override
  SaveExamPeriodRequest id(String? id) => this(id: id);

  @override
  SaveExamPeriodRequest code(String code) => this(code: code);

  @override
  SaveExamPeriodRequest name(String name) => this(name: name);

  @override
  SaveExamPeriodRequest academicYearId(String academicYearId) =>
      this(academicYearId: academicYearId);

  @override
  SaveExamPeriodRequest semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  SaveExamPeriodRequest gradeLevel(String? gradeLevel) =>
      this(gradeLevel: gradeLevel);

  @override
  SaveExamPeriodRequest startDate(DateTime startDate) =>
      this(startDate: startDate);

  @override
  SaveExamPeriodRequest endDate(DateTime endDate) => this(endDate: endDate);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamPeriodRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamPeriodRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamPeriodRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? academicYearId = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
    Object? gradeLevel = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
  }) {
    return SaveExamPeriodRequest(
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
          : name as String,
      academicYearId: academicYearId == const $CopyWithPlaceholder()
          ? _value.academicYearId
          // ignore: cast_nullable_to_non_nullable
          : academicYearId as String,
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
      gradeLevel: gradeLevel == const $CopyWithPlaceholder()
          ? _value.gradeLevel
          // ignore: cast_nullable_to_non_nullable
          : gradeLevel as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      endDate: endDate == const $CopyWithPlaceholder()
          ? _value.endDate
          // ignore: cast_nullable_to_non_nullable
          : endDate as DateTime,
    );
  }
}

extension $SaveExamPeriodRequestCopyWith on SaveExamPeriodRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamPeriodRequest.copyWith(...)` or like so:`instanceOfSaveExamPeriodRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamPeriodRequestCWProxy get copyWith =>
      _$SaveExamPeriodRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamPeriodRequest _$SaveExamPeriodRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveExamPeriodRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'code',
      'name',
      'academicYearId',
      'semesterId',
      'startDate',
      'endDate',
    ],
  );
  final val = SaveExamPeriodRequest(
    id: $checkedConvert('id', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    academicYearId: $checkedConvert('academicYearId', (v) => v as String),
    semesterId: $checkedConvert('semesterId', (v) => v as String),
    gradeLevel: $checkedConvert('gradeLevel', (v) => v as String?),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SaveExamPeriodRequestToJson(
  SaveExamPeriodRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': instance.code,
  'name': instance.name,
  'academicYearId': instance.academicYearId,
  'semesterId': instance.semesterId,
  'gradeLevel': ?instance.gradeLevel,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};
