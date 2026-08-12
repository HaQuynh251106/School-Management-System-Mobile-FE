// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_band.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradeBandCWProxy {
  GradeBand band(String band);

  GradeBand count(int count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeBand(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeBand(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeBand call({String band, int count});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradeBand.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradeBand.copyWith.fieldName(...)`
class _$GradeBandCWProxyImpl implements _$GradeBandCWProxy {
  const _$GradeBandCWProxyImpl(this._value);

  final GradeBand _value;

  @override
  GradeBand band(String band) => this(band: band);

  @override
  GradeBand count(int count) => this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeBand(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeBand(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeBand call({
    Object? band = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return GradeBand(
      band: band == const $CopyWithPlaceholder()
          ? _value.band
          // ignore: cast_nullable_to_non_nullable
          : band as String,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
    );
  }
}

extension $GradeBandCopyWith on GradeBand {
  /// Returns a callable class that can be used as follows: `instanceOfGradeBand.copyWith(...)` or like so:`instanceOfGradeBand.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradeBandCWProxy get copyWith => _$GradeBandCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeBand _$GradeBandFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GradeBand', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['band', 'count']);
      final val = GradeBand(
        band: $checkedConvert('band', (v) => v as String),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$GradeBandToJson(GradeBand instance) => <String, dynamic>{
  'band': instance.band,
  'count': instance.count,
};
