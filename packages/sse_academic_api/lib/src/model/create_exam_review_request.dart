//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_exam_review_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateExamReviewRequest {
  /// Returns a new [CreateExamReviewRequest] instance.
  CreateExamReviewRequest({required this.resultId, required this.reason});

  @JsonKey(name: r'resultId', required: true, includeIfNull: false)
  final String resultId;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateExamReviewRequest &&
          other.resultId == resultId &&
          other.reason == reason;

  @override
  int get hashCode => resultId.hashCode + reason.hashCode;

  factory CreateExamReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExamReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExamReviewRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
