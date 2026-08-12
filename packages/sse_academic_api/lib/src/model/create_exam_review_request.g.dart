// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_exam_review_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateExamReviewRequestCWProxy {
  CreateExamReviewRequest resultId(String resultId);

  CreateExamReviewRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExamReviewRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExamReviewRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExamReviewRequest call({String resultId, String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateExamReviewRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateExamReviewRequest.copyWith.fieldName(...)`
class _$CreateExamReviewRequestCWProxyImpl
    implements _$CreateExamReviewRequestCWProxy {
  const _$CreateExamReviewRequestCWProxyImpl(this._value);

  final CreateExamReviewRequest _value;

  @override
  CreateExamReviewRequest resultId(String resultId) => this(resultId: resultId);

  @override
  CreateExamReviewRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExamReviewRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExamReviewRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExamReviewRequest call({
    Object? resultId = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return CreateExamReviewRequest(
      resultId: resultId == const $CopyWithPlaceholder()
          ? _value.resultId
          // ignore: cast_nullable_to_non_nullable
          : resultId as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $CreateExamReviewRequestCopyWith on CreateExamReviewRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateExamReviewRequest.copyWith(...)` or like so:`instanceOfCreateExamReviewRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateExamReviewRequestCWProxy get copyWith =>
      _$CreateExamReviewRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExamReviewRequest _$CreateExamReviewRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateExamReviewRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['resultId', 'reason']);
  final val = CreateExamReviewRequest(
    resultId: $checkedConvert('resultId', (v) => v as String),
    reason: $checkedConvert('reason', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$CreateExamReviewRequestToJson(
  CreateExamReviewRequest instance,
) => <String, dynamic>{
  'resultId': instance.resultId,
  'reason': instance.reason,
};
