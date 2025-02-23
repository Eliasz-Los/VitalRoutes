import 'package:dio/dio.dart';
import 'package:ui/Models/Users/UpdateUser.dart';
import 'package:ui/Models/Users/User.dart';

class UserService{
  static final Dio _dio = Dio();
  
  static Future<User> getUserByEmail(String email) async{
    try{
      final response = await _dio.get('http://10.0.2.2:5028/api/user/$email');
      if(response.statusCode != 200){
        throw Exception('Failed to load user data');
      }
      if(response.data == null){
        throw Exception('User not found');
      }
      return User.fromJson(response.data);
    }catch(e){
      throw Exception('Error getting user by email $email: \n$e');
    }
  }

 static Future<void> updateUser(UpdateUser updateUser) async{
    try{
      final response = await _dio.put(
        'http://10.0.2.2:5028/api/user/update',
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
        'http://10.0.2.2:5028/api/user/$supervisorId/addUnderSupervision/$superviseeId',
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

  static Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('http://10.0.2.2:5028/api/user/$id');
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
 
}