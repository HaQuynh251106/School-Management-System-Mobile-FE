// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocate_exam_candidates_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AllocateExamCandidatesRequestCWProxy {
  AllocateExamCandidatesRequest classId(String classId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AllocateExamCandidatesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AllocateExamCandidatesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AllocateExamCandidatesRequest call({String classId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAllocateExamCandidatesRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAllocateExamCandidatesRequest.copyWith.fieldName(...)`
class _$AllocateExamCandidatesRequestCWProxyImpl
    implements _$AllocateExamCandidatesRequestCWProxy {
  const _$AllocateExamCandidatesRequestCWProxyImpl(this._value);

  final AllocateExamCandidatesRequest _value;

  @override
  AllocateExamCandidatesRequest classId(String classId) =>
      this(classId: classId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AllocateExamCandidatesRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AllocateExamCandidatesRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AllocateExamCandidatesRequest call({
    Object? classId = const $CopyWithPlaceholder(),
  }) {
    return AllocateExamCandidatesRequest(
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
    );
  }
}

extension $AllocateExamCandidatesRequestCopyWith
    on AllocateExamCandidatesRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAllocateExamCandidatesRequest.copyWith(...)` or like so:`instanceOfAllocateExamCandidatesRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AllocateExamCandidatesRequestCWProxy get copyWith =>
      _$AllocateExamCandidatesRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllocateExamCandidatesRequest _$AllocateExamCandidatesRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AllocateExamCandidatesRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['classId']);
  final val = AllocateExamCandidatesRequest(
    classId: $checkedConvert('classId', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AllocateExamCandidatesRequestToJson(
  AllocateExamCandidatesRequest instance,
) => <String, dynamic>{'classId': instance.classId};
