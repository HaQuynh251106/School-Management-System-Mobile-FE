//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum AttendanceStatus {
  @JsonValue(r'PRESENT')
  PRESENT(r'PRESENT'),
  @JsonValue(r'LATE')
  LATE(r'LATE'),
  @JsonValue(r'ABSENT_UNEXCUSED')
  ABSENT_UNEXCUSED(r'ABSENT_UNEXCUSED'),
  @JsonValue(r'ABSENT_EXCUSED')
  ABSENT_EXCUSED(r'ABSENT_EXCUSED');

  const AttendanceStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
