// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamResultCWProxy {
  ExamResult id(String id);

  ExamResult examPeriodId(String examPeriodId);

  ExamResult scheduleId(String scheduleId);

  ExamResult studentId(String studentId);

  ExamResult subjectId(String subjectId);

  ExamResult score(num? score);

  ExamResult status(String status);

  ExamResult note(String? note);

  ExamResult recordedAt(DateTime? recordedAt);

  ExamResult recordedBy(String? recordedBy);

  ExamResult updatedAt(DateTime? updatedAt);

  ExamResult updatedBy(String? updatedBy);

  ExamResult version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResult call({
    String id,
    String examPeriodId,
    String scheduleId,
    String studentId,
    String subjectId,
    num? score,
    String status,
    String? note,
    DateTime? recordedAt,
    String? recordedBy,
    DateTime? updatedAt,
    String? updatedBy,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamResult.copyWith.fieldName(...)`
class _$ExamResultCWProxyImpl implements _$ExamResultCWProxy {
  const _$ExamResultCWProxyImpl(this._value);

  final ExamResult _value;

  @override
  ExamResult id(String id) => this(id: id);

  @override
  ExamResult examPeriodId(String examPeriodId) =>
      this(examPeriodId: examPeriodId);

  @override
  ExamResult scheduleId(String scheduleId) => this(scheduleId: scheduleId);

  @override
  ExamResult studentId(String studentId) => this(studentId: studentId);

  @override
  ExamResult subjectId(String subjectId) => this(subjectId: subjectId);

  @override
  ExamResult score(num? score) => this(score: score);

  @override
  ExamResult status(String status) => this(status: status);

  @override
  ExamResult note(String? note) => this(note: note);

  @override
  ExamResult recordedAt(DateTime? recordedAt) => this(recordedAt: recordedAt);

  @override
  ExamResult recordedBy(String? recordedBy) => this(recordedBy: recordedBy);

  @override
  ExamResult updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  ExamResult updatedBy(String? updatedBy) => this(updatedBy: updatedBy);

  @override
  ExamResult version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResult call({
    Object? id = const $CopyWithPlaceholder(),
    Object? examPeriodId = const $CopyWithPlaceholder(),
    Object? scheduleId = const $CopyWithPlaceholder(),
    Object? studentId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? recordedAt = const $CopyWithPlaceholder(),
    Object? recordedBy = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? updatedBy = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return ExamResult(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      examPeriodId: examPeriodId == const $CopyWithPlaceholder()
          ? _value.examPeriodId
          // ignore: cast_nullable_to_non_nullable
          : examPeriodId as String,
      scheduleId: scheduleId == const $CopyWithPlaceholder()
          ? _value.scheduleId
          // ignore: cast_nullable_to_non_nullable
          : scheduleId as String,
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      recordedAt: recordedAt == const $CopyWithPlaceholder()
          ? _value.recordedAt
          // ignore: cast_nullable_to_non_nullable
          : recordedAt as DateTime?,
      recordedBy: recordedBy == const $CopyWithPlaceholder()
          ? _value.recordedBy
          // ignore: cast_nullable_to_non_nullable
          : recordedBy as String?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      updatedBy: updatedBy == const $CopyWithPlaceholder()
          ? _value.updatedBy
          // ignore: cast_nullable_to_non_nullable
          : updatedBy as String?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $ExamResultCopyWith on ExamResult {
  /// Returns a callable class that can be used as follows: `instanceOfExamResult.copyWith(...)` or like so:`instanceOfExamResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamResultCWProxy get copyWith => _$ExamResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamResult _$ExamResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamResult', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'examPeriodId',
          'scheduleId',
          'studentId',
          'subjectId',
          'status',
          'version',
        ],
      );
      final val = ExamResult(
        id: $checkedConvert('id', (v) => v as String),
        examPeriodId: $checkedConvert('examPeriodId', (v) => v as String),
        scheduleId: $checkedConvert('scheduleId', (v) => v as String),
        studentId: $checkedConvert('studentId', (v) => v as String),
        subjectId: $checkedConvert('subjectId', (v) => v as String),
        score: $checkedConvert('score', (v) => v as num?),
        status: $checkedConvert('status', (v) => v as String),
        note: $checkedConvert('note', (v) => v as String?),
        recordedAt: $checkedConvert(
          'recordedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        recordedBy: $checkedConvert('recordedBy', (v) => v as String?),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        updatedBy: $checkedConvert('updatedBy', (v) => v as String?),
        version: $checkedConvert('version', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ExamResultToJson(ExamResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examPeriodId': instance.examPeriodId,
      'scheduleId': instance.scheduleId,
      'studentId': instance.studentId,
      'subjectId': instance.subjectId,
      'score': ?instance.score,
      'status': instance.status,
      'note': ?instance.note,
      'recordedAt': ?instance.recordedAt?.toIso8601String(),
      'recordedBy': ?instance.recordedBy,
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
      'updatedBy': ?instance.updatedBy,
      'version': instance.version,
    };
