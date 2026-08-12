// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_overview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReportOverviewCWProxy {
  ReportOverview students(int students);

  ReportOverview teachers(int teachers);

  ReportOverview parents(int parents);

  ReportOverview admins(int admins);

  ReportOverview classes(int classes);

  ReportOverview subjects(int subjects);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReportOverview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReportOverview(...).copyWith(id: 12, name: "My name")
  /// ````
  ReportOverview call({
    int students,
    int teachers,
    int parents,
    int admins,
    int classes,
    int subjects,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReportOverview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReportOverview.copyWith.fieldName(...)`
class _$ReportOverviewCWProxyImpl implements _$ReportOverviewCWProxy {
  const _$ReportOverviewCWProxyImpl(this._value);

  final ReportOverview _value;

  @override
  ReportOverview students(int students) => this(students: students);

  @override
  ReportOverview teachers(int teachers) => this(teachers: teachers);

  @override
  ReportOverview parents(int parents) => this(parents: parents);

  @override
  ReportOverview admins(int admins) => this(admins: admins);

  @override
  ReportOverview classes(int classes) => this(classes: classes);

  @override
  ReportOverview subjects(int subjects) => this(subjects: subjects);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReportOverview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReportOverview(...).copyWith(id: 12, name: "My name")
  /// ````
  ReportOverview call({
    Object? students = const $CopyWithPlaceholder(),
    Object? teachers = const $CopyWithPlaceholder(),
    Object? parents = const $CopyWithPlaceholder(),
    Object? admins = const $CopyWithPlaceholder(),
    Object? classes = const $CopyWithPlaceholder(),
    Object? subjects = const $CopyWithPlaceholder(),
  }) {
    return ReportOverview(
      students: students == const $CopyWithPlaceholder()
          ? _value.students
          // ignore: cast_nullable_to_non_nullable
          : students as int,
      teachers: teachers == const $CopyWithPlaceholder()
          ? _value.teachers
          // ignore: cast_nullable_to_non_nullable
          : teachers as int,
      parents: parents == const $CopyWithPlaceholder()
          ? _value.parents
          // ignore: cast_nullable_to_non_nullable
          : parents as int,
      admins: admins == const $CopyWithPlaceholder()
          ? _value.admins
          // ignore: cast_nullable_to_non_nullable
          : admins as int,
      classes: classes == const $CopyWithPlaceholder()
          ? _value.classes
          // ignore: cast_nullable_to_non_nullable
          : classes as int,
      subjects: subjects == const $CopyWithPlaceholder()
          ? _value.subjects
          // ignore: cast_nullable_to_non_nullable
          : subjects as int,
    );
  }
}

extension $ReportOverviewCopyWith on ReportOverview {
  /// Returns a callable class that can be used as follows: `instanceOfReportOverview.copyWith(...)` or like so:`instanceOfReportOverview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReportOverviewCWProxy get copyWith => _$ReportOverviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportOverview _$ReportOverviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReportOverview', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'students',
          'teachers',
          'parents',
          'admins',
          'classes',
          'subjects',
        ],
      );
      final val = ReportOverview(
        students: $checkedConvert('students', (v) => (v as num).toInt()),
        teachers: $checkedConvert('teachers', (v) => (v as num).toInt()),
        parents: $checkedConvert('parents', (v) => (v as num).toInt()),
        admins: $checkedConvert('admins', (v) => (v as num).toInt()),
        classes: $checkedConvert('classes', (v) => (v as num).toInt()),
        subjects: $checkedConvert('subjects', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ReportOverviewToJson(ReportOverview instance) =>
    <String, dynamic>{
      'students': instance.students,
      'teachers': instance.teachers,
      'parents': instance.parents,
      'admins': instance.admins,
      'classes': instance.classes,
      'subjects': instance.subjects,
    };
