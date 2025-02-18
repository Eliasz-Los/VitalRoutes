import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Users/UserCredentials.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Services/AuthService.dart';
import '../Navigation/MainScaffold.dart';
import 'RegisterScreen.dart';
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
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(firebaseUser: user!),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Problem with signing in: \n$e');
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScaffold(body: RegisterScreen())),
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
              decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.blue[900])),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.blue[900])),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: Text('Sign In', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
                onPressed: _navigateToRegister,
                child: Text("Don't have an account? Register here", style: TextStyle(color: Colors.blue[900]))
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
