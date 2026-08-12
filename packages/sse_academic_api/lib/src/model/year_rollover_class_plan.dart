//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'year_rollover_class_plan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class YearRolloverClassPlan {
  /// Returns a new [YearRolloverClassPlan] instance.
  YearRolloverClassPlan({
    required this.sourceClassId,

    required this.sourceClassCode,

    required this.targetClassCode,

    required this.targetGradeLevel,

    required this.type,

    required this.capacity,

    required this.studyShift,
  });

  @JsonKey(name: r'sourceClassId', required: true, includeIfNull: false)
  final String sourceClassId;

  @JsonKey(name: r'sourceClassCode', required: true, includeIfNull: false)
  final String sourceClassCode;

  @JsonKey(name: r'targetClassCode', required: true, includeIfNull: false)
  final String targetClassCode;

  @JsonKey(name: r'targetGradeLevel', required: true, includeIfNull: false)
  final String targetGradeLevel;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final String type;

  @JsonKey(name: r'capacity', required: true, includeIfNull: false)
  final int capacity;

  @JsonKey(name: r'studyShift', required: true, includeIfNull: false)
  final String studyShift;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearRolloverClassPlan &&
          other.sourceClassId == sourceClassId &&
          other.sourceClassCode == sourceClassCode &&
          other.targetClassCode == targetClassCode &&
          other.targetGradeLevel == targetGradeLevel &&
          other.type == type &&
          other.capacity == capacity &&
          other.studyShift == studyShift;

  @override
  int get hashCode =>
      sourceClassId.hashCode +
      sourceClassCode.hashCode +
      targetClassCode.hashCode +
      targetGradeLevel.hashCode +
      type.hashCode +
      capacity.hashCode +
      studyShift.hashCode;

  factory YearRolloverClassPlan.fromJson(Map<String, dynamic> json) =>
      _$YearRolloverClassPlanFromJson(json);

  Map<String, dynamic> toJson() => _$YearRolloverClassPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
