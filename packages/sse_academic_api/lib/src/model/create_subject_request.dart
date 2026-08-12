//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_subject_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateSubjectRequest {
  /// Returns a new [CreateSubjectRequest] instance.
  CreateSubjectRequest({
    this.id,

    required this.code,

    required this.name,

    this.coefficient,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'coefficient', required: false, includeIfNull: false)
  final num? coefficient;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSubjectRequest &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.coefficient == coefficient;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      code.hashCode +
      name.hashCode +
      (coefficient == null ? 0 : coefficient.hashCode);

  factory CreateSubjectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubjectRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubjectRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
