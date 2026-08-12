//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade_band.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GradeBand {
  /// Returns a new [GradeBand] instance.
  GradeBand({required this.band, required this.count});

  @JsonKey(name: r'band', required: true, includeIfNull: false)
  final String band;

  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeBand && other.band == band && other.count == count;

  @override
  int get hashCode => band.hashCode + count.hashCode;

  factory GradeBand.fromJson(Map<String, dynamic> json) =>
      _$GradeBandFromJson(json);

  Map<String, dynamic> toJson() => _$GradeBandToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
