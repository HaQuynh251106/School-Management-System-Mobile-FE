//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GradeEntry {
  /// Returns a new [GradeEntry] instance.
  GradeEntry({
    required this.studentId,

    required this.score,

    this.note,

    this.expectedVersion,
  });

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: true, includeIfNull: false)
  final num score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  // minimum: 0
  @JsonKey(name: r'expectedVersion', required: false, includeIfNull: false)
  final int? expectedVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeEntry &&
          other.studentId == studentId &&
          other.score == score &&
          other.note == note &&
          other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
      studentId.hashCode +
      score.hashCode +
      (note == null ? 0 : note.hashCode) +
      (expectedVersion == null ? 0 : expectedVersion.hashCode);

  factory GradeEntry.fromJson(Map<String, dynamic> json) =>
      _$GradeEntryFromJson(json);

  Map<String, dynamic> toJson() => _$GradeEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
