//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'academic_year.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcademicYear {
  /// Returns a new [AcademicYear] instance.
  AcademicYear({
    required this.id,

    required this.code,

    required this.name,

    required this.startDate,

    required this.endDate,

    required this.status,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicYear &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.status == status;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      name.hashCode +
      startDate.hashCode +
      endDate.hashCode +
      status.hashCode;

  factory AcademicYear.fromJson(Map<String, dynamic> json) =>
      _$AcademicYearFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicYearToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
