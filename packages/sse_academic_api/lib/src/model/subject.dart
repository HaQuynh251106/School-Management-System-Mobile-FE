//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Subject {
  /// Returns a new [Subject] instance.
  Subject({
    required this.id,

    required this.code,

    required this.name,

    required this.coefficient,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'coefficient', required: true, includeIfNull: false)
  final num coefficient;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.coefficient == coefficient;

  @override
  int get hashCode =>
      id.hashCode + code.hashCode + name.hashCode + coefficient.hashCode;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
