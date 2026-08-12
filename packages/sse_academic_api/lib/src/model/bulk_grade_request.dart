//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/grade_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bulk_grade_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BulkGradeRequest {
  /// Returns a new [BulkGradeRequest] instance.
  BulkGradeRequest({
    this.subjectId,

    this.classId,

    required this.semesterId,

    required this.category,

    this.assessmentIndex,

    this.reason,

    required this.entries,
  });

  @JsonKey(name: r'subjectId', required: false, includeIfNull: false)
  final String? subjectId;

  @JsonKey(name: r'classId', required: false, includeIfNull: false)
  final String? classId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  // minimum: 1
  @JsonKey(name: r'assessmentIndex', required: false, includeIfNull: false)
  final int? assessmentIndex;

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @JsonKey(name: r'entries', required: true, includeIfNull: false)
  final List<GradeEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkGradeRequest &&
          other.subjectId == subjectId &&
          other.classId == classId &&
          other.semesterId == semesterId &&
          other.category == category &&
          other.assessmentIndex == assessmentIndex &&
          other.reason == reason &&
          other.entries == entries;

  @override
  int get hashCode =>
      (subjectId == null ? 0 : subjectId.hashCode) +
      (classId == null ? 0 : classId.hashCode) +
      semesterId.hashCode +
      category.hashCode +
      (assessmentIndex == null ? 0 : assessmentIndex.hashCode) +
      (reason == null ? 0 : reason.hashCode) +
      entries.hashCode;

  factory BulkGradeRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkGradeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkGradeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
