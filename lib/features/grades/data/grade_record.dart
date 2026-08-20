class GradeRecord {
  const GradeRecord({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    required this.semesterId,
    required this.category,
    required this.categoryName,
    required this.assessmentIndex,
    required this.score,
    required this.version,
    required this.recordedAt,
    required this.note,
  });

  final String id;
  final String studentId;
  final String subjectId;
  final String subjectName;
  final String semesterId;
  final String category;
  final String categoryName;
  final int assessmentIndex;
  final double score;
  final int version;
  final DateTime? recordedAt;
  final String? note;

  String get key => '$category#$assessmentIndex';

  factory GradeRecord.fromJson(Map<String, dynamic> json) => GradeRecord(
    id: '${json['id'] ?? ''}',
    studentId: '${json['studentId'] ?? ''}',
    subjectId: '${json['subjectId'] ?? ''}',
    subjectName: '${json['subjectName'] ?? ''}',
    semesterId: '${json['semesterId'] ?? ''}',
    category: '${json['category'] ?? ''}',
    categoryName: '${json['categoryName'] ?? json['category'] ?? ''}',
    assessmentIndex: (json['assessmentIndex'] as num?)?.toInt() ?? 1,
    score: (json['score'] as num).toDouble(),
    version: (json['version'] as num?)?.toInt() ?? 0,
    recordedAt: DateTime.tryParse('${json['recordedAt'] ?? ''}'),
    note: json['note']?.toString(),
  );
}

class GradeCategoryDefinition {
  const GradeCategoryDefinition({
    required this.code,
    required this.name,
    required this.weight,
    required this.requiredCount,
  });

  final String code;
  final String name;
  final double weight;
  final int requiredCount;

  factory GradeCategoryDefinition.fromJson(Map<String, dynamic> json) =>
      GradeCategoryDefinition(
        code: '${json['code'] ?? ''}',
        name: '${json['name'] ?? json['code'] ?? ''}',
        weight: (json['weight'] as num?)?.toDouble() ?? 1,
        requiredCount: (json['requiredCount'] as num?)?.toInt() ?? 1,
      );
}

class GradeColumn {
  const GradeColumn(
    this.category,
    this.assessmentIndex,
    this.label,
    this.weight,
  );

  final String category;
  final int assessmentIndex;
  final String label;
  final double weight;

  String get key => '$category#$assessmentIndex';
}

class GradeSubjectSummary {
  const GradeSubjectSummary({
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    required this.semesterId,
    required this.average,
    required this.complete,
    required this.missingAssessmentKeys,
  });

  final String studentId;
  final String subjectId;
  final String subjectName;
  final String semesterId;
  final double? average;
  final bool complete;
  final List<String> missingAssessmentKeys;

  String get key => '$subjectId|$semesterId';

  factory GradeSubjectSummary.fromJson(Map<String, dynamic> json) =>
      GradeSubjectSummary(
        studentId: '${json['studentId'] ?? ''}',
        subjectId: '${json['subjectId'] ?? ''}',
        subjectName: '${json['subjectName'] ?? ''}',
        semesterId: '${json['semesterId'] ?? ''}',
        average: (json['average'] as num?)?.toDouble(),
        complete: json['complete'] == true,
        missingAssessmentKeys:
            (json['missingAssessmentKeys'] as List? ?? const [])
                .map((value) => '$value')
                .toList(growable: false),
      );
}

/// A subject/semester selection backed by the grade rows and canonical
/// summary returned by the backend. Keeping both ids here prevents detail
/// screens from accidentally querying with an empty subject or semester.
class SubjectGradeSelection {
  const SubjectGradeSelection({
    required this.subjectId,
    required this.subjectName,
    required this.semesterId,
    required this.records,
    required this.average,
    required this.complete,
  });

  final String subjectId;
  final String subjectName;
  final String semesterId;
  final Map<String, GradeRecord> records;
  final double? average;
  final bool complete;

  String get key => '$subjectId|$semesterId';
}

