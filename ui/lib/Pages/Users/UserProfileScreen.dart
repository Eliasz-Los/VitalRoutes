import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Users/UpdateUser.dart';
import 'package:ui/Models/Users/User.dart' as custom_user;
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Services/UserService.dart';
import 'package:ui/main.dart';

class UserProfileScreen extends StatefulWidget {
  final String email;

  const UserProfileScreen({super.key, required this.email});

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
  final TextEditingController _functionController = TextEditingController();
  var firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _userData = UserService.getUserByEmail(widget.email);
    _userData.then((user) {
      _firstNameController.text = user.firstName!;
      _lastNameController.text = user.lastName!;
      _emailController.text = user.email!;
      _telephoneNrController.text = user.telephoneNr!;
      _functionController.text = user.function?.name as String;
    });
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final user = await _userData;
      final updateUser = UpdateUser(
        id: user.id!,
        Uid: firebaseUser!.uid,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        telephoneNr: _telephoneNrController.text,
      );
      await UserService.updateUser(updateUser);
      //als da op true was kon ik nie navigeren naar de homepage, nu wel 
      Provider.of<UserProvider>(context, listen: false).setUser(firebaseUser);
      //Zodat de user geen callback kan doen naar de vorige waardes want die zijn verandert, errort anders
      Navigator.pushAndRemoveUntil(context, 
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Vital Routes')),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _telephoneNrController,
                      decoration: InputDecoration(labelText: 'Telephone Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your telephone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _functionController,
                      decoration: InputDecoration(labelText: 'Function'),
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: Text('Update'),
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