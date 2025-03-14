import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Pages/Alert/AlertNursePage.dart';  // Voor patient
import 'package:ui/Pages/Users/SignInScreen.dart';    // Voor login
import 'package:ui/Pages/Floorplan/FloorplanScreen.dart'; // Voor andere functies
import 'package:ui/Services/UserService.dart';
import 'package:ui/Models/Users/User.dart' as custom_user;
import 'package:ui/Models/Enums/FunctionType.dart'; // Als je het enum wilt checken
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';

import 'Navigation/MainScaffold.dart';

class HomePage extends StatefulWidget {
  final String title = "VitalRoutes";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // We maken een Future om te checken of de user is ingelogd en zo ja, welke functie
  Future<(bool isLoggedIn, FunctionType? function)> _checkLoginAndFunction() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return (false, null);
    }
    final domainUser = await UserService.getUserByEmail(firebaseUser.email!);
    return (true, domainUser.function);
  }

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<(bool isLoggedIn, FunctionType? function)>(
            future: _checkLoginAndFunction(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final (isLoggedIn, userFunction) = snapshot.data!;
              String buttonLabel;
              VoidCallback onButtonPressed;
              
              if (!isLoggedIn) {
                buttonLabel = "Login";
                onButtonPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScaffold(
                        body: SignInScreen(),
                        hasScaffold: true,
                      ),
                    ),
                  );
                };
              } else {
                if (userFunction == FunctionType.Patient) {
                  buttonLabel = "Alert verpleegkundige";
                  onButtonPressed = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScaffold(
                          body: AlertNursePage(),
                          hasScaffold: true,
                        ),
                      ),
                    );
                  };
                } else {
                  buttonLabel = "Navigeer";
                  onButtonPressed = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScaffold(
                          body: FloorplanPage(
                            hospitalName: 'UZ Groenplaats',
                            initialFloorNumber: -1,
                          ),
                          hasScaffold: true,
                        ),
                      ),
                    );
                  };
                }
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Text(
                      'VitalRoutes',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                        letterSpacing: 1.2,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                  // Creative tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Connecting Care, Step by Step',
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/route.png',
                            width: imageWidth,
                            height: MediaQuery.of(context).size.width * 0.6,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 40),
                          SizedBox(
                            width: imageWidth,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                shadowColor: Colors.blue.shade200,
                              ),
                              onPressed: onButtonPressed,
                              child: Text(
                                buttonLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Arial',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
