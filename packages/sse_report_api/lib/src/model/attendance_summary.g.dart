// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttendanceSummaryCWProxy {
  AttendanceSummary present(int present);

  AttendanceSummary late_(int late_);

  AttendanceSummary absentExcused(int absentExcused);

  AttendanceSummary absentUnexcused(int absentUnexcused);

  AttendanceSummary total(int total);

  AttendanceSummary attendanceRate(num attendanceRate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceSummary call({
    int present,
    int late_,
    int absentExcused,
    int absentUnexcused,
    int total,
    num attendanceRate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttendanceSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttendanceSummary.copyWith.fieldName(...)`
class _$AttendanceSummaryCWProxyImpl implements _$AttendanceSummaryCWProxy {
  const _$AttendanceSummaryCWProxyImpl(this._value);

  final AttendanceSummary _value;

  @override
  AttendanceSummary present(int present) => this(present: present);

  @override
  AttendanceSummary late_(int late_) => this(late_: late_);

  @override
  AttendanceSummary absentExcused(int absentExcused) =>
      this(absentExcused: absentExcused);

  @override
  AttendanceSummary absentUnexcused(int absentUnexcused) =>
      this(absentUnexcused: absentUnexcused);

  @override
  AttendanceSummary total(int total) => this(total: total);

  @override
  AttendanceSummary attendanceRate(num attendanceRate) =>
      this(attendanceRate: attendanceRate);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceSummary call({
    Object? present = const $CopyWithPlaceholder(),
    Object? late_ = const $CopyWithPlaceholder(),
    Object? absentExcused = const $CopyWithPlaceholder(),
    Object? absentUnexcused = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? attendanceRate = const $CopyWithPlaceholder(),
  }) {
    return AttendanceSummary(
      present: present == const $CopyWithPlaceholder()
          ? _value.present
          // ignore: cast_nullable_to_non_nullable
          : present as int,
      late_: late_ == const $CopyWithPlaceholder()
          ? _value.late_
          // ignore: cast_nullable_to_non_nullable
          : late_ as int,
      absentExcused: absentExcused == const $CopyWithPlaceholder()
          ? _value.absentExcused
          // ignore: cast_nullable_to_non_nullable
          : absentExcused as int,
      absentUnexcused: absentUnexcused == const $CopyWithPlaceholder()
          ? _value.absentUnexcused
          // ignore: cast_nullable_to_non_nullable
          : absentUnexcused as int,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      attendanceRate: attendanceRate == const $CopyWithPlaceholder()
          ? _value.attendanceRate
          // ignore: cast_nullable_to_non_nullable
          : attendanceRate as num,
    );
  }
}

extension $AttendanceSummaryCopyWith on AttendanceSummary {
  /// Returns a callable class that can be used as follows: `instanceOfAttendanceSummary.copyWith(...)` or like so:`instanceOfAttendanceSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttendanceSummaryCWProxy get copyWith =>
      _$AttendanceSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AttendanceSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'present',
          'late',
          'absentExcused',
          'absentUnexcused',
          'total',
          'attendanceRate',
        ],
      );
      final val = AttendanceSummary(
        present: $checkedConvert('present', (v) => (v as num).toInt()),
        late_: $checkedConvert('late', (v) => (v as num).toInt()),
        absentExcused: $checkedConvert(
          'absentExcused',
          (v) => (v as num).toInt(),
        ),
        absentUnexcused: $checkedConvert(
          'absentUnexcused',
          (v) => (v as num).toInt(),
        ),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        attendanceRate: $checkedConvert('attendanceRate', (v) => v as num),
      );
      return val;
    }, fieldKeyMap: const {'late_': 'late'});

Map<String, dynamic> _$AttendanceSummaryToJson(AttendanceSummary instance) =>
    <String, dynamic>{
      'present': instance.present,
      'late': instance.late_,
      'absentExcused': instance.absentExcused,
      'absentUnexcused': instance.absentUnexcused,
      'total': instance.total,
      'attendanceRate': instance.attendanceRate,
    };
