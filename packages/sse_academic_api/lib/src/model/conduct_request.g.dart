// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conduct_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConductRequestCWProxy {
  ConductRequest conductGrade(ConductRequestConductGradeEnum conductGrade);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConductRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConductRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConductRequest call({ConductRequestConductGradeEnum conductGrade});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConductRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConductRequest.copyWith.fieldName(...)`
class _$ConductRequestCWProxyImpl implements _$ConductRequestCWProxy {
  const _$ConductRequestCWProxyImpl(this._value);

  final ConductRequest _value;

  @override
  ConductRequest conductGrade(ConductRequestConductGradeEnum conductGrade) =>
      this(conductGrade: conductGrade);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConductRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConductRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConductRequest call({Object? conductGrade = const $CopyWithPlaceholder()}) {
    return ConductRequest(
      conductGrade: conductGrade == const $CopyWithPlaceholder()
          ? _value.conductGrade
          // ignore: cast_nullable_to_non_nullable
          : conductGrade as ConductRequestConductGradeEnum,
    );
  }
}

extension $ConductRequestCopyWith on ConductRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConductRequest.copyWith(...)` or like so:`instanceOfConductRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConductRequestCWProxy get copyWith => _$ConductRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConductRequest _$ConductRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConductRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['conductGrade']);
      final val = ConductRequest(
        conductGrade: $checkedConvert(
          'conductGrade',
          (v) => $enumDecode(_$ConductRequestConductGradeEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ConductRequestToJson(ConductRequest instance) =>
    <String, dynamic>{
      'conductGrade':
          _$ConductRequestConductGradeEnumEnumMap[instance.conductGrade]!,
    };

const _$ConductRequestConductGradeEnumEnumMap = {
  ConductRequestConductGradeEnum.GOOD: 'GOOD',
  ConductRequestConductGradeEnum.FAIR: 'FAIR',
  ConductRequestConductGradeEnum.AVERAGE: 'AVERAGE',
  ConductRequestConductGradeEnum.WEAK: 'WEAK',
};
