// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_grader_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamGraderRequestCWProxy {
  SaveExamGraderRequest classId(String classId);

  SaveExamGraderRequest teacherId(String teacherId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamGraderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamGraderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamGraderRequest call({String classId, String teacherId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamGraderRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamGraderRequest.copyWith.fieldName(...)`
class _$SaveExamGraderRequestCWProxyImpl
    implements _$SaveExamGraderRequestCWProxy {
  const _$SaveExamGraderRequestCWProxyImpl(this._value);

  final SaveExamGraderRequest _value;

  @override
  SaveExamGraderRequest classId(String classId) => this(classId: classId);

  @override
  SaveExamGraderRequest teacherId(String teacherId) =>
      this(teacherId: teacherId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamGraderRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamGraderRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamGraderRequest call({
    Object? classId = const $CopyWithPlaceholder(),
    Object? teacherId = const $CopyWithPlaceholder(),
  }) {
    return SaveExamGraderRequest(
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      teacherId: teacherId == const $CopyWithPlaceholder()
          ? _value.teacherId
          // ignore: cast_nullable_to_non_nullable
          : teacherId as String,
    );
  }
}

extension $SaveExamGraderRequestCopyWith on SaveExamGraderRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamGraderRequest.copyWith(...)` or like so:`instanceOfSaveExamGraderRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamGraderRequestCWProxy get copyWith =>
      _$SaveExamGraderRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamGraderRequest _$SaveExamGraderRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveExamGraderRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['classId', 'teacherId']);
  final val = SaveExamGraderRequest(
    classId: $checkedConvert('classId', (v) => v as String),
    teacherId: $checkedConvert('teacherId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SaveExamGraderRequestToJson(
  SaveExamGraderRequest instance,
) => <String, dynamic>{
  'classId': instance.classId,
  'teacherId': instance.teacherId,
};
