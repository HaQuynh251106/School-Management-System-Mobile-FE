//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_agenda_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamAgendaItem {
  /// Returns a new [ExamAgendaItem] instance.
  ExamAgendaItem({
    required this.id,

    required this.taskType,

    required this.taskLabel,

    required this.examPeriodId,

    required this.examPeriodName,

    required this.scheduleRevision,

    required this.scheduleId,

    required this.subjectId,

    required this.subjectName,

    required this.examDate,

    required this.startTime,

    required this.durationMinutes,

    this.notes,

    this.roomCode,

    this.studentId,

    this.studentName,

    this.classCode,

    this.candidateNo,

    this.seatNo,

    this.proctorNames,

    required this.status,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'taskType', required: true, includeIfNull: false)
  final String taskType;

  @JsonKey(name: r'taskLabel', required: true, includeIfNull: false)
  final String taskLabel;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'examPeriodName', required: true, includeIfNull: false)
  final String examPeriodName;

  @JsonKey(name: r'scheduleRevision', required: true, includeIfNull: false)
  final int scheduleRevision;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'examDate', required: true, includeIfNull: false)
  final DateTime examDate;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  @JsonKey(name: r'durationMinutes', required: true, includeIfNull: false)
  final int durationMinutes;

  @JsonKey(name: r'notes', required: false, includeIfNull: false)
  final String? notes;

  @JsonKey(name: r'roomCode', required: false, includeIfNull: false)
  final String? roomCode;

  @JsonKey(name: r'studentId', required: false, includeIfNull: false)
  final String? studentId;

  @JsonKey(name: r'studentName', required: false, includeIfNull: false)
  final String? studentName;

  @JsonKey(name: r'classCode', required: false, includeIfNull: false)
  final String? classCode;

  @JsonKey(name: r'candidateNo', required: false, includeIfNull: false)
  final String? candidateNo;

  @JsonKey(name: r'seatNo', required: false, includeIfNull: false)
  final int? seatNo;

  @JsonKey(name: r'proctorNames', required: false, includeIfNull: false)
  final String? proctorNames;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamAgendaItem &&
          other.id == id &&
          other.taskType == taskType &&
          other.taskLabel == taskLabel &&
          other.examPeriodId == examPeriodId &&
          other.examPeriodName == examPeriodName &&
          other.scheduleRevision == scheduleRevision &&
          other.scheduleId == scheduleId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.examDate == examDate &&
          other.startTime == startTime &&
          other.durationMinutes == durationMinutes &&
          other.notes == notes &&
          other.roomCode == roomCode &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.classCode == classCode &&
          other.candidateNo == candidateNo &&
          other.seatNo == seatNo &&
          other.proctorNames == proctorNames &&
          other.status == status;

  @override
  int get hashCode =>
      id.hashCode +
      taskType.hashCode +
      taskLabel.hashCode +
      examPeriodId.hashCode +
      examPeriodName.hashCode +
      scheduleRevision.hashCode +
      scheduleId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      examDate.hashCode +
      startTime.hashCode +
      durationMinutes.hashCode +
      (notes == null ? 0 : notes.hashCode) +
      (roomCode == null ? 0 : roomCode.hashCode) +
      (studentId == null ? 0 : studentId.hashCode) +
      (studentName == null ? 0 : studentName.hashCode) +
      (classCode == null ? 0 : classCode.hashCode) +
      (candidateNo == null ? 0 : candidateNo.hashCode) +
      (seatNo == null ? 0 : seatNo.hashCode) +
      (proctorNames == null ? 0 : proctorNames.hashCode) +
      status.hashCode;

  factory ExamAgendaItem.fromJson(Map<String, dynamic> json) =>
      _$ExamAgendaItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExamAgendaItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
