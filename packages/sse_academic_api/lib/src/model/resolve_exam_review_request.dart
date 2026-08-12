//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resolve_exam_review_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResolveExamReviewRequest {
  /// Returns a new [ResolveExamReviewRequest] instance.
  ResolveExamReviewRequest({
    required this.status,

    required this.resolution,

    this.resolvedScore,
  });

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final ResolveExamReviewRequestStatusEnum status;

  @JsonKey(name: r'resolution', required: true, includeIfNull: false)
  final String resolution;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'resolvedScore', required: false, includeIfNull: false)
  final num? resolvedScore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolveExamReviewRequest &&
          other.status == status &&
          other.resolution == resolution &&
          other.resolvedScore == resolvedScore;

  @override
  int get hashCode =>
      status.hashCode +
      resolution.hashCode +
      (resolvedScore == null ? 0 : resolvedScore.hashCode);

  factory ResolveExamReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveExamReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResolveExamReviewRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ResolveExamReviewRequestStatusEnum {
  @JsonValue(r'APPROVED')
  APPROVED(r'APPROVED'),
  @JsonValue(r'REJECTED')
  REJECTED(r'REJECTED');

  const ResolveExamReviewRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
