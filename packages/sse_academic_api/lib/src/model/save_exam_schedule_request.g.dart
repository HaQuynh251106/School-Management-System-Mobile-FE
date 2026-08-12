// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_schedule_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamScheduleRequestCWProxy {
  SaveExamScheduleRequest id(String? id);

  SaveExamScheduleRequest subjectId(String subjectId);

  SaveExamScheduleRequest classIds(Set<String> classIds);

  SaveExamScheduleRequest examDate(DateTime examDate);

  SaveExamScheduleRequest startTime(String startTime);

  SaveExamScheduleRequest durationMinutes(int durationMinutes);

  SaveExamScheduleRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamScheduleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamScheduleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamScheduleRequest call({
    String? id,
    String subjectId,
    Set<String> classIds,
    DateTime examDate,
    String startTime,
    int durationMinutes,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamScheduleRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamScheduleRequest.copyWith.fieldName(...)`
class _$SaveExamScheduleRequestCWProxyImpl
    implements _$SaveExamScheduleRequestCWProxy {
  const _$SaveExamScheduleRequestCWProxyImpl(this._value);

  final SaveExamScheduleRequest _value;

  @override
  SaveExamScheduleRequest id(String? id) => this(id: id);

  @override
  SaveExamScheduleRequest subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  SaveExamScheduleRequest classIds(Set<String> classIds) =>
      this(classIds: classIds);

  @override
  SaveExamScheduleRequest examDate(DateTime examDate) =>
      this(examDate: examDate);

  @override
  SaveExamScheduleRequest startTime(String startTime) =>
      this(startTime: startTime);

  @override
  SaveExamScheduleRequest durationMinutes(int durationMinutes) =>
      this(durationMinutes: durationMinutes);

  @override
  SaveExamScheduleRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamScheduleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamScheduleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamScheduleRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? classIds = const $CopyWithPlaceholder(),
    Object? examDate = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? durationMinutes = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return SaveExamScheduleRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      classIds: classIds == const $CopyWithPlaceholder()
          ? _value.classIds
          // ignore: cast_nullable_to_non_nullable
          : classIds as Set<String>,
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
    );
  }
}

extension $SaveExamScheduleRequestCopyWith on SaveExamScheduleRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamScheduleRequest.copyWith(...)` or like so:`instanceOfSaveExamScheduleRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamScheduleRequestCWProxy get copyWith =>
      _$SaveExamScheduleRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamScheduleRequest _$SaveExamScheduleRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveExamScheduleRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'subjectId',
      'classIds',
      'examDate',
      'startTime',
      'durationMinutes',
    ],
  );
  final val = SaveExamScheduleRequest(
    id: $checkedConvert('id', (v) => v as String?),
    subjectId: $checkedConvert('subjectId', (v) => v as String),
    classIds: $checkedConvert(
      'classIds',
      (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
    ),
    examDate: $checkedConvert('examDate', (v) => DateTime.parse(v as String)),
    startTime: $checkedConvert('startTime', (v) => v as String),
    durationMinutes: $checkedConvert(
      'durationMinutes',
      (v) => (v as num).toInt(),
    ),
    notes: $checkedConvert('notes', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$SaveExamScheduleRequestToJson(
  SaveExamScheduleRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'subjectId': instance.subjectId,
  'classIds': instance.classIds.toList(),
  'examDate': instance.examDate.toIso8601String(),
  'startTime': instance.startTime,
  'durationMinutes': instance.durationMinutes,
  'notes': ?instance.notes,
};
