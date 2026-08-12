// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradeEntryCWProxy {
  GradeEntry studentId(String studentId);

  GradeEntry score(num score);

  GradeEntry note(String? note);

  GradeEntry expectedVersion(int? expectedVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeEntry call({
    String studentId,
    num score,
    String? note,
    int? expectedVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradeEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradeEntry.copyWith.fieldName(...)`
class _$GradeEntryCWProxyImpl implements _$GradeEntryCWProxy {
  const _$GradeEntryCWProxyImpl(this._value);

  final GradeEntry _value;

  @override
  GradeEntry studentId(String studentId) => this(studentId: studentId);

  @override
  GradeEntry score(num score) => this(score: score);

  @override
  GradeEntry note(String? note) => this(note: note);

  @override
  GradeEntry expectedVersion(int? expectedVersion) =>
      this(expectedVersion: expectedVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeEntry call({
    Object? studentId = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? expectedVersion = const $CopyWithPlaceholder(),
  }) {
    return GradeEntry(
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num,
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

extension $GradeEntryCopyWith on GradeEntry {
  /// Returns a callable class that can be used as follows: `instanceOfGradeEntry.copyWith(...)` or like so:`instanceOfGradeEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradeEntryCWProxy get copyWith => _$GradeEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeEntry _$GradeEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GradeEntry', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['studentId', 'score']);
      final val = GradeEntry(
        studentId: $checkedConvert('studentId', (v) => v as String),
        score: $checkedConvert('score', (v) => v as num),
        note: $checkedConvert('note', (v) => v as String?),
        expectedVersion: $checkedConvert(
          'expectedVersion',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GradeEntryToJson(GradeEntry instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'score': instance.score,
      'note': ?instance.note,
      'expectedVersion': ?instance.expectedVersion,
    };
