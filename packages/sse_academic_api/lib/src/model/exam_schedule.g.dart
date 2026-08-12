// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_schedule.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamScheduleCWProxy {
  ExamSchedule id(String id);

  ExamSchedule examPeriodId(String examPeriodId);

  ExamSchedule subjectId(String subjectId);

  ExamSchedule subjectName(String subjectName);

  ExamSchedule examDate(DateTime examDate);

  ExamSchedule startTime(String startTime);

  ExamSchedule durationMinutes(int durationMinutes);

  ExamSchedule notes(String? notes);

  ExamSchedule classIds(Set<String> classIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamSchedule(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamSchedule(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamSchedule call({
    String id,
    String examPeriodId,
    String subjectId,
    String subjectName,
    DateTime examDate,
    String startTime,
    int durationMinutes,
    String? notes,
    Set<String> classIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamSchedule.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamSchedule.copyWith.fieldName(...)`
class _$ExamScheduleCWProxyImpl implements _$ExamScheduleCWProxy {
  const _$ExamScheduleCWProxyImpl(this._value);

  final ExamSchedule _value;

  @override
  ExamSchedule id(String id) => this(id: id);

  @override
  ExamSchedule examPeriodId(String examPeriodId) =>
      this(examPeriodId: examPeriodId);

  @override
  ExamSchedule subjectId(String subjectId) => this(subjectId: subjectId);

  @override
  ExamSchedule subjectName(String subjectName) =>
      this(subjectName: subjectName);

  @override
  ExamSchedule examDate(DateTime examDate) => this(examDate: examDate);

  @override
  ExamSchedule startTime(String startTime) => this(startTime: startTime);

  @override
  ExamSchedule durationMinutes(int durationMinutes) =>
      this(durationMinutes: durationMinutes);

  @override
  ExamSchedule notes(String? notes) => this(notes: notes);

  @override
  ExamSchedule classIds(Set<String> classIds) => this(classIds: classIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamSchedule(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamSchedule(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamSchedule call({
    Object? id = const $CopyWithPlaceholder(),
    Object? examPeriodId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? examDate = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? durationMinutes = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? classIds = const $CopyWithPlaceholder(),
  }) {
    return ExamSchedule(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      examPeriodId: examPeriodId == const $CopyWithPlaceholder()
          ? _value.examPeriodId
          // ignore: cast_nullable_to_non_nullable
          : examPeriodId as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String,
      examDate: examDate == const $CopyWithPlaceholder()
          ? _value.examDate
          // ignore: cast_nullable_to_non_nullable
          : examDate as DateTime,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as String,
      durationMinutes: durationMinutes == const $CopyWithPlaceholder()
          ? _value.durationMinutes
          // ignore: cast_nullable_to_non_nullable
          : durationMinutes as int,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      classIds: classIds == const $CopyWithPlaceholder()
          ? _value.classIds
          // ignore: cast_nullable_to_non_nullable
          : classIds as Set<String>,
    );
  }
}

extension $ExamScheduleCopyWith on ExamSchedule {
  /// Returns a callable class that can be used as follows: `instanceOfExamSchedule.copyWith(...)` or like so:`instanceOfExamSchedule.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamScheduleCWProxy get copyWith => _$ExamScheduleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamSchedule _$ExamScheduleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamSchedule', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'examPeriodId',
          'subjectId',
          'subjectName',
          'examDate',
          'startTime',
          'durationMinutes',
          'classIds',
        ],
      );
      final val = ExamSchedule(
        id: $checkedConvert('id', (v) => v as String),
        examPeriodId: $checkedConvert('examPeriodId', (v) => v as String),
        subjectId: $checkedConvert('subjectId', (v) => v as String),
        subjectName: $checkedConvert('subjectName', (v) => v as String),
        examDate: $checkedConvert(
          'examDate',
          (v) => DateTime.parse(v as String),
        ),
        startTime: $checkedConvert('startTime', (v) => v as String),
        durationMinutes: $checkedConvert(
          'durationMinutes',
          (v) => (v as num).toInt(),
        ),
        notes: $checkedConvert('notes', (v) => v as String?),
        classIds: $checkedConvert(
          'classIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamScheduleToJson(ExamSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examPeriodId': instance.examPeriodId,
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'examDate': instance.examDate.toIso8601String(),
      'startTime': instance.startTime,
      'durationMinutes': instance.durationMinutes,
      'notes': ?instance.notes,
      'classIds': instance.classIds.toList(),
    };
