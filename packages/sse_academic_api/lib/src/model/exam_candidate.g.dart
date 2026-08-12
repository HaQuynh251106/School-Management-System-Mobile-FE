// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_candidate.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamCandidateCWProxy {
  ExamCandidate id(String id);

  ExamCandidate examPeriodId(String examPeriodId);

  ExamCandidate scheduleId(String scheduleId);

  ExamCandidate examRoomId(String examRoomId);

  ExamCandidate studentId(String studentId);

  ExamCandidate studentName(String studentName);

  ExamCandidate studentCode(String? studentCode);

  ExamCandidate classId(String classId);

  ExamCandidate classCode(String classCode);

  ExamCandidate candidateNo(String candidateNo);

  ExamCandidate seatNo(int seatNo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamCandidate call({
    String id,
    String examPeriodId,
    String scheduleId,
    String examRoomId,
    String studentId,
    String studentName,
    String? studentCode,
    String classId,
    String classCode,
    String candidateNo,
    int seatNo,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamCandidate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamCandidate.copyWith.fieldName(...)`
class _$ExamCandidateCWProxyImpl implements _$ExamCandidateCWProxy {
  const _$ExamCandidateCWProxyImpl(this._value);

  final ExamCandidate _value;

  @override
  ExamCandidate id(String id) => this(id: id);

  @override
  ExamCandidate examPeriodId(String examPeriodId) =>
      this(examPeriodId: examPeriodId);

  @override
  ExamCandidate scheduleId(String scheduleId) => this(scheduleId: scheduleId);

  @override
  ExamCandidate examRoomId(String examRoomId) => this(examRoomId: examRoomId);

  @override
  ExamCandidate studentId(String studentId) => this(studentId: studentId);

  @override
  ExamCandidate studentName(String studentName) =>
      this(studentName: studentName);

  @override
  ExamCandidate studentCode(String? studentCode) =>
      this(studentCode: studentCode);

  @override
  ExamCandidate classId(String classId) => this(classId: classId);

  @override
  ExamCandidate classCode(String classCode) => this(classCode: classCode);

  @override
  ExamCandidate candidateNo(String candidateNo) =>
      this(candidateNo: candidateNo);

  @override
  ExamCandidate seatNo(int seatNo) => this(seatNo: seatNo);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamCandidate call({
    Object? id = const $CopyWithPlaceholder(),
    Object? examPeriodId = const $CopyWithPlaceholder(),
    Object? scheduleId = const $CopyWithPlaceholder(),
    Object? examRoomId = const $CopyWithPlaceholder(),
    Object? studentId = const $CopyWithPlaceholder(),
    Object? studentName = const $CopyWithPlaceholder(),
    Object? studentCode = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? candidateNo = const $CopyWithPlaceholder(),
    Object? seatNo = const $CopyWithPlaceholder(),
  }) {
    return ExamCandidate(
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
      examRoomId: examRoomId == const $CopyWithPlaceholder()
          ? _value.examRoomId
          // ignore: cast_nullable_to_non_nullable
          : examRoomId as String,
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      studentName: studentName == const $CopyWithPlaceholder()
          ? _value.studentName
          // ignore: cast_nullable_to_non_nullable
          : studentName as String,
      studentCode: studentCode == const $CopyWithPlaceholder()
          ? _value.studentCode
          // ignore: cast_nullable_to_non_nullable
          : studentCode as String?,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      classCode: classCode == const $CopyWithPlaceholder()
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String,
      candidateNo: candidateNo == const $CopyWithPlaceholder()
          ? _value.candidateNo
          // ignore: cast_nullable_to_non_nullable
          : candidateNo as String,
      seatNo: seatNo == const $CopyWithPlaceholder()
          ? _value.seatNo
          // ignore: cast_nullable_to_non_nullable
          : seatNo as int,
    );
  }
}

extension $ExamCandidateCopyWith on ExamCandidate {
  /// Returns a callable class that can be used as follows: `instanceOfExamCandidate.copyWith(...)` or like so:`instanceOfExamCandidate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamCandidateCWProxy get copyWith => _$ExamCandidateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamCandidate _$ExamCandidateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamCandidate', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'examPeriodId',
          'scheduleId',
          'examRoomId',
          'studentId',
          'studentName',
          'classId',
          'classCode',
          'candidateNo',
          'seatNo',
        ],
      );
      final val = ExamCandidate(
        id: $checkedConvert('id', (v) => v as String),
        examPeriodId: $checkedConvert('examPeriodId', (v) => v as String),
        scheduleId: $checkedConvert('scheduleId', (v) => v as String),
        examRoomId: $checkedConvert('examRoomId', (v) => v as String),
        studentId: $checkedConvert('studentId', (v) => v as String),
        studentName: $checkedConvert('studentName', (v) => v as String),
        studentCode: $checkedConvert('studentCode', (v) => v as String?),
        classId: $checkedConvert('classId', (v) => v as String),
        classCode: $checkedConvert('classCode', (v) => v as String),
        candidateNo: $checkedConvert('candidateNo', (v) => v as String),
        seatNo: $checkedConvert('seatNo', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ExamCandidateToJson(ExamCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examPeriodId': instance.examPeriodId,
      'scheduleId': instance.scheduleId,
      'examRoomId': instance.examRoomId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'studentCode': ?instance.studentCode,
      'classId': instance.classId,
      'classCode': instance.classCode,
      'candidateNo': instance.candidateNo,
      'seatNo': instance.seatNo,
    };
