// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_exam_review_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResolveExamReviewRequestCWProxy {
  ResolveExamReviewRequest status(ResolveExamReviewRequestStatusEnum status);

  ResolveExamReviewRequest resolution(String resolution);

  ResolveExamReviewRequest resolvedScore(num? resolvedScore);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResolveExamReviewRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResolveExamReviewRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ResolveExamReviewRequest call({
    ResolveExamReviewRequestStatusEnum status,
    String resolution,
    num? resolvedScore,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResolveExamReviewRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResolveExamReviewRequest.copyWith.fieldName(...)`
class _$ResolveExamReviewRequestCWProxyImpl
    implements _$ResolveExamReviewRequestCWProxy {
  const _$ResolveExamReviewRequestCWProxyImpl(this._value);

  final ResolveExamReviewRequest _value;

  @override
  ResolveExamReviewRequest status(ResolveExamReviewRequestStatusEnum status) =>
      this(status: status);

  @override
  ResolveExamReviewRequest resolution(String resolution) =>
      this(resolution: resolution);

  @override
  ResolveExamReviewRequest resolvedScore(num? resolvedScore) =>
      this(resolvedScore: resolvedScore);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResolveExamReviewRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResolveExamReviewRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ResolveExamReviewRequest call({
    Object? status = const $CopyWithPlaceholder(),
    Object? resolution = const $CopyWithPlaceholder(),
    Object? resolvedScore = const $CopyWithPlaceholder(),
  }) {
    return ResolveExamReviewRequest(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ResolveExamReviewRequestStatusEnum,
      resolution: resolution == const $CopyWithPlaceholder()
          ? _value.resolution
          // ignore: cast_nullable_to_non_nullable
          : resolution as String,
      resolvedScore: resolvedScore == const $CopyWithPlaceholder()
          ? _value.resolvedScore
          // ignore: cast_nullable_to_non_nullable
          : resolvedScore as num?,
    );
  }
}

extension $ResolveExamReviewRequestCopyWith on ResolveExamReviewRequest {
  /// Returns a callable class that can be used as follows: `instanceOfResolveExamReviewRequest.copyWith(...)` or like so:`instanceOfResolveExamReviewRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResolveExamReviewRequestCWProxy get copyWith =>
      _$ResolveExamReviewRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveExamReviewRequest _$ResolveExamReviewRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResolveExamReviewRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['status', 'resolution']);
  final val = ResolveExamReviewRequest(
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$ResolveExamReviewRequestStatusEnumEnumMap, v),
    ),
    resolution: $checkedConvert('resolution', (v) => v as String),
    resolvedScore: $checkedConvert('resolvedScore', (v) => v as num?),
  );
  return val;
});

Map<String, dynamic> _$ResolveExamReviewRequestToJson(
  ResolveExamReviewRequest instance,
) => <String, dynamic>{
  'status': _$ResolveExamReviewRequestStatusEnumEnumMap[instance.status]!,
  'resolution': instance.resolution,
  'resolvedScore': ?instance.resolvedScore,
};

const _$ResolveExamReviewRequestStatusEnumEnumMap = {
  ResolveExamReviewRequestStatusEnum.APPROVED: 'APPROVED',
  ResolveExamReviewRequestStatusEnum.REJECTED: 'REJECTED',
};
