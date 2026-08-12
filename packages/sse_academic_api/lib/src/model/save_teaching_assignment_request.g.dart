// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_teaching_assignment_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveTeachingAssignmentRequestCWProxy {
  SaveTeachingAssignmentRequest classId(String classId);

  SaveTeachingAssignmentRequest subjectId(String subjectId);

  SaveTeachingAssignmentRequest teacherId(String teacherId);

  SaveTeachingAssignmentRequest semesterId(String semesterId);

  SaveTeachingAssignmentRequest weeklyPeriods(int weeklyPeriods);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveTeachingAssignmentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveTeachingAssignmentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveTeachingAssignmentRequest call({
    String classId,
    String subjectId,
    String teacherId,
    String semesterId,
    int weeklyPeriods,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveTeachingAssignmentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveTeachingAssignmentRequest.copyWith.fieldName(...)`
class _$SaveTeachingAssignmentRequestCWProxyImpl
    implements _$SaveTeachingAssignmentRequestCWProxy {
  const _$SaveTeachingAssignmentRequestCWProxyImpl(this._value);

  final SaveTeachingAssignmentRequest _value;

  @override
  SaveTeachingAssignmentRequest classId(String classId) =>
      this(classId: classId);

  @override
  SaveTeachingAssignmentRequest subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  SaveTeachingAssignmentRequest teacherId(String teacherId) =>
      this(teacherId: teacherId);

  @override
  SaveTeachingAssignmentRequest semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  SaveTeachingAssignmentRequest weeklyPeriods(int weeklyPeriods) =>
      this(weeklyPeriods: weeklyPeriods);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveTeachingAssignmentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveTeachingAssignmentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveTeachingAssignmentRequest call({
    Object? classId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? teacherId = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
    Object? weeklyPeriods = const $CopyWithPlaceholder(),
  }) {
    return SaveTeachingAssignmentRequest(
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
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
      weeklyPeriods: weeklyPeriods == const $CopyWithPlaceholder()
          ? _value.weeklyPeriods
          // ignore: cast_nullable_to_non_nullable
          : weeklyPeriods as int,
    );
  }
}

extension $SaveTeachingAssignmentRequestCopyWith
    on SaveTeachingAssignmentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveTeachingAssignmentRequest.copyWith(...)` or like so:`instanceOfSaveTeachingAssignmentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveTeachingAssignmentRequestCWProxy get copyWith =>
      _$SaveTeachingAssignmentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveTeachingAssignmentRequest _$SaveTeachingAssignmentRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveTeachingAssignmentRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'classId',
      'subjectId',
      'teacherId',
      'semesterId',
      'weeklyPeriods',
    ],
  );
  final val = SaveTeachingAssignmentRequest(
    classId: $checkedConvert('classId', (v) => v as String),
    subjectId: $checkedConvert('subjectId', (v) => v as String),
    teacherId: $checkedConvert('teacherId', (v) => v as String),
    semesterId: $checkedConvert('semesterId', (v) => v as String),
    weeklyPeriods: $checkedConvert('weeklyPeriods', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SaveTeachingAssignmentRequestToJson(
  SaveTeachingAssignmentRequest instance,
) => <String, dynamic>{
  'classId': instance.classId,
  'subjectId': instance.subjectId,
  'teacherId': instance.teacherId,
  'semesterId': instance.semesterId,
  'weeklyPeriods': instance.weeklyPeriods,
};
