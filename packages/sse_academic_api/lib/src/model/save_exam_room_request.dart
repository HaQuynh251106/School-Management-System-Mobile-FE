//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_room_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamRoomRequest {
  /// Returns a new [SaveExamRoomRequest] instance.
  SaveExamRoomRequest({
    this.id,

    required this.roomCode,

    required this.capacity,

    this.proctorOneId,

    this.proctorTwoId,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'roomCode', required: true, includeIfNull: false)
  final String roomCode;

  // minimum: 1
  // maximum: 1000
  @JsonKey(name: r'capacity', required: true, includeIfNull: false)
  final int capacity;

  @JsonKey(name: r'proctorOneId', required: false, includeIfNull: false)
  final String? proctorOneId;

  @JsonKey(name: r'proctorTwoId', required: false, includeIfNull: false)
  final String? proctorTwoId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamRoomRequest &&
          other.id == id &&
          other.roomCode == roomCode &&
          other.capacity == capacity &&
          other.proctorOneId == proctorOneId &&
          other.proctorTwoId == proctorTwoId;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      roomCode.hashCode +
      capacity.hashCode +
      (proctorOneId == null ? 0 : proctorOneId.hashCode) +
      (proctorTwoId == null ? 0 : proctorTwoId.hashCode);

  factory SaveExamRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamRoomRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamRoomRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
