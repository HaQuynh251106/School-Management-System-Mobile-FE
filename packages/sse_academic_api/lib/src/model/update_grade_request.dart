//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_grade_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateGradeRequest {
  /// Returns a new [UpdateGradeRequest] instance.
  UpdateGradeRequest({
    required this.score,

    this.note,

    required this.reason,

    this.expectedVersion,
  });

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: true, includeIfNull: false)
  final num score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  // minimum: 0
  @JsonKey(name: r'expectedVersion', required: false, includeIfNull: false)
  final int? expectedVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateGradeRequest &&
          other.score == score &&
          other.note == note &&
          other.reason == reason &&
          other.expectedVersion == expectedVersion;

  @override
  int get hashCode =>
      score.hashCode +
      (note == null ? 0 : note.hashCode) +
      reason.hashCode +
      (expectedVersion == null ? 0 : expectedVersion.hashCode);

  factory UpdateGradeRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGradeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateGradeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
