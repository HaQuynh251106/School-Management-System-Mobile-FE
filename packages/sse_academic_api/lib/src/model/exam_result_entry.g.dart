// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_result_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamResultEntryCWProxy {
  ExamResultEntry studentId(String studentId);

  ExamResultEntry score(num? score);

  ExamResultEntry note(String? note);

  ExamResultEntry expectedVersion(int? expectedVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamResultEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamResultEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResultEntry call({
    String studentId,
    num? score,
    String? note,
    int? expectedVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamResultEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamResultEntry.copyWith.fieldName(...)`
class _$ExamResultEntryCWProxyImpl implements _$ExamResultEntryCWProxy {
  const _$ExamResultEntryCWProxyImpl(this._value);

  final ExamResultEntry _value;

  @override
  ExamResultEntry studentId(String studentId) => this(studentId: studentId);

  @override
  ExamResultEntry score(num? score) => this(score: score);

  @override
  ExamResultEntry note(String? note) => this(note: note);

  @override
  ExamResultEntry expectedVersion(int? expectedVersion) =>
      this(expectedVersion: expectedVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamResultEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamResultEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResultEntry call({
    Object? studentId = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? expectedVersion = const $CopyWithPlaceholder(),
  }) {
    return ExamResultEntry(
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      expectedVersion: expectedVersion == const $CopyWithPlaceholder()
          ? _value.expectedVersion
          // ignore: cast_nullable_to_non_nullable
          : expectedVersion as int?,
    );
  }
}

extension $ExamResultEntryCopyWith on ExamResultEntry {
  /// Returns a callable class that can be used as follows: `instanceOfExamResultEntry.copyWith(...)` or like so:`instanceOfExamResultEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamResultEntryCWProxy get copyWith => _$ExamResultEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamResultEntry _$ExamResultEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamResultEntry', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['studentId']);
      final val = ExamResultEntry(
        studentId: $checkedConvert('studentId', (v) => v as String),
        score: $checkedConvert('score', (v) => v as num?),
        note: $checkedConvert('note', (v) => v as String?),
        expectedVersion: $checkedConvert(
          'expectedVersion',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamResultEntryToJson(ExamResultEntry instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'score': ?instance.score,
      'note': ?instance.note,
      'expectedVersion': ?instance.expectedVersion,
    };
