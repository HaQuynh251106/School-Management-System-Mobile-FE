//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade_change_log.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GradeChangeLog {
  /// Returns a new [GradeChangeLog] instance.
  GradeChangeLog({
    required this.id,

    required this.gradeId,

    required this.action,

    this.oldScore,

    this.newScore,

    this.oldNote,

    this.newNote,

    required this.changedBy,

    required this.reason,

    required this.changedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'gradeId', required: true, includeIfNull: false)
  final String gradeId;

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final GradeChangeLogActionEnum action;

  @JsonKey(name: r'oldScore', required: false, includeIfNull: false)
  final num? oldScore;

  @JsonKey(name: r'newScore', required: false, includeIfNull: false)
  final num? newScore;

  @JsonKey(name: r'oldNote', required: false, includeIfNull: false)
  final String? oldNote;

  @JsonKey(name: r'newNote', required: false, includeIfNull: false)
  final String? newNote;

  @JsonKey(name: r'changedBy', required: true, includeIfNull: false)
  final String changedBy;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'changedAt', required: true, includeIfNull: false)
  final DateTime changedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeChangeLog &&
          other.id == id &&
          other.gradeId == gradeId &&
          other.action == action &&
          other.oldScore == oldScore &&
          other.newScore == newScore &&
          other.oldNote == oldNote &&
          other.newNote == newNote &&
          other.changedBy == changedBy &&
          other.reason == reason &&
          other.changedAt == changedAt;

  @override
  int get hashCode =>
      id.hashCode +
      gradeId.hashCode +
      action.hashCode +
      (oldScore == null ? 0 : oldScore.hashCode) +
      (newScore == null ? 0 : newScore.hashCode) +
      (oldNote == null ? 0 : oldNote.hashCode) +
      (newNote == null ? 0 : newNote.hashCode) +
      changedBy.hashCode +
      reason.hashCode +
      changedAt.hashCode;

  factory GradeChangeLog.fromJson(Map<String, dynamic> json) =>
      _$GradeChangeLogFromJson(json);

  Map<String, dynamic> toJson() => _$GradeChangeLogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum GradeChangeLogActionEnum {
  @JsonValue(r'CREATE')
  CREATE(r'CREATE'),
  @JsonValue(r'UPDATE')
  UPDATE(r'UPDATE');

  const GradeChangeLogActionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
