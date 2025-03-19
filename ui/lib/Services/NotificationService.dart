import 'package:dio/dio.dart';
import '../Models/NotificationModel.dart';
import '../Config.dart';

class NotificationService {
  static final String baseUrl = Config.apiUrl;
  static final Dio _dio = Dio();

  static Future<List<NotificationModel>> getNotificationsForNurse(String nurseId) async {
    final response = await _dio.get('$baseUrl/api/notification/nurse/$nurseId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<List<NotificationModel>> getNotificationsForDoctor(String doctorId) async {
    final response = await _dio.get('$baseUrl/api/notification/doctor/$doctorId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }


  static Future<void> createPatientToNurseNotification(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/Notification/createPatientToNurseNotification',
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


  static Future<void> createNurseToDoctorNotification(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/Notification/createNurseToDoctorNotification',
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
      '$baseUrl/api/Notification/$notificationId/status',
      data: '"$newStatus"',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update notification status');
    }
  }

  static Future<List<NotificationModel>> getSentNotificationsForPatient(String patientId) async {
    final response = await _dio.get('$baseUrl/api/notification/sent/patient/$patientId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load patient notifications');
    }
  }

  static Future<List<NotificationModel>> getSentNotificationsForNurse(String nurseId) async {
    final response = await _dio.get('$baseUrl/api/notification/sent/patient/$nurseId');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load nurse notifications');
    }
  }

}