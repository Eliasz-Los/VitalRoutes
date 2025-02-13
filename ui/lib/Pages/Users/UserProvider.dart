import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Models/Users/UserCredentials.dart';
import 'package:ui/Services/AuthService.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
  
  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
}