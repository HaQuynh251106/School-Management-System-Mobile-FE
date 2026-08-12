// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_grade_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateGradeRequestCWProxy {
  UpdateGradeRequest score(num score);

  UpdateGradeRequest note(String? note);

  UpdateGradeRequest reason(String reason);

  UpdateGradeRequest expectedVersion(int? expectedVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateGradeRequest call({
    num score,
    String? note,
    String reason,
    int? expectedVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateGradeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateGradeRequest.copyWith.fieldName(...)`
class _$UpdateGradeRequestCWProxyImpl implements _$UpdateGradeRequestCWProxy {
  const _$UpdateGradeRequestCWProxyImpl(this._value);

  final UpdateGradeRequest _value;

  @override
  UpdateGradeRequest score(num score) => this(score: score);

  @override
  UpdateGradeRequest note(String? note) => this(note: note);

  @override
  UpdateGradeRequest reason(String reason) => this(reason: reason);

  @override
  UpdateGradeRequest expectedVersion(int? expectedVersion) =>
      this(expectedVersion: expectedVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateGradeRequest call({
    Object? score = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? expectedVersion = const $CopyWithPlaceholder(),
  }) {
    return UpdateGradeRequest(
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      expectedVersion: expectedVersion == const $CopyWithPlaceholder()
          ? _value.expectedVersion
          // ignore: cast_nullable_to_non_nullable
          : expectedVersion as int?,
    );
  }
}

extension $UpdateGradeRequestCopyWith on UpdateGradeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateGradeRequest.copyWith(...)` or like so:`instanceOfUpdateGradeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateGradeRequestCWProxy get copyWith =>
      _$UpdateGradeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateGradeRequest _$UpdateGradeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateGradeRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['score', 'reason']);
      final val = UpdateGradeRequest(
        score: $checkedConvert('score', (v) => v as num),
        note: $checkedConvert('note', (v) => v as String?),
        reason: $checkedConvert('reason', (v) => v as String),
        expectedVersion: $checkedConvert(
          'expectedVersion',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateGradeRequestToJson(UpdateGradeRequest instance) =>
    <String, dynamic>{
      'score': instance.score,
      'note': ?instance.note,
      'reason': instance.reason,
      'expectedVersion': ?instance.expectedVersion,
    };
