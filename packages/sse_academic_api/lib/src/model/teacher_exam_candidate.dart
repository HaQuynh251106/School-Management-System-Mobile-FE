//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teacher_exam_candidate.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeacherExamCandidate {
  /// Returns a new [TeacherExamCandidate] instance.
  TeacherExamCandidate({
    required this.candidateId,

    required this.studentId,

    required this.studentName,

    required this.studentCode,

    this.candidateNo,

    this.seatNo,

    this.roomCode,

    this.resultId,

    this.score,

    this.note,

    this.resultStatus,

    this.version,
  });

  @JsonKey(name: r'candidateId', required: true, includeIfNull: false)
  final String candidateId;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: true, includeIfNull: false)
  final String studentName;

  @JsonKey(name: r'studentCode', required: true, includeIfNull: false)
  final String studentCode;

  @JsonKey(name: r'candidateNo', required: false, includeIfNull: false)
  final String? candidateNo;

  @JsonKey(name: r'seatNo', required: false, includeIfNull: false)
  final int? seatNo;

  @JsonKey(name: r'roomCode', required: false, includeIfNull: false)
  final String? roomCode;

  @JsonKey(name: r'resultId', required: false, includeIfNull: false)
  final String? resultId;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: false, includeIfNull: false)
  final num? score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'resultStatus', required: false, includeIfNull: false)
  final String? resultStatus;

  @JsonKey(name: r'version', required: false, includeIfNull: false)
  final int? version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherExamCandidate &&
          other.candidateId == candidateId &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.studentCode == studentCode &&
          other.candidateNo == candidateNo &&
          other.seatNo == seatNo &&
          other.roomCode == roomCode &&
          other.resultId == resultId &&
          other.score == score &&
          other.note == note &&
          other.resultStatus == resultStatus &&
          other.version == version;

  @override
  int get hashCode =>
      candidateId.hashCode +
      studentId.hashCode +
      studentName.hashCode +
      studentCode.hashCode +
      (candidateNo == null ? 0 : candidateNo.hashCode) +
      (seatNo == null ? 0 : seatNo.hashCode) +
      (roomCode == null ? 0 : roomCode.hashCode) +
      (resultId == null ? 0 : resultId.hashCode) +
      (score == null ? 0 : score.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (resultStatus == null ? 0 : resultStatus.hashCode) +
      (version == null ? 0 : version.hashCode);

  factory TeacherExamCandidate.fromJson(Map<String, dynamic> json) =>
      _$TeacherExamCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherExamCandidateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
