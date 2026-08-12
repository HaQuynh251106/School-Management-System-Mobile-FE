//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'viet_qr_confirmation_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VietQrConfirmationRequest {
  /// Returns a new [VietQrConfirmationRequest] instance.
  VietQrConfirmationRequest({this.bankTransactionRef});

  @JsonKey(name: r'bankTransactionRef', required: false, includeIfNull: false)
  final String? bankTransactionRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietQrConfirmationRequest &&
          other.bankTransactionRef == bankTransactionRef;

  @override
  int get hashCode =>
      (bankTransactionRef == null ? 0 : bankTransactionRef.hashCode);

  factory VietQrConfirmationRequest.fromJson(Map<String, dynamic> json) =>
      _$VietQrConfirmationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VietQrConfirmationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
