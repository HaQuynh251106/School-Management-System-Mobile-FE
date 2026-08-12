//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_category.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamCategory {
  /// Returns a new [ExamCategory] instance.
  ExamCategory({
    required this.id,

    required this.code,

    required this.name,

    required this.weight,

    required this.requiredCount,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'weight', required: true, includeIfNull: false)
  final num weight;

  // minimum: 1
  // maximum: 10
  @JsonKey(name: r'requiredCount', required: true, includeIfNull: false)
  final int requiredCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamCategory &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.weight == weight &&
          other.requiredCount == requiredCount;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      name.hashCode +
      weight.hashCode +
      requiredCount.hashCode;

  factory ExamCategory.fromJson(Map<String, dynamic> json) =>
      _$ExamCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamCategoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