/// Joins `/grades` with `/grades/summary` without recalculating the canonical
/// average on the client. A summary without a grade row is retained so the
/// caller can still navigate using the real subject and semester ids.
List<SubjectGradeSelection> buildSubjectGradeSelections({
  required Iterable<Map<String, dynamic>> gradeRows,
  required Iterable<Map<String, dynamic>> summaryRows,
}) {
  final builders = <String, _SubjectGradeSelectionBuilder>{};

  String selectionKey(String subjectId, String subjectName, String semesterId) {
    final subjectKey = subjectId.isNotEmpty ? subjectId : subjectName;
    return '$subjectKey|$semesterId';
  }

  for (final row in gradeRows) {
    if (row['score'] is! num) continue;
    final record = GradeRecord.fromJson(row);
    if (record.subjectName.isEmpty || record.semesterId.isEmpty) continue;
    final key = selectionKey(
      record.subjectId,
      record.subjectName,
      record.semesterId,
    );
    final builder = builders.putIfAbsent(
      key,
      () => _SubjectGradeSelectionBuilder(
        subjectId: record.subjectId,
        subjectName: record.subjectName,
        semesterId: record.semesterId,
      ),
    );
    builder.records[record.key] = record;
  }

  for (final row in summaryRows) {
    final summary = GradeSubjectSummary.fromJson(row);
    if (summary.subjectName.isEmpty || summary.semesterId.isEmpty) continue;
    final key = selectionKey(
      summary.subjectId,
      summary.subjectName,
      summary.semesterId,
    );
    final builder = builders.putIfAbsent(
      key,
      () => _SubjectGradeSelectionBuilder(
        subjectId: summary.subjectId,
        subjectName: summary.subjectName,
        semesterId: summary.semesterId,
      ),
    );
    builder
      ..subjectId = summary.subjectId
      ..subjectName = summary.subjectName
      ..summary = summary;
  }

  final selections = builders.values
      .map(
        (builder) => SubjectGradeSelection(
          subjectId: builder.subjectId,
          subjectName: builder.subjectName,
          semesterId: builder.semesterId,
          records: Map.unmodifiable(builder.records),
          average: builder.summary?.average,
          complete: builder.summary?.complete ?? false,
        ),
      )
      .toList();
  selections.sort((left, right) {
    final semester = left.semesterId.compareTo(right.semesterId);
    return semester != 0
        ? semester
        : left.subjectName.compareTo(right.subjectName);
  });
  return selections;
}

class _SubjectGradeSelectionBuilder {
  _SubjectGradeSelectionBuilder({
    required this.subjectId,
    required this.subjectName,
    required this.semesterId,
  });

  String subjectId;
  String subjectName;
  final String semesterId;
  final Map<String, GradeRecord> records = {};
  GradeSubjectSummary? summary;
}

List<GradeColumn> buildGradeColumns(
  List<GradeCategoryDefinition> categories, {
  Iterable<GradeRecord> records = const [],
}) {
  final recordsByCategory = <String, List<GradeRecord>>{};
  for (final record in records) {
    (recordsByCategory[record.category] ??= []).add(record);
  }

  final columns = <GradeColumn>[];
  final configuredCodes = <String>{};
  for (final category in categories) {
    configuredCodes.add(category.code);
    final observedMax =
        recordsByCategory[category.code]?.fold<int>(
          0,
          (max, record) =>
              record.assessmentIndex > max ? record.assessmentIndex : max,
        ) ??
        0;
    final count = observedMax > category.requiredCount
        ? observedMax
        : category.requiredCount;
    for (var index = 1; index <= count; index++) {
      columns.add(
        GradeColumn(
          category.code,
          index,
          count > 1 ? '${category.name} $index' : category.name,
          category.weight,
        ),
      );
    }
  }

  // Never hide an existing assessment if its category is not in the current
  // configuration (for example while an administrator is changing it).
  final unconfiguredCodes =
      recordsByCategory.keys
          .where((code) => !configuredCodes.contains(code))
          .toList()
        ..sort();
  for (final code in unconfiguredCodes) {
    final categoryRecords = recordsByCategory[code]!;
    final count = categoryRecords.fold<int>(
      0,
      (max, record) =>
          record.assessmentIndex > max ? record.assessmentIndex : max,
    );
    final name = categoryRecords.first.categoryName;
    for (var index = 1; index <= count; index++) {
      columns.add(
        GradeColumn(code, index, count > 1 ? '$name $index' : name, 1),
      );
    }
  }
  return columns;
}

Map<String, Map<String, GradeRecord>> groupGradeRecordsByStudent(
  Iterable<Map<String, dynamic>> rows,
) {
  final grouped = <String, Map<String, GradeRecord>>{};
  for (final row in rows) {
    if (row['studentId'] == null ||
        row['category'] == null ||
        row['score'] is! num) {
      continue;
    }
    final record = GradeRecord.fromJson(row);
    (grouped[record.studentId] ??= {})[record.key] = record;
  }
  return grouped;
}

Map<String, dynamic> buildGradeEntryPayload({
  required String studentId,
  required double score,
  GradeRecord? existing,
}) => <String, dynamic>{
  'studentId': studentId,
  'score': score,
  if (existing?.note != null) 'note': existing!.note,
  if (existing != null) 'expectedVersion': existing.version,
};

double? completeWeightedAverage(
  Map<String, GradeRecord> records,
  List<GradeColumn> columns,
) {
  if (columns.isEmpty ||
      columns.any((column) => !records.containsKey(column.key))) {
    return null;
  }
  var total = 0.0;
  var totalWeight = 0.0;
  for (final column in columns) {
    total += records[column.key]!.score * column.weight;
    totalWeight += column.weight;
  }
  return totalWeight == 0 ? null : total / totalWeight;
}
