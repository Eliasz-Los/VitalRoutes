import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Models/Users/User.dart' as domain_user;

class UserProvider with ChangeNotifier {
  User? _user;
  domain_user.User? _domainUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;
  domain_user.User? get domainUser => _domainUser;

  void setUser([User? user, domain_user.User? domainUser]) {
    _user = user;
    _domainUser = domainUser;
    notifyListeners();
  }

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
}