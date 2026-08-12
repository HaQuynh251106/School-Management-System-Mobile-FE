//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_category_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamCategoryRequest {
  /// Returns a new [SaveExamCategoryRequest] instance.
  SaveExamCategoryRequest({
    this.id,

    required this.code,

    required this.name,

    this.weight,

    this.requiredCount,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'weight', required: false, includeIfNull: false)
  final num? weight;

  // minimum: 1
  // maximum: 10
  @JsonKey(name: r'requiredCount', required: false, includeIfNull: false)
  final int? requiredCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamCategoryRequest &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.weight == weight &&
          other.requiredCount == requiredCount;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      code.hashCode +
      name.hashCode +
      (weight == null ? 0 : weight.hashCode) +
      (requiredCount == null ? 0 : requiredCount.hashCode);

  factory SaveExamCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamCategoryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
