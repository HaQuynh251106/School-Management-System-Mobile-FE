//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_period.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamPeriod {
  /// Returns a new [ExamPeriod] instance.
  ExamPeriod({
    required this.id,

    required this.code,

    required this.name,

    required this.academicYearId,

    required this.semesterId,

    this.gradeLevel,

    required this.startDate,

    required this.endDate,

    required this.status,

    required this.scoreEntryLocked,

    required this.schedulePublished,

    required this.scheduleRevision,

    this.schedulePublishedAt,

    this.schedulePublishedBy,

    this.confirmedAt,

    this.confirmedBy,

    required this.createdAt,

    this.createdBy,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'academicYearId', required: true, includeIfNull: false)
  final String academicYearId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'gradeLevel', required: false, includeIfNull: false)
  final String? gradeLevel;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'scoreEntryLocked', required: true, includeIfNull: false)
  final bool scoreEntryLocked;

  @JsonKey(name: r'schedulePublished', required: true, includeIfNull: false)
  final bool schedulePublished;

  @JsonKey(name: r'scheduleRevision', required: true, includeIfNull: false)
  final int scheduleRevision;

  @JsonKey(name: r'schedulePublishedAt', required: false, includeIfNull: false)
  final DateTime? schedulePublishedAt;

  @JsonKey(name: r'schedulePublishedBy', required: false, includeIfNull: false)
  final String? schedulePublishedBy;

  @JsonKey(name: r'confirmedAt', required: false, includeIfNull: false)
  final DateTime? confirmedAt;

  @JsonKey(name: r'confirmedBy', required: false, includeIfNull: false)
  final String? confirmedBy;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'createdBy', required: false, includeIfNull: false)
  final String? createdBy;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamPeriod &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.academicYearId == academicYearId &&
          other.semesterId == semesterId &&
          other.gradeLevel == gradeLevel &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.status == status &&
          other.scoreEntryLocked == scoreEntryLocked &&
          other.schedulePublished == schedulePublished &&
          other.scheduleRevision == scheduleRevision &&
          other.schedulePublishedAt == schedulePublishedAt &&
          other.schedulePublishedBy == schedulePublishedBy &&
          other.confirmedAt == confirmedAt &&
          other.confirmedBy == confirmedBy &&
          other.createdAt == createdAt &&
          other.createdBy == createdBy &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      name.hashCode +
      academicYearId.hashCode +
      semesterId.hashCode +
      (gradeLevel == null ? 0 : gradeLevel.hashCode) +
      startDate.hashCode +
      endDate.hashCode +
      status.hashCode +
      scoreEntryLocked.hashCode +
      schedulePublished.hashCode +
      scheduleRevision.hashCode +
      (schedulePublishedAt == null ? 0 : schedulePublishedAt.hashCode) +
      (schedulePublishedBy == null ? 0 : schedulePublishedBy.hashCode) +
      (confirmedAt == null ? 0 : confirmedAt.hashCode) +
      (confirmedBy == null ? 0 : confirmedBy.hashCode) +
      createdAt.hashCode +
      (createdBy == null ? 0 : createdBy.hashCode) +
      updatedAt.hashCode;

  factory ExamPeriod.fromJson(Map<String, dynamic> json) =>
      _$ExamPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPeriodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
