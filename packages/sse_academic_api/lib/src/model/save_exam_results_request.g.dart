// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_results_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamResultsRequestCWProxy {
  SaveExamResultsRequest scheduleId(String scheduleId);

  SaveExamResultsRequest entries(List<ExamResultEntry> entries);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamResultsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamResultsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamResultsRequest call({
    String scheduleId,
    List<ExamResultEntry> entries,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamResultsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamResultsRequest.copyWith.fieldName(...)`
class _$SaveExamResultsRequestCWProxyImpl
    implements _$SaveExamResultsRequestCWProxy {
  const _$SaveExamResultsRequestCWProxyImpl(this._value);

  final SaveExamResultsRequest _value;

  @override
  SaveExamResultsRequest scheduleId(String scheduleId) =>
      this(scheduleId: scheduleId);

  @override
  SaveExamResultsRequest entries(List<ExamResultEntry> entries) =>
      this(entries: entries);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamResultsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamResultsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamResultsRequest call({
    Object? scheduleId = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
  }) {
    return SaveExamResultsRequest(
      scheduleId: scheduleId == const $CopyWithPlaceholder()
          ? _value.scheduleId
          // ignore: cast_nullable_to_non_nullable
          : scheduleId as String,
      entries: entries == const $CopyWithPlaceholder()
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<ExamResultEntry>,
    );
  }
}

extension $SaveExamResultsRequestCopyWith on SaveExamResultsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamResultsRequest.copyWith(...)` or like so:`instanceOfSaveExamResultsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamResultsRequestCWProxy get copyWith =>
      _$SaveExamResultsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamResultsRequest _$SaveExamResultsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveExamResultsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['scheduleId', 'entries']);
  final val = SaveExamResultsRequest(
    scheduleId: $checkedConvert('scheduleId', (v) => v as String),
    entries: $checkedConvert(
      'entries',
      (v) => (v as List<dynamic>)
          .map((e) => ExamResultEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SaveExamResultsRequestToJson(
  SaveExamResultsRequest instance,
) => <String, dynamic>{
  'scheduleId': instance.scheduleId,
  'entries': instance.entries.map((e) => e.toJson()).toList(),
};
