// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SemesterCWProxy {
  Semester id(String id);

  Semester academicYearId(String academicYearId);

  Semester code(String code);

  Semester name(String name);

  Semester sequence(int sequence);

  Semester startDate(DateTime startDate);

  Semester endDate(DateTime endDate);

  Semester status(String status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Semester(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Semester(...).copyWith(id: 12, name: "My name")
  /// ````
  Semester call({
    String id,
    String academicYearId,
    String code,
    String name,
    int sequence,
    DateTime startDate,
    DateTime endDate,
    String status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSemester.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSemester.copyWith.fieldName(...)`
class _$SemesterCWProxyImpl implements _$SemesterCWProxy {
  const _$SemesterCWProxyImpl(this._value);

  final Semester _value;

  @override
  Semester id(String id) => this(id: id);

  @override
  Semester academicYearId(String academicYearId) =>
      this(academicYearId: academicYearId);

  @override
  Semester code(String code) => this(code: code);

  @override
  Semester name(String name) => this(name: name);

  @override
  Semester sequence(int sequence) => this(sequence: sequence);

  @override
  Semester startDate(DateTime startDate) => this(startDate: startDate);

  @override
  Semester endDate(DateTime endDate) => this(endDate: endDate);

  @override
  Semester status(String status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Semester(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Semester(...).copyWith(id: 12, name: "My name")
  /// ````
  Semester call({
    Object? id = const $CopyWithPlaceholder(),
    Object? academicYearId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? sequence = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return Semester(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      academicYearId: academicYearId == const $CopyWithPlaceholder()
          ? _value.academicYearId
          // ignore: cast_nullable_to_non_nullable
          : academicYearId as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sequence: sequence == const $CopyWithPlaceholder()
          ? _value.sequence
          // ignore: cast_nullable_to_non_nullable
          : sequence as int,
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

extension $SemesterCopyWith on Semester {
  /// Returns a callable class that can be used as follows: `instanceOfSemester.copyWith(...)` or like so:`instanceOfSemester.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SemesterCWProxy get copyWith => _$SemesterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Semester _$SemesterFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Semester', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'academicYearId',
          'code',
          'name',
          'sequence',
          'startDate',
          'endDate',
          'status',
        ],
      );
      final val = Semester(
        id: $checkedConvert('id', (v) => v as String),
        academicYearId: $checkedConvert('academicYearId', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        sequence: $checkedConvert('sequence', (v) => (v as num).toInt()),
        startDate: $checkedConvert(
          'startDate',
          (v) => DateTime.parse(v as String),
        ),
        endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SemesterToJson(Semester instance) => <String, dynamic>{
  'id': instance.id,
  'academicYearId': instance.academicYearId,
  'code': instance.code,
  'name': instance.name,
  'sequence': instance.sequence,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'status': instance.status,
};
