class NotificationModel {
  final String id;
  final String message;
  String status;
  final DateTime timeStamp;
  final String userId;
  final String userName;
  final String emergencyLevel;
  final int roomNumber; // Toegevoegd

  NotificationModel({
    required this.id,
    required this.message,
    required this.status,
    required this.timeStamp,
    required this.userId,
    required this.userName,
    required this.emergencyLevel,
    required this.roomNumber,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      status: json['status'],
      timeStamp: DateTime.parse(json['timeStamp']),
      userId: json['userId'],
      userName: json['userName'] ?? 'Onbekend',
      emergencyLevel: json['emergencyLevel'] ?? 'Onbekend',
      roomNumber: json['roomNumber'] ?? -101,
    );
  }
}
