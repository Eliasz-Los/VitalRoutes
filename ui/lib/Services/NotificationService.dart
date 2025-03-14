import 'package:dio/dio.dart';
import '../Models/NotificationModel.dart';

class NotificationService {
  static final Dio _dio = Dio();

  static Future<List<NotificationModel>> getNotificationsForNurse(String nurseId) async {
    final response = await _dio.get('http://10.0.2.2:5028/api/notification/nurse/$nurseId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }


  static Future<void> createNotification(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:5028/api/Notification/create',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print('Notificatie succesvol aangemaakt: ${response.data}');
      } else {
        print('Fout bij notificatie-aanmaak: ${response.statusCode}');
        throw Exception('Failed to create notification, status: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP Request error: $e');
      throw Exception('Fout bij verzenden van notificatie: $e');
    }
  }

  static Future<void> updateNotificationStatus(String notificationId, String newStatus) async {
    // Let op de extra quotes: data: '"$newStatus"'
    final response = await _dio.put(
      'http://10.0.2.2:5028/api/Notification/$notificationId/status',
      data: '"$newStatus"',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update notification status');
    }
  }

  static Future<List<NotificationModel>> getNotificationsForPatient(String patientId) async {
    final response = await _dio.get('http://10.0.2.2:5028/api/notification/patient/$patientId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load patient notifications');
    }
  }


}