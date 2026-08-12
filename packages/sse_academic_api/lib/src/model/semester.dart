//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'semester.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Semester {
  /// Returns a new [Semester] instance.
  Semester({
    required this.id,

    required this.academicYearId,

    required this.code,

    required this.name,

    required this.sequence,

    required this.startDate,

    required this.endDate,

    required this.status,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'academicYearId', required: true, includeIfNull: false)
  final String academicYearId;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'sequence', required: true, includeIfNull: false)
  final int sequence;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester &&
          other.id == id &&
          other.academicYearId == academicYearId &&
          other.code == code &&
          other.name == name &&
          other.sequence == sequence &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.status == status;

  @override
  int get hashCode =>
      id.hashCode +
      academicYearId.hashCode +
      code.hashCode +
      name.hashCode +
      sequence.hashCode +
      startDate.hashCode +
      endDate.hashCode +
      status.hashCode;

  factory Semester.fromJson(Map<String, dynamic> json) =>
      _$SemesterFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
