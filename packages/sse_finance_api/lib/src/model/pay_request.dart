//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pay_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PayRequest {
  /// Returns a new [PayRequest] instance.
  PayRequest({
    required this.invoiceId,

    this.method = PayRequestMethodEnum.VIETQR,
  });

  @JsonKey(name: r'invoiceId', required: true, includeIfNull: false)
  final String invoiceId;

  @JsonKey(name: r'method', required: false, includeIfNull: false)
  final PayRequestMethodEnum? method;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayRequest &&
          other.invoiceId == invoiceId &&
          other.method == method;

  @override
  int get hashCode =>
      invoiceId.hashCode + (method == null ? 0 : method.hashCode);

  factory PayRequest.fromJson(Map<String, dynamic> json) =>
      _$PayRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PayRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PayRequestMethodEnum {
  @JsonValue(r'VIETQR')
  VIETQR(r'VIETQR');

  const PayRequestMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
