class TimetableSlot {
  const TimetableSlot({
    required this.id,
    required this.classId,
    required this.classCode,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.roomCode,
    required this.dayOfWeek,
    required this.periodNo,
    required this.startTime,
    required this.endTime,
    required this.semesterId,
    required this.publishedPlanId,
  });

  final String id;
  final String classId;
  final String classCode;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String roomCode;
  final String dayOfWeek;
  final int periodNo;
  final String startTime;
  final String endTime;
  final String semesterId;
  final String publishedPlanId;

  factory TimetableSlot.fromJson(Map<String, dynamic> json) => TimetableSlot(
    id: '${json['id'] ?? ''}',
    classId: '${json['classId'] ?? ''}',
    classCode: '${json['classCode'] ?? ''}',
    subjectId: '${json['subjectId'] ?? ''}',
    subjectName: '${json['subjectName'] ?? ''}',
    teacherId: '${json['teacherId'] ?? ''}',
    teacherName: '${json['teacherName'] ?? ''}',
    roomCode: '${json['roomCode'] ?? ''}',
    dayOfWeek: '${json['dayOfWeek'] ?? ''}',
    periodNo: (json['periodNo'] as num?)?.toInt() ?? 0,
    startTime: '${json['startTime'] ?? ''}',
    endTime: '${json['endTime'] ?? ''}',
    semesterId: '${json['semesterId'] ?? ''}',
    publishedPlanId: '${json['publishedPlanId'] ?? ''}',
  );
}
