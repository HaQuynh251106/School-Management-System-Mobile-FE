//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conduct_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConductRequest {
  /// Returns a new [ConductRequest] instance.
  ConductRequest({required this.conductGrade});

  @JsonKey(name: r'conductGrade', required: true, includeIfNull: false)
  final ConductRequestConductGradeEnum conductGrade;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConductRequest && other.conductGrade == conductGrade;

  @override
  int get hashCode => conductGrade.hashCode;

  factory ConductRequest.fromJson(Map<String, dynamic> json) =>
      _$ConductRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConductRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ConductRequestConductGradeEnum {
  @JsonValue(r'GOOD')
  GOOD(r'GOOD'),
  @JsonValue(r'FAIR')
  FAIR(r'FAIR'),
  @JsonValue(r'AVERAGE')
  AVERAGE(r'AVERAGE'),
  @JsonValue(r'WEAK')
  WEAK(r'WEAK');

  const ConductRequestConductGradeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
