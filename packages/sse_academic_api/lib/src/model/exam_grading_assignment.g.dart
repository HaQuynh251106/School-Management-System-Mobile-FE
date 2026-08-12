// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_grading_assignment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamGradingAssignmentCWProxy {
  ExamGradingAssignment id(String id);

  ExamGradingAssignment examPeriodId(String examPeriodId);

  ExamGradingAssignment scheduleId(String scheduleId);

  ExamGradingAssignment classId(String classId);

  ExamGradingAssignment classCode(String classCode);

  ExamGradingAssignment subjectId(String subjectId);

  ExamGradingAssignment subjectName(String subjectName);

  ExamGradingAssignment teacherId(String teacherId);

  ExamGradingAssignment teacherName(String teacherName);

  ExamGradingAssignment assignedAt(DateTime assignedAt);

  ExamGradingAssignment assignedBy(String? assignedBy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamGradingAssignment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamGradingAssignment(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamGradingAssignment call({
    String id,
    String examPeriodId,
    String scheduleId,
    String classId,
    String classCode,
    String subjectId,
    String subjectName,
    String teacherId,
    String teacherName,
    DateTime assignedAt,
    String? assignedBy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamGradingAssignment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamGradingAssignment.copyWith.fieldName(...)`
class _$ExamGradingAssignmentCWProxyImpl
    implements _$ExamGradingAssignmentCWProxy {
  const _$ExamGradingAssignmentCWProxyImpl(this._value);

  final ExamGradingAssignment _value;

  @override
  ExamGradingAssignment id(String id) => this(id: id);

  @override
  ExamGradingAssignment examPeriodId(String examPeriodId) =>
      this(examPeriodId: examPeriodId);

  @override
  ExamGradingAssignment scheduleId(String scheduleId) =>
      this(scheduleId: scheduleId);

  @override
  ExamGradingAssignment classId(String classId) => this(classId: classId);

  @override
  ExamGradingAssignment classCode(String classCode) =>
      this(classCode: classCode);

  @override
  ExamGradingAssignment subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  ExamGradingAssignment subjectName(String subjectName) =>
      this(subjectName: subjectName);

  @override
  ExamGradingAssignment teacherId(String teacherId) =>
      this(teacherId: teacherId);

  @override
  ExamGradingAssignment teacherName(String teacherName) =>
      this(teacherName: teacherName);

  @override
  ExamGradingAssignment assignedAt(DateTime assignedAt) =>
      this(assignedAt: assignedAt);

  @override
  ExamGradingAssignment assignedBy(String? assignedBy) =>
      this(assignedBy: assignedBy);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamGradingAssignment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamGradingAssignment(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamGradingAssignment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? examPeriodId = const $CopyWithPlaceholder(),
    Object? scheduleId = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? teacherId = const $CopyWithPlaceholder(),
    Object? teacherName = const $CopyWithPlaceholder(),
    Object? assignedAt = const $CopyWithPlaceholder(),
    Object? assignedBy = const $CopyWithPlaceholder(),
  }) {
    return ExamGradingAssignment(
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
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      classCode: classCode == const $CopyWithPlaceholder()
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String,
      teacherId: teacherId == const $CopyWithPlaceholder()
          ? _value.teacherId
          // ignore: cast_nullable_to_non_nullable
          : teacherId as String,
      teacherName: teacherName == const $CopyWithPlaceholder()
          ? _value.teacherName
          // ignore: cast_nullable_to_non_nullable
          : teacherName as String,
      assignedAt: assignedAt == const $CopyWithPlaceholder()
          ? _value.assignedAt
          // ignore: cast_nullable_to_non_nullable
          : assignedAt as DateTime,
      assignedBy: assignedBy == const $CopyWithPlaceholder()
          ? _value.assignedBy
          // ignore: cast_nullable_to_non_nullable
          : assignedBy as String?,
    );
  }
}

extension $ExamGradingAssignmentCopyWith on ExamGradingAssignment {
  /// Returns a callable class that can be used as follows: `instanceOfExamGradingAssignment.copyWith(...)` or like so:`instanceOfExamGradingAssignment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamGradingAssignmentCWProxy get copyWith =>
      _$ExamGradingAssignmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamGradingAssignment _$ExamGradingAssignmentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExamGradingAssignment', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'examPeriodId',
      'scheduleId',
      'classId',
      'classCode',
      'subjectId',
      'subjectName',
      'teacherId',
      'teacherName',
      'assignedAt',
    ],
  );
  final val = ExamGradingAssignment(
    id: $checkedConvert('id', (v) => v as String),
    examPeriodId: $checkedConvert('examPeriodId', (v) => v as String),
    scheduleId: $checkedConvert('scheduleId', (v) => v as String),
    classId: $checkedConvert('classId', (v) => v as String),
    classCode: $checkedConvert('classCode', (v) => v as String),
    subjectId: $checkedConvert('subjectId', (v) => v as String),
    subjectName: $checkedConvert('subjectName', (v) => v as String),
    teacherId: $checkedConvert('teacherId', (v) => v as String),
    teacherName: $checkedConvert('teacherName', (v) => v as String),
    assignedAt: $checkedConvert(
      'assignedAt',
      (v) => DateTime.parse(v as String),
    ),
    assignedBy: $checkedConvert('assignedBy', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ExamGradingAssignmentToJson(
  ExamGradingAssignment instance,
) => <String, dynamic>{
  'id': instance.id,
  'examPeriodId': instance.examPeriodId,
  'scheduleId': instance.scheduleId,
  'classId': instance.classId,
  'classCode': instance.classCode,
  'subjectId': instance.subjectId,
  'subjectName': instance.subjectName,
  'teacherId': instance.teacherId,
  'teacherName': instance.teacherName,
  'assignedAt': instance.assignedAt.toIso8601String(),
  'assignedBy': ?instance.assignedBy,
};
