//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/exam_result_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_results_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamResultsRequest {
  /// Returns a new [SaveExamResultsRequest] instance.
  SaveExamResultsRequest({required this.scheduleId, required this.entries});

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'entries', required: true, includeIfNull: false)
  final List<ExamResultEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamResultsRequest &&
          other.scheduleId == scheduleId &&
          other.entries == entries;

  @override
  int get hashCode => scheduleId.hashCode + entries.hashCode;

  factory SaveExamResultsRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamResultsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamResultsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
