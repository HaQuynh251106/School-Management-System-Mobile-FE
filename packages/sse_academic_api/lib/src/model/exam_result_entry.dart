//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_result_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamResultEntry {
  /// Returns a new [ExamResultEntry] instance.
  ExamResultEntry({
    required this.studentId,

    this.score,

    this.note,

    this.expectedVersion,
  });

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: false, includeIfNull: false)
  final num? score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'expectedVersion', required: false, includeIfNull: false)
  final int? expectedVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResultEntry &&
          other.studentId == studentId &&
          other.score == score &&
          other.note == note &&
          other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
      studentId.hashCode +
      (score == null ? 0 : score.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (expectedVersion == null ? 0 : expectedVersion.hashCode);

  factory ExamResultEntry.fromJson(Map<String, dynamic> json) =>
      _$ExamResultEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResultEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
