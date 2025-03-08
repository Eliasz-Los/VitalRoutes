class NotificationModel {
  final String id;
  final String message;
  String status;
  final DateTime timeStamp;
  final String patientId;
  final String patientName;     // Toegevoegd voor weergave in de notificatie
  final String emergencyLevel;  // Bijvoorbeeld "Low", "Medium", "High"

  NotificationModel({
    required this.id,
    required this.message,
    required this.status,
    required this.timeStamp,
    required this.patientId,
    required this.patientName,
    required this.emergencyLevel,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      status: json['status'],
      timeStamp: DateTime.parse(json['timeStamp']),
      patientId: json['patientId'],
      patientName: json['patientName'] ?? 'Onbekend', // fallback als naam niet aanwezig is
      emergencyLevel: json['emergencyLevel'] ?? 'Low',
    );
  }
}
