// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_score_adjustment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamScoreAdjustmentCWProxy {
  ExamScoreAdjustment id(String id);

  ExamScoreAdjustment examPeriodId(String examPeriodId);

  ExamScoreAdjustment resultId(String resultId);

  ExamScoreAdjustment reviewRequestId(String? reviewRequestId);

  ExamScoreAdjustment oldScore(num? oldScore);

  ExamScoreAdjustment newScore(num? newScore);

  ExamScoreAdjustment reason(String reason);

  ExamScoreAdjustment adjustedAt(DateTime adjustedAt);

  ExamScoreAdjustment adjustedBy(String adjustedBy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamScoreAdjustment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamScoreAdjustment(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamScoreAdjustment call({
    String id,
    String examPeriodId,
    String resultId,
    String? reviewRequestId,
    num? oldScore,
    num? newScore,
    String reason,
    DateTime adjustedAt,
    String adjustedBy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamScoreAdjustment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamScoreAdjustment.copyWith.fieldName(...)`
class _$ExamScoreAdjustmentCWProxyImpl implements _$ExamScoreAdjustmentCWProxy {
  const _$ExamScoreAdjustmentCWProxyImpl(this._value);

  final ExamScoreAdjustment _value;

  @override
  ExamScoreAdjustment id(String id) => this(id: id);

  @override
  ExamScoreAdjustment examPeriodId(String examPeriodId) =>
      this(examPeriodId: examPeriodId);

  @override
  ExamScoreAdjustment resultId(String resultId) => this(resultId: resultId);

  @override
  ExamScoreAdjustment reviewRequestId(String? reviewRequestId) =>
      this(reviewRequestId: reviewRequestId);

  @override
  ExamScoreAdjustment oldScore(num? oldScore) => this(oldScore: oldScore);

  @override
  ExamScoreAdjustment newScore(num? newScore) => this(newScore: newScore);

  @override
  ExamScoreAdjustment reason(String reason) => this(reason: reason);

  @override
  ExamScoreAdjustment adjustedAt(DateTime adjustedAt) =>
      this(adjustedAt: adjustedAt);

  @override
  ExamScoreAdjustment adjustedBy(String adjustedBy) =>
      this(adjustedBy: adjustedBy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamScoreAdjustment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamScoreAdjustment(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamScoreAdjustment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? examPeriodId = const $CopyWithPlaceholder(),
    Object? resultId = const $CopyWithPlaceholder(),
    Object? reviewRequestId = const $CopyWithPlaceholder(),
    Object? oldScore = const $CopyWithPlaceholder(),
    Object? newScore = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? adjustedAt = const $CopyWithPlaceholder(),
    Object? adjustedBy = const $CopyWithPlaceholder(),
  }) {
    return ExamScoreAdjustment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      examPeriodId: examPeriodId == const $CopyWithPlaceholder()
          ? _value.examPeriodId
          // ignore: cast_nullable_to_non_nullable
          : examPeriodId as String,
      resultId: resultId == const $CopyWithPlaceholder()
          ? _value.resultId
          // ignore: cast_nullable_to_non_nullable
          : resultId as String,
      reviewRequestId: reviewRequestId == const $CopyWithPlaceholder()
          ? _value.reviewRequestId
          // ignore: cast_nullable_to_non_nullable
          : reviewRequestId as String?,
      oldScore: oldScore == const $CopyWithPlaceholder()
          ? _value.oldScore
          // ignore: cast_nullable_to_non_nullable
          : oldScore as num?,
      newScore: newScore == const $CopyWithPlaceholder()
          ? _value.newScore
          // ignore: cast_nullable_to_non_nullable
          : newScore as num?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      adjustedAt: adjustedAt == const $CopyWithPlaceholder()
          ? _value.adjustedAt
          // ignore: cast_nullable_to_non_nullable
          : adjustedAt as DateTime,
      adjustedBy: adjustedBy == const $CopyWithPlaceholder()
          ? _value.adjustedBy
          // ignore: cast_nullable_to_non_nullable
          : adjustedBy as String,
    );
  }
}

extension $ExamScoreAdjustmentCopyWith on ExamScoreAdjustment {
  /// Returns a callable class that can be used as follows: `instanceOfExamScoreAdjustment.copyWith(...)` or like so:`instanceOfExamScoreAdjustment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamScoreAdjustmentCWProxy get copyWith =>
      _$ExamScoreAdjustmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamScoreAdjustment _$ExamScoreAdjustmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamScoreAdjustment', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'examPeriodId',
          'resultId',
          'reason',
          'adjustedAt',
          'adjustedBy',
        ],
      );
      final val = ExamScoreAdjustment(
        id: $checkedConvert('id', (v) => v as String),
        examPeriodId: $checkedConvert('examPeriodId', (v) => v as String),
        resultId: $checkedConvert('resultId', (v) => v as String),
        reviewRequestId: $checkedConvert(
          'reviewRequestId',
          (v) => v as String?,
        ),
        oldScore: $checkedConvert('oldScore', (v) => v as num?),
        newScore: $checkedConvert('newScore', (v) => v as num?),
        reason: $checkedConvert('reason', (v) => v as String),
        adjustedAt: $checkedConvert(
          'adjustedAt',
          (v) => DateTime.parse(v as String),
        ),
        adjustedBy: $checkedConvert('adjustedBy', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExamScoreAdjustmentToJson(
  ExamScoreAdjustment instance,
) => <String, dynamic>{
  'id': instance.id,
  'examPeriodId': instance.examPeriodId,
  'resultId': instance.resultId,
  'reviewRequestId': ?instance.reviewRequestId,
  'oldScore': ?instance.oldScore,
  'newScore': ?instance.newScore,
  'reason': instance.reason,
  'adjustedAt': instance.adjustedAt.toIso8601String(),
  'adjustedBy': instance.adjustedBy,
};
