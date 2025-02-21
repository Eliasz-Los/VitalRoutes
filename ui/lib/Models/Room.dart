
import 'Point.dart';
import 'Users/User.dart';

class Room {
  final String id;
  final Point point;
  final User? assignedPatient;
  final int roomNumber;
  
  Room({
    required this.id,
    required this.point,
    required this.assignedPatient,
    required this.roomNumber,
  });
  
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      point: Point.fromJson(json['point']),
      assignedPatient: json['assignedPatient'] != null ? User.fromJson(json['assignedPatient']) : null,
      roomNumber: json['roomNumber'],
    );
  }
}
