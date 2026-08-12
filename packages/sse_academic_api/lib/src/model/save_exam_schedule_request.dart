//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_schedule_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamScheduleRequest {
  /// Returns a new [SaveExamScheduleRequest] instance.
  SaveExamScheduleRequest({
    this.id,

    required this.subjectId,

    required this.classIds,

    required this.examDate,

    required this.startTime,

    required this.durationMinutes,

    this.notes,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'classIds', required: true, includeIfNull: false)
  final Set<String> classIds;

  @JsonKey(name: r'examDate', required: true, includeIfNull: false)
  final DateTime examDate;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  // minimum: 15
  // maximum: 480
  @JsonKey(name: r'durationMinutes', required: true, includeIfNull: false)
  final int durationMinutes;

  @JsonKey(name: r'notes', required: false, includeIfNull: false)
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamScheduleRequest &&
          other.id == id &&
          other.subjectId == subjectId &&
          other.classIds == classIds &&
          other.examDate == examDate &&
          other.startTime == startTime &&
          other.durationMinutes == durationMinutes &&
          other.notes == notes;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      subjectId.hashCode +
      classIds.hashCode +
      examDate.hashCode +
      startTime.hashCode +
      durationMinutes.hashCode +
      (notes == null ? 0 : notes.hashCode);

  factory SaveExamScheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamScheduleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamScheduleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
