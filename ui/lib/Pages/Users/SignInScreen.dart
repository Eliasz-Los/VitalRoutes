import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Users/UserCredentials.dart';
import 'package:ui/Pages/Users/UserMenuWidget.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Services/AuthService.dart';

import '../../presentation/home_page.dart';
import '../../presentation/widgets/custom_drawer.dart';
import 'RegisterScreen.dart';
import 'package:ui/presentation/widgets/MainScaffold.dart';

import 'UserProfileScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredentials userCredentials = UserCredentials(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await AuthService.signInWithEmailAndPassword(userCredentials);
      User? user = FirebaseAuth.instance.currentUser;
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScaffold(body: HomePage())),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Problem with signing in: \n$e');
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(email: _emailController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold( 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            TextButton(
              onPressed: _navigateToRegister,
              child: Text('Don\'t have an account? Register here'),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
