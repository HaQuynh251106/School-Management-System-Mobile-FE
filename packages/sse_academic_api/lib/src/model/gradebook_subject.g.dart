// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gradebook_subject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradebookSubjectCWProxy {
  GradebookSubject subjectId(String subjectId);

  GradebookSubject subjectName(String subjectName);

  GradebookSubject teacherName(String? teacherName);

  GradebookSubject editable(bool editable);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradebookSubject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradebookSubject(...).copyWith(id: 12, name: "My name")
  /// ````
  GradebookSubject call({
    String subjectId,
    String subjectName,
    String? teacherName,
    bool editable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradebookSubject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradebookSubject.copyWith.fieldName(...)`
class _$GradebookSubjectCWProxyImpl implements _$GradebookSubjectCWProxy {
  const _$GradebookSubjectCWProxyImpl(this._value);

  final GradebookSubject _value;

  @override
  GradebookSubject subjectId(String subjectId) => this(subjectId: subjectId);

  @override
  GradebookSubject subjectName(String subjectName) =>
      this(subjectName: subjectName);

  @override
  GradebookSubject teacherName(String? teacherName) =>
      this(teacherName: teacherName);

  @override
  GradebookSubject editable(bool editable) => this(editable: editable);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradebookSubject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradebookSubject(...).copyWith(id: 12, name: "My name")
  /// ````
  GradebookSubject call({
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? subjectName = const $CopyWithPlaceholder(),
    Object? teacherName = const $CopyWithPlaceholder(),
    Object? editable = const $CopyWithPlaceholder(),
  }) {
    return GradebookSubject(
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      subjectName: subjectName == const $CopyWithPlaceholder()
          ? _value.subjectName
          // ignore: cast_nullable_to_non_nullable
          : subjectName as String,
      teacherName: teacherName == const $CopyWithPlaceholder()
          ? _value.teacherName
          // ignore: cast_nullable_to_non_nullable
          : teacherName as String?,
      editable: editable == const $CopyWithPlaceholder()
          ? _value.editable
          // ignore: cast_nullable_to_non_nullable
          : editable as bool,
    );
  }
}

extension $GradebookSubjectCopyWith on GradebookSubject {
  /// Returns a callable class that can be used as follows: `instanceOfGradebookSubject.copyWith(...)` or like so:`instanceOfGradebookSubject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradebookSubjectCWProxy get copyWith => _$GradebookSubjectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradebookSubject _$GradebookSubjectFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GradebookSubject', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['subjectId', 'subjectName', 'editable'],
      );
      final val = GradebookSubject(
        subjectId: $checkedConvert('subjectId', (v) => v as String),
        subjectName: $checkedConvert('subjectName', (v) => v as String),
        teacherName: $checkedConvert('teacherName', (v) => v as String?),
        editable: $checkedConvert('editable', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$GradebookSubjectToJson(GradebookSubject instance) =>
    <String, dynamic>{
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'teacherName': ?instance.teacherName,
      'editable': instance.editable,
    };
