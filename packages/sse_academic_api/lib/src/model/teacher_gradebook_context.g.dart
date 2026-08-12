// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_gradebook_context.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TeacherGradebookContextCWProxy {
  TeacherGradebookContext classId(String classId);

  TeacherGradebookContext semesterId(String semesterId);

  TeacherGradebookContext subjectId(String subjectId);

  TeacherGradebookContext subjectName(String subjectName);

  TeacherGradebookContext homeroomTeacher(bool homeroomTeacher);

  TeacherGradebookContext canEdit(bool canEdit);

  TeacherGradebookContext subjects(List<GradebookSubject> subjects);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TeacherGradebookContext(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TeacherGradebookContext(...).copyWith(id: 12, name: "My name")
  /// ````
  TeacherGradebookContext call({
    String classId,
    String semesterId,
    String subjectId,
    String subjectName,
    bool homeroomTeacher,
    bool canEdit,
    List<GradebookSubject> subjects,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTeacherGradebookContext.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTeacherGradebookContext.copyWith.fieldName(...)`
class _$TeacherGradebookContextCWProxyImpl
    implements _$TeacherGradebookContextCWProxy {
  const _$TeacherGradebookContextCWProxyImpl(this._value);

  final TeacherGradebookContext _value;

  @override
  TeacherGradebookContext classId(String classId) => this(classId: classId);

  @override
  TeacherGradebookContext semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  TeacherGradebookContext subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  TeacherGradebookContext subjectName(String subjectName) =>
      this(subjectName: subjectName);

  @override
  TeacherGradebookContext homeroomTeacher(bool homeroomTeacher) =>
      this(homeroomTeacher: homeroomTeacher);

  @override
  TeacherGradebookContext canEdit(bool canEdit) => this(canEdit: canEdit);

  @override
  TeacherGradebookContext subjects(List<GradebookSubject> subjects) =>
      this(subjects: subjects);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TeacherGradebookContext(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TeacherGradebookContext(...).copyWith(id: 12, name: "My name")
  /// ````
  TeacherGradebookContext call({
    Object? classId = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? homeroomTeacher = const $CopyWithPlaceholder(),
    Object? canEdit = const $CopyWithPlaceholder(),
    Object? subjects = const $CopyWithPlaceholder(),
  }) {
    return TeacherGradebookContext(
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String,
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String,
      homeroomTeacher: homeroomTeacher == const $CopyWithPlaceholder()
          ? _value.homeroomTeacher
          // ignore: cast_nullable_to_non_nullable
          : homeroomTeacher as bool,
      canEdit: canEdit == const $CopyWithPlaceholder()
          ? _value.canEdit
          // ignore: cast_nullable_to_non_nullable
          : canEdit as bool,
      subjects: subjects == const $CopyWithPlaceholder()
          ? _value.subjects
          // ignore: cast_nullable_to_non_nullable
          : subjects as List<GradebookSubject>,
    );
  }
}

extension $TeacherGradebookContextCopyWith on TeacherGradebookContext {
  /// Returns a callable class that can be used as follows: `instanceOfTeacherGradebookContext.copyWith(...)` or like so:`instanceOfTeacherGradebookContext.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TeacherGradebookContextCWProxy get copyWith =>
      _$TeacherGradebookContextCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherGradebookContext _$TeacherGradebookContextFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TeacherGradebookContext', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'classId',
      'semesterId',
      'subjectId',
      'subjectName',
      'homeroomTeacher',
      'canEdit',
      'subjects',
    ],
  );
  final val = TeacherGradebookContext(
    classId: $checkedConvert('classId', (v) => v as String),
    semesterId: $checkedConvert('semesterId', (v) => v as String),
    subjectId: $checkedConvert('subjectId', (v) => v as String),
    subjectName: $checkedConvert('subjectName', (v) => v as String),
    homeroomTeacher: $checkedConvert('homeroomTeacher', (v) => v as bool),
    canEdit: $checkedConvert('canEdit', (v) => v as bool),
    subjects: $checkedConvert(
      'subjects',
      (v) => (v as List<dynamic>)
          .map((e) => GradebookSubject.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$TeacherGradebookContextToJson(
  TeacherGradebookContext instance,
) => <String, dynamic>{
  'classId': instance.classId,
  'semesterId': instance.semesterId,
  'subjectId': instance.subjectId,
  'subjectName': instance.subjectName,
  'homeroomTeacher': instance.homeroomTeacher,
  'canEdit': instance.canEdit,
  'subjects': instance.subjects.map((e) => e.toJson()).toList(),
};
