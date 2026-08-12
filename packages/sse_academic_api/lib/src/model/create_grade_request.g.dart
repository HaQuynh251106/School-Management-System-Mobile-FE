// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_grade_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateGradeRequestCWProxy {
  CreateGradeRequest studentId(String studentId);

  CreateGradeRequest subjectId(String? subjectId);

  CreateGradeRequest semesterId(String semesterId);

  CreateGradeRequest category(String category);

  CreateGradeRequest assessmentIndex(int? assessmentIndex);

  CreateGradeRequest score(num score);

  CreateGradeRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGradeRequest call({
    String studentId,
    String? subjectId,
    String semesterId,
    String category,
    int? assessmentIndex,
    num score,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateGradeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateGradeRequest.copyWith.fieldName(...)`
class _$CreateGradeRequestCWProxyImpl implements _$CreateGradeRequestCWProxy {
  const _$CreateGradeRequestCWProxyImpl(this._value);

  final CreateGradeRequest _value;

  @override
  CreateGradeRequest studentId(String studentId) => this(studentId: studentId);

  @override
  CreateGradeRequest subjectId(String? subjectId) => this(subjectId: subjectId);

  @override
  CreateGradeRequest semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  CreateGradeRequest category(String category) => this(category: category);

  @override
  CreateGradeRequest assessmentIndex(int? assessmentIndex) =>
      this(assessmentIndex: assessmentIndex);

  @override
  CreateGradeRequest score(num score) => this(score: score);

  @override
  CreateGradeRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateGradeRequest call({
    Object? studentId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? assessmentIndex = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return CreateGradeRequest(
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String?,
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      assessmentIndex: assessmentIndex == const $CopyWithPlaceholder()
          ? _value.assessmentIndex
          // ignore: cast_nullable_to_non_nullable
          : assessmentIndex as int?,
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $CreateGradeRequestCopyWith on CreateGradeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateGradeRequest.copyWith(...)` or like so:`instanceOfCreateGradeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateGradeRequestCWProxy get copyWith =>
      _$CreateGradeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGradeRequest _$CreateGradeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateGradeRequest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['studentId', 'semesterId', 'category', 'score'],
      );
      final val = CreateGradeRequest(
        studentId: $checkedConvert('studentId', (v) => v as String),
        subjectId: $checkedConvert('subjectId', (v) => v as String?),
        semesterId: $checkedConvert('semesterId', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        assessmentIndex: $checkedConvert(
          'assessmentIndex',
          (v) => (v as num?)?.toInt(),
        ),
        score: $checkedConvert('score', (v) => v as num),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreateGradeRequestToJson(CreateGradeRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'subjectId': ?instance.subjectId,
      'semesterId': instance.semesterId,
      'category': instance.category,
      'assessmentIndex': ?instance.assessmentIndex,
      'score': instance.score,
      'note': ?instance.note,
    };
