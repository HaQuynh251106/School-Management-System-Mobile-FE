//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_widget_error.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardWidgetError {
  /// Returns a new [DashboardWidgetError] instance.
  DashboardWidgetError({
    required this.widget,

    required this.code,

    required this.message,

    required this.retryable,
  });

  @JsonKey(name: r'widget', required: true, includeIfNull: false)
  final String widget;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'retryable', required: true, includeIfNull: false)
  final bool retryable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardWidgetError &&
          other.widget == widget &&
          other.code == code &&
          other.message == message &&
          other.retryable == retryable;

  @override
  int get hashCode =>
      widget.hashCode + code.hashCode + message.hashCode + retryable.hashCode;

  factory DashboardWidgetError.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetErrorFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardWidgetErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
