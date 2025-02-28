class AssignPatientToRoom {
  final String roomId;
  final String? patientId;

  AssignPatientToRoom({required this.roomId, required this.patientId});

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'patientId': patientId,
  };
}