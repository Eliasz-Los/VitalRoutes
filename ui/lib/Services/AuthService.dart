import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Models/Users/RegisterUser.dart';
import 'package:ui/Models/Users/UserCredentials.dart';

class AuthService {
  static final Dio _dio = Dio();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> registerUser(RegisterUser registerUser) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:5028/api/firebaseauth/register',
        data: registerUser.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      throw Exception('Error registering user: $e');
    }
  }

  static Future<void> signInWithEmailAndPassword(UserCredentials userCredentials) async{
    try{
      final response = await _dio.post(
        'http://10.0.2.2:5028/api/firebaseauth/login',
        data: userCredentials.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if(response.statusCode != 200){
        throw Exception('Failed to authenticate user');
      }
      
      //Handling response, saving token
      final token = response.data['token'];
      await _auth.signInWithCustomToken(token);
    } catch(e){
      throw Exception('Error signing in: $e');
    }
  }
  
  static Future<void> signOut() async {
    try{
      await _auth.signOut();
    }catch(e){
      throw Exception('Error signing out: $e');
    }
  }
}