//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_overview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportOverview {
  /// Returns a new [ReportOverview] instance.
  ReportOverview({
    required this.students,

    required this.teachers,

    required this.parents,

    required this.admins,

    required this.classes,

    required this.subjects,
  });

  @JsonKey(name: r'students', required: true, includeIfNull: false)
  final int students;

  @JsonKey(name: r'teachers', required: true, includeIfNull: false)
  final int teachers;

  @JsonKey(name: r'parents', required: true, includeIfNull: false)
  final int parents;

  @JsonKey(name: r'admins', required: true, includeIfNull: false)
  final int admins;

  @JsonKey(name: r'classes', required: true, includeIfNull: false)
  final int classes;

  @JsonKey(name: r'subjects', required: true, includeIfNull: false)
  final int subjects;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportOverview &&
          other.students == students &&
          other.teachers == teachers &&
          other.parents == parents &&
          other.admins == admins &&
          other.classes == classes &&
          other.subjects == subjects;

  @override
  int get hashCode =>
      students.hashCode +
      teachers.hashCode +
      parents.hashCode +
      admins.hashCode +
      classes.hashCode +
      subjects.hashCode;

  factory ReportOverview.fromJson(Map<String, dynamic> json) =>
      _$ReportOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReportOverviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
