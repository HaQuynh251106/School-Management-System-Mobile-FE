//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ok_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OkResponse {
  /// Returns a new [OkResponse] instance.
  OkResponse({required this.ok});

  @JsonKey(name: r'ok', required: true, includeIfNull: false)
  final bool ok;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OkResponse && other.ok == ok;

  @override
  int get hashCode => ok.hashCode;

  factory OkResponse.fromJson(Map<String, dynamic> json) =>
      _$OkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OkResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
