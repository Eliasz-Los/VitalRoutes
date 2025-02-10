import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        String? idToken = await user.getIdToken();
        await _sendTokenToBackend(idToken!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Problem with signing with email and password: \n$e');
    }
  }

  Future<void> _sendTokenToBackend(String idToken) async {
   try {
     final response = await _dio.post(
         'http://10.0.2.2:5028/api/auth/firebase-login',
         data: {'idToken': idToken},
         options: Options(
           headers: {
             'Content-Type': 'application/json',
           },
         ));

     if (response.statusCode == 200) {
       print('User authenticated successfully');
     } else {
       print('Failed to authenticate user');
     }
   }catch(e){
     print('Error from send token:  $e');
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed: _signInWithEmailAndPassword,
            child: Text('Sign In'),
          ),
            if(_errorMessage != null) ... [
              SizedBox(height: 20),
              Text(_errorMessage!,
              style: TextStyle(color: Colors.red)
              ),
            ]
          ],
      ),
    ),
  );
  }
}