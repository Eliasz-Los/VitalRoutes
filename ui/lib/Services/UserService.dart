import 'package:dio/dio.dart';
import 'package:ui/Models/Users/UpdateUser.dart';
import 'package:ui/Models/Users/User.dart';

import '../Config.dart';

class UserService{
  static final Dio _dio = Dio();
  static final String baseUrl = Config.apiUrl;

 static Future<void> updateUser(UpdateUser updateUser) async{
    try{
      final response = await _dio.put(
        '$baseUrl/api/user/update',
        data: updateUser.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if(response.statusCode != 200){
        throw Exception('Failed to update user');
      }
    }catch(e){
      throw Exception('Error updating user: $e');
    }
 }

  static Future<void> addUnderSupervision(String supervisorId, String superviseeId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/user/$supervisorId/addUnderSupervision/$superviseeId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add supervision');
      }
    } catch (e) {
      throw Exception('Error adding supervision: $e');
    }
  }

  static Future<User> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('$baseUrl/api/user/$email');
      if (response.statusCode != 200) {
        throw Exception('Failed to load user data');
      }
      if (response.data == null) {
        throw Exception('User not found');
      }
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Error getting user by email $email: \n$e');
    }
  }

  static Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/api/user/id/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to load user data');
      }
      if (response.data == null) {
        throw Exception('User not found');
      }
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Error getting user by id $id: \n$e');
    }
  }
  
  static Future<List<User>> getUsersByFunction(String function) async {
    try {
      final response = await _dio.get('$baseUrl/api/user/getUsers/$function');
      if (response.statusCode != 200) {
        throw Exception('Failed to load user data');
      }
      if (response.data == null) {
        throw Exception('Users not found');
      }
      List<dynamic> body = response.data;
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error getting users by function $function: \n$e');
    }
  }

  // lib/Services/UserService.dart

  static Future<void> removeUnderSupervision(String supervisorId, String superviseeId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/user/$supervisorId/removeUnderSupervision/$superviseeId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove supervision');
      }
    } catch (e) {
      throw Exception('Error removing supervision: $e');
    }
  }


}