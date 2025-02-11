import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String email;

  UserProfileScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Text('Logged in as: $email'),
      ),
    );
  }
}