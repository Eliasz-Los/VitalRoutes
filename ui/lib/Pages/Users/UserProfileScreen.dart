import 'package:flutter/material.dart';
import 'package:ui/Services/AuthService.dart';

import '../../Models/Users/RegisterUser.dart';

class UserProfileScreen extends StatefulWidget {
  final String email;
  

  const UserProfileScreen({super.key, required this.email});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<RegisterUser> _userData;
  
  @override
  void initState(){
    super.initState();
    _userData = AuthService.getUserByEmail(widget.email);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<RegisterUser>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('First Name: ${user.firstName}'),
                  Text('Last Name: ${user.lastName}'),
                  Text('Email: ${user.email}'),
                  Text('Telephone Number: ${user.telephoneNr}'),
                  Text('Function: ${user.function}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  
}