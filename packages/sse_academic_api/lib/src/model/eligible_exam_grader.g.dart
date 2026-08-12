// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eligible_exam_grader.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EligibleExamGraderCWProxy {
  EligibleExamGrader teacherId(String teacherId);

  EligibleExamGrader teacherCode(String? teacherCode);

  EligibleExamGrader teacherName(String teacherName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EligibleExamGrader(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EligibleExamGrader(...).copyWith(id: 12, name: "My name")
  /// ````
  EligibleExamGrader call({
    String teacherId,
    String? teacherCode,
    String teacherName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEligibleExamGrader.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEligibleExamGrader.copyWith.fieldName(...)`
class _$EligibleExamGraderCWProxyImpl implements _$EligibleExamGraderCWProxy {
  const _$EligibleExamGraderCWProxyImpl(this._value);

  final EligibleExamGrader _value;

  @override
  EligibleExamGrader teacherId(String teacherId) => this(teacherId: teacherId);

  @override
  EligibleExamGrader teacherCode(String? teacherCode) =>
      this(teacherCode: teacherCode);

  @override
  EligibleExamGrader teacherName(String teacherName) =>
      this(teacherName: teacherName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EligibleExamGrader(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EligibleExamGrader(...).copyWith(id: 12, name: "My name")
  /// ````
  EligibleExamGrader call({
    Object? teacherId = const $CopyWithPlaceholder(),
    Object? teacherCode = const $CopyWithPlaceholder(),
    Object? teacherName = const $CopyWithPlaceholder(),
  }) {
    return EligibleExamGrader(
      teacherId: teacherId == const $CopyWithPlaceholder()
          ? _value.teacherId
          // ignore: cast_nullable_to_non_nullable
          : teacherId as String,
      teacherCode: teacherCode == const $CopyWithPlaceholder()
          ? _value.teacherCode
          // ignore: cast_nullable_to_non_nullable
          : teacherCode as String?,
      teacherName: teacherName == const $CopyWithPlaceholder()
          ? _value.teacherName
          // ignore: cast_nullable_to_non_nullable
          : teacherName as String,
    );
  }
}

extension $EligibleExamGraderCopyWith on EligibleExamGrader {
  /// Returns a callable class that can be used as follows: `instanceOfEligibleExamGrader.copyWith(...)` or like so:`instanceOfEligibleExamGrader.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EligibleExamGraderCWProxy get copyWith =>
      _$EligibleExamGraderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EligibleExamGrader _$EligibleExamGraderFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EligibleExamGrader', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['teacherId', 'teacherName']);
      final val = EligibleExamGrader(
        teacherId: $checkedConvert('teacherId', (v) => v as String),
        teacherCode: $checkedConvert('teacherCode', (v) => v as String?),
        teacherName: $checkedConvert('teacherName', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$EligibleExamGraderToJson(EligibleExamGrader instance) =>
    <String, dynamic>{
      'teacherId': instance.teacherId,
      'teacherCode': ?instance.teacherCode,
      'teacherName': instance.teacherName,
    };
