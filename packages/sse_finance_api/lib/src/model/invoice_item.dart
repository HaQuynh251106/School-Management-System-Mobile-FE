//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvoiceItem {
  /// Returns a new [InvoiceItem] instance.
  InvoiceItem({
    required this.id,

    required this.invoiceId,

    required this.name,

    required this.amount,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'invoiceId', required: true, includeIfNull: false)
  final String invoiceId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  // minimum: 0
  @JsonKey(name: r'amount', required: true, includeIfNull: false)
  final int amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItem &&
          other.id == id &&
          other.invoiceId == invoiceId &&
          other.name == name &&
          other.amount == amount;

  @override
  int get hashCode =>
      id.hashCode + invoiceId.hashCode + name.hashCode + amount.hashCode;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
