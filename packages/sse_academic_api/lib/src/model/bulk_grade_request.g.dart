// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_grade_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BulkGradeRequestCWProxy {
  BulkGradeRequest subjectId(String? subjectId);

  BulkGradeRequest classId(String? classId);

  BulkGradeRequest semesterId(String semesterId);

  BulkGradeRequest category(String category);

  BulkGradeRequest assessmentIndex(int? assessmentIndex);

  BulkGradeRequest reason(String? reason);

  BulkGradeRequest entries(List<GradeEntry> entries);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BulkGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BulkGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BulkGradeRequest call({
    String? subjectId,
    String? classId,
    String semesterId,
    String category,
    int? assessmentIndex,
    String? reason,
    List<GradeEntry> entries,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBulkGradeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBulkGradeRequest.copyWith.fieldName(...)`
class _$BulkGradeRequestCWProxyImpl implements _$BulkGradeRequestCWProxy {
  const _$BulkGradeRequestCWProxyImpl(this._value);

  final BulkGradeRequest _value;

  @override
  BulkGradeRequest subjectId(String? subjectId) => this(subjectId: subjectId);

  @override
  BulkGradeRequest classId(String? classId) => this(classId: classId);

  @override
  BulkGradeRequest semesterId(String semesterId) =>
      this(semesterId: semesterId);

  @override
  BulkGradeRequest category(String category) => this(category: category);

  @override
  BulkGradeRequest assessmentIndex(int? assessmentIndex) =>
      this(assessmentIndex: assessmentIndex);

  @override
  BulkGradeRequest reason(String? reason) => this(reason: reason);

  @override
  BulkGradeRequest entries(List<GradeEntry> entries) => this(entries: entries);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BulkGradeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BulkGradeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BulkGradeRequest call({
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? classId = const $CopyWithPlaceholder(),
    Object? semesterId = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? assessmentIndex = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
  }) {
    return BulkGradeRequest(
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String?,
      classId: classId == const $CopyWithPlaceholder()
          ? _value.classId
          // ignore: cast_nullable_to_non_nullable
          : classId as String?,
      semesterId: semesterId == const $CopyWithPlaceholder()
          ? _value.semesterId
          // ignore: cast_nullable_to_non_nullable
          : semesterId as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String,
      assessmentIndex: assessmentIndex == const $CopyWithPlaceholder()
          ? _value.assessmentIndex
          // ignore: cast_nullable_to_non_nullable
          : assessmentIndex as int?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      entries: entries == const $CopyWithPlaceholder()
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<GradeEntry>,
    );
  }
}

extension $BulkGradeRequestCopyWith on BulkGradeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBulkGradeRequest.copyWith(...)` or like so:`instanceOfBulkGradeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BulkGradeRequestCWProxy get copyWith => _$BulkGradeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkGradeRequest _$BulkGradeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BulkGradeRequest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['semesterId', 'category', 'entries'],
      );
      final val = BulkGradeRequest(
        subjectId: $checkedConvert('subjectId', (v) => v as String?),
        classId: $checkedConvert('classId', (v) => v as String?),
        semesterId: $checkedConvert('semesterId', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        assessmentIndex: $checkedConvert(
          'assessmentIndex',
          (v) => (v as num?)?.toInt(),
        ),
        reason: $checkedConvert('reason', (v) => v as String?),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>)
              .map((e) => GradeEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BulkGradeRequestToJson(BulkGradeRequest instance) =>
    <String, dynamic>{
      'subjectId': ?instance.subjectId,
      'classId': ?instance.classId,
      'semesterId': instance.semesterId,
      'category': instance.category,
      'assessmentIndex': ?instance.assessmentIndex,
      'reason': ?instance.reason,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
