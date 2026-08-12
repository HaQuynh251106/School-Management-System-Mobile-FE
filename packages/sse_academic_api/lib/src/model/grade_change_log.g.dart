// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_change_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradeChangeLogCWProxy {
  GradeChangeLog id(String id);

  GradeChangeLog gradeId(String gradeId);

  GradeChangeLog action(GradeChangeLogActionEnum action);

  GradeChangeLog oldScore(num? oldScore);

  GradeChangeLog newScore(num? newScore);

  GradeChangeLog oldNote(String? oldNote);

  GradeChangeLog newNote(String? newNote);

  GradeChangeLog changedBy(String changedBy);

  GradeChangeLog reason(String reason);

  GradeChangeLog changedAt(DateTime changedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeChangeLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeChangeLog(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeChangeLog call({
    String id,
    String gradeId,
    GradeChangeLogActionEnum action,
    num? oldScore,
    num? newScore,
    String? oldNote,
    String? newNote,
    String changedBy,
    String reason,
    DateTime changedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradeChangeLog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradeChangeLog.copyWith.fieldName(...)`
class _$GradeChangeLogCWProxyImpl implements _$GradeChangeLogCWProxy {
  const _$GradeChangeLogCWProxyImpl(this._value);

  final GradeChangeLog _value;

  @override
  GradeChangeLog id(String id) => this(id: id);

  @override
  GradeChangeLog gradeId(String gradeId) => this(gradeId: gradeId);

  @override
  GradeChangeLog action(GradeChangeLogActionEnum action) =>
      this(action: action);

  @override
  GradeChangeLog oldScore(num? oldScore) => this(oldScore: oldScore);

  @override
  GradeChangeLog newScore(num? newScore) => this(newScore: newScore);

  @override
  GradeChangeLog oldNote(String? oldNote) => this(oldNote: oldNote);

  @override
  GradeChangeLog newNote(String? newNote) => this(newNote: newNote);

  @override
  GradeChangeLog changedBy(String changedBy) => this(changedBy: changedBy);

  @override
  GradeChangeLog reason(String reason) => this(reason: reason);

  @override
  GradeChangeLog changedAt(DateTime changedAt) => this(changedAt: changedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradeChangeLog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradeChangeLog(...).copyWith(id: 12, name: "My name")
  /// ````
  GradeChangeLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? gradeId = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? oldScore = const $CopyWithPlaceholder(),
    Object? newScore = const $CopyWithPlaceholder(),
    Object? oldNote = const $CopyWithPlaceholder(),
    Object? newNote = const $CopyWithPlaceholder(),
    Object? changedBy = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? changedAt = const $CopyWithPlaceholder(),
  }) {
    return GradeChangeLog(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      gradeId: gradeId == const $CopyWithPlaceholder()
          ? _value.gradeId
          // ignore: cast_nullable_to_non_nullable
          : gradeId as String,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as GradeChangeLogActionEnum,
      oldScore: oldScore == const $CopyWithPlaceholder()
          ? _value.oldScore
          // ignore: cast_nullable_to_non_nullable
          : oldScore as num?,
      newScore: newScore == const $CopyWithPlaceholder()
          ? _value.newScore
          // ignore: cast_nullable_to_non_nullable
          : newScore as num?,
      oldNote: oldNote == const $CopyWithPlaceholder()
          ? _value.oldNote
          // ignore: cast_nullable_to_non_nullable
          : oldNote as String?,
      newNote: newNote == const $CopyWithPlaceholder()
          ? _value.newNote
          // ignore: cast_nullable_to_non_nullable
          : newNote as String?,
      changedBy: changedBy == const $CopyWithPlaceholder()
          ? _value.changedBy
          // ignore: cast_nullable_to_non_nullable
          : changedBy as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      changedAt: changedAt == const $CopyWithPlaceholder()
          ? _value.changedAt
          // ignore: cast_nullable_to_non_nullable
          : changedAt as DateTime,
    );
  }
}

extension $GradeChangeLogCopyWith on GradeChangeLog {
  /// Returns a callable class that can be used as follows: `instanceOfGradeChangeLog.copyWith(...)` or like so:`instanceOfGradeChangeLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradeChangeLogCWProxy get copyWith => _$GradeChangeLogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeChangeLog _$GradeChangeLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GradeChangeLog', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'gradeId',
          'action',
          'changedBy',
          'reason',
          'changedAt',
        ],
      );
      final val = GradeChangeLog(
        id: $checkedConvert('id', (v) => v as String),
        gradeId: $checkedConvert('gradeId', (v) => v as String),
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$GradeChangeLogActionEnumEnumMap, v),
        ),
        oldScore: $checkedConvert('oldScore', (v) => v as num?),
        newScore: $checkedConvert('newScore', (v) => v as num?),
        oldNote: $checkedConvert('oldNote', (v) => v as String?),
        newNote: $checkedConvert('newNote', (v) => v as String?),
        changedBy: $checkedConvert('changedBy', (v) => v as String),
        reason: $checkedConvert('reason', (v) => v as String),
        changedAt: $checkedConvert(
          'changedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GradeChangeLogToJson(GradeChangeLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gradeId': instance.gradeId,
      'action': _$GradeChangeLogActionEnumEnumMap[instance.action]!,
      'oldScore': ?instance.oldScore,
      'newScore': ?instance.newScore,
      'oldNote': ?instance.oldNote,
      'newNote': ?instance.newNote,
      'changedBy': instance.changedBy,
      'reason': instance.reason,
      'changedAt': instance.changedAt.toIso8601String(),
    };

const _$GradeChangeLogActionEnumEnumMap = {
  GradeChangeLogActionEnum.CREATE: 'CREATE',
  GradeChangeLogActionEnum.UPDATE: 'UPDATE',
};
