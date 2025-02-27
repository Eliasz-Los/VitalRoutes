import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Users/UpdateUser.dart';
import 'package:ui/Models/Users/User.dart' as custom_user;
import 'package:ui/Models/Users/UserCredentials.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Services/AuthService.dart';
import 'package:ui/Services/UserService.dart';
import '../Navigation/MainScaffold.dart';
import '../home_page.dart';

class UserProfileScreen extends StatefulWidget {
  final User firebaseUser;

  const UserProfileScreen({super.key, required this.firebaseUser});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<custom_user.User> _userData;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneNrController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _userData = UserService.getUserByEmail(widget.firebaseUser.email.toString());
    _userData.then((user) {
      setState(() {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _telephoneNrController.text = user.telephoneNr ?? '';
        _functionController.text = user.function?.name ?? 'Unknown';
      });
    });
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final user = await _userData;
      final updateUser = UpdateUser(
        id: user.id!,
        Uid: widget.firebaseUser.uid,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        telephoneNr: _telephoneNrController.text,
        password: _passwordController.text,
      );
      await UserService.updateUser(updateUser);
      await AuthService.signInWithEmailAndPassword(
        UserCredentials(email: _emailController.text, password: _passwordController.text),
      );
      firebase_auth.User? reAuthenticatedUser = FirebaseAuth.instance.currentUser;
      Provider.of<UserProvider>(context, listen: false).setUser(reAuthenticatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes accepted'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _userData = UserService.getUserByEmail(_emailController.text);
      });

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScaffold(body: HomePage())),
              (Route<dynamic> route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: FutureBuilder<custom_user.User>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 27,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your first name' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your last name' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: !_showPassword,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _showPassword,
                          onChanged: (value) {
                            setState(() {
                              _showPassword = value!;
                            });
                          },
                        ),
                        Text('Show password'),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _telephoneNrController,
                      decoration: InputDecoration(
                        labelText: 'Telephone Number',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your telephone number';
                        }
                        final phoneRegExp = RegExp(r'^\+[1-9]\d{0,2}\s?\d{1,14}$');
                        if (!phoneRegExp.hasMatch(value)) {
                          return 'Please enter a valid phone number: +32 123456789';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _functionController,
                      decoration: InputDecoration(
                        labelText: 'Function',
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Update', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
