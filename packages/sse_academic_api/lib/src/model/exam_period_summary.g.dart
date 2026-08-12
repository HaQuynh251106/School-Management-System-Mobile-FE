// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_period_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamPeriodSummaryCWProxy {
  ExamPeriodSummary period(ExamPeriod period);

  ExamPeriodSummary scheduleCount(int scheduleCount);

  ExamPeriodSummary roomCount(int roomCount);

  ExamPeriodSummary candidateCount(int candidateCount);

  ExamPeriodSummary resultCount(int resultCount);

  ExamPeriodSummary pendingReviewCount(int pendingReviewCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamPeriodSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamPeriodSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamPeriodSummary call({
    ExamPeriod period,
    int scheduleCount,
    int roomCount,
    int candidateCount,
    int resultCount,
    int pendingReviewCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamPeriodSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamPeriodSummary.copyWith.fieldName(...)`
class _$ExamPeriodSummaryCWProxyImpl implements _$ExamPeriodSummaryCWProxy {
  const _$ExamPeriodSummaryCWProxyImpl(this._value);

  final ExamPeriodSummary _value;

  @override
  ExamPeriodSummary period(ExamPeriod period) => this(period: period);

  @override
  ExamPeriodSummary scheduleCount(int scheduleCount) =>
      this(scheduleCount: scheduleCount);

  @override
  ExamPeriodSummary roomCount(int roomCount) => this(roomCount: roomCount);

  @override
  ExamPeriodSummary candidateCount(int candidateCount) =>
      this(candidateCount: candidateCount);

  @override
  ExamPeriodSummary resultCount(int resultCount) =>
      this(resultCount: resultCount);

  @override
  ExamPeriodSummary pendingReviewCount(int pendingReviewCount) =>
      this(pendingReviewCount: pendingReviewCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamPeriodSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamPeriodSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamPeriodSummary call({
    Object? period = const $CopyWithPlaceholder(),
    Object? scheduleCount = const $CopyWithPlaceholder(),
    Object? roomCount = const $CopyWithPlaceholder(),
    Object? candidateCount = const $CopyWithPlaceholder(),
    Object? resultCount = const $CopyWithPlaceholder(),
    Object? pendingReviewCount = const $CopyWithPlaceholder(),
  }) {
    return ExamPeriodSummary(
      period: period == const $CopyWithPlaceholder()
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as ExamPeriod,
      scheduleCount: scheduleCount == const $CopyWithPlaceholder()
          ? _value.scheduleCount
          // ignore: cast_nullable_to_non_nullable
          : scheduleCount as int,
      roomCount: roomCount == const $CopyWithPlaceholder()
          ? _value.roomCount
          // ignore: cast_nullable_to_non_nullable
          : roomCount as int,
      candidateCount: candidateCount == const $CopyWithPlaceholder()
          ? _value.candidateCount
          // ignore: cast_nullable_to_non_nullable
          : candidateCount as int,
      resultCount: resultCount == const $CopyWithPlaceholder()
          ? _value.resultCount
          // ignore: cast_nullable_to_non_nullable
          : resultCount as int,
      pendingReviewCount: pendingReviewCount == const $CopyWithPlaceholder()
          ? _value.pendingReviewCount
          // ignore: cast_nullable_to_non_nullable
          : pendingReviewCount as int,
    );
  }
}

extension $ExamPeriodSummaryCopyWith on ExamPeriodSummary {
  /// Returns a callable class that can be used as follows: `instanceOfExamPeriodSummary.copyWith(...)` or like so:`instanceOfExamPeriodSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamPeriodSummaryCWProxy get copyWith =>
      _$ExamPeriodSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamPeriodSummary _$ExamPeriodSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamPeriodSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'period',
          'scheduleCount',
          'roomCount',
          'candidateCount',
          'resultCount',
          'pendingReviewCount',
        ],
      );
      final val = ExamPeriodSummary(
        period: $checkedConvert(
          'period',
          (v) => ExamPeriod.fromJson(v as Map<String, dynamic>),
        ),
        scheduleCount: $checkedConvert(
          'scheduleCount',
          (v) => (v as num).toInt(),
        ),
        roomCount: $checkedConvert('roomCount', (v) => (v as num).toInt()),
        candidateCount: $checkedConvert(
          'candidateCount',
          (v) => (v as num).toInt(),
        ),
        resultCount: $checkedConvert('resultCount', (v) => (v as num).toInt()),
        pendingReviewCount: $checkedConvert(
          'pendingReviewCount',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamPeriodSummaryToJson(ExamPeriodSummary instance) =>
    <String, dynamic>{
      'period': instance.period.toJson(),
      'scheduleCount': instance.scheduleCount,
      'roomCount': instance.roomCount,
      'candidateCount': instance.candidateCount,
      'resultCount': instance.resultCount,
      'pendingReviewCount': instance.pendingReviewCount,
    };
