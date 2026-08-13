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
      this.category, this.assessmentIndex, this.label, this.weight);

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

List<GradeColumn> buildGradeColumns(List<GradeCategoryDefinition> categories) {
  return [
    for (final category in categories)
      for (var index = 1; index <= category.requiredCount; index++)
        GradeColumn(
          category.code,
          index,
          category.requiredCount > 1
              ? '${category.name} $index'
              : category.name,
          category.weight,
        ),
  ];
}

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
