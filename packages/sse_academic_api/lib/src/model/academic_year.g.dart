// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_year.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AcademicYearCWProxy {
  AcademicYear id(String id);

  AcademicYear code(String code);

  AcademicYear name(String name);

  AcademicYear startDate(DateTime startDate);

  AcademicYear endDate(DateTime endDate);

  AcademicYear status(String status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcademicYear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcademicYear(...).copyWith(id: 12, name: "My name")
  /// ````
  AcademicYear call({
    String id,
    String code,
    String name,
    DateTime startDate,
    DateTime endDate,
    String status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAcademicYear.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAcademicYear.copyWith.fieldName(...)`
class _$AcademicYearCWProxyImpl implements _$AcademicYearCWProxy {
  const _$AcademicYearCWProxyImpl(this._value);

  final AcademicYear _value;

  @override
  AcademicYear id(String id) => this(id: id);

  @override
  AcademicYear code(String code) => this(code: code);

  @override
  AcademicYear name(String name) => this(name: name);

  @override
  AcademicYear startDate(DateTime startDate) => this(startDate: startDate);

  @override
  AcademicYear endDate(DateTime endDate) => this(endDate: endDate);

  @override
  AcademicYear status(String status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AcademicYear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AcademicYear(...).copyWith(id: 12, name: "My name")
  /// ````
  AcademicYear call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return AcademicYear(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      endDate: endDate == const $CopyWithPlaceholder()
          ? _value.endDate
          // ignore: cast_nullable_to_non_nullable
          : endDate as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
    );
  }
}

extension $AcademicYearCopyWith on AcademicYear {
  /// Returns a callable class that can be used as follows: `instanceOfAcademicYear.copyWith(...)` or like so:`instanceOfAcademicYear.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AcademicYearCWProxy get copyWith => _$AcademicYearCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicYear _$AcademicYearFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AcademicYear', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'code',
          'name',
          'startDate',
          'endDate',
          'status',
        ],
      );
      final val = AcademicYear(
        id: $checkedConvert('id', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        startDate: $checkedConvert(
          'startDate',
          (v) => DateTime.parse(v as String),
        ),
        endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AcademicYearToJson(AcademicYear instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
    };
