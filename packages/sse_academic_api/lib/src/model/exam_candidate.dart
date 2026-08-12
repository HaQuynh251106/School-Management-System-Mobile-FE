//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamCandidate {
  /// Returns a new [ExamCandidate] instance.
  ExamCandidate({
    required this.id,

    required this.examPeriodId,

    required this.scheduleId,

    required this.examRoomId,

    required this.studentId,

    required this.studentName,

    this.studentCode,

    required this.classId,

    required this.classCode,

    required this.candidateNo,

    required this.seatNo,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'examRoomId', required: true, includeIfNull: false)
  final String examRoomId;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: true, includeIfNull: false)
  final String studentName;

  @JsonKey(name: r'studentCode', required: false, includeIfNull: false)
  final String? studentCode;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: true, includeIfNull: false)
  final String classCode;

  @JsonKey(name: r'candidateNo', required: true, includeIfNull: false)
  final String candidateNo;

  // minimum: 1
  @JsonKey(name: r'seatNo', required: true, includeIfNull: false)
  final int seatNo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamCandidate &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.scheduleId == scheduleId &&
          other.examRoomId == examRoomId &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.studentCode == studentCode &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.candidateNo == candidateNo &&
          other.seatNo == seatNo;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      scheduleId.hashCode +
      examRoomId.hashCode +
      studentId.hashCode +
      studentName.hashCode +
      (studentCode == null ? 0 : studentCode.hashCode) +
      classId.hashCode +
      classCode.hashCode +
      candidateNo.hashCode +
      seatNo.hashCode;

  factory ExamCandidate.fromJson(Map<String, dynamic> json) =>
      _$ExamCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$ExamCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
