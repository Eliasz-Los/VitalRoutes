import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../Admin/SystemAdminPage.dart';
import '../Floorplan/FloorplanScreen.dart';
import '../home_page.dart';
import 'custom_drawer.dart';
import '../../Services/AuthService.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final bool hasScaffold;

  MainScaffold({required this.body, this.hasScaffold = false, Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  User? user;  
  late List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    _pages = [
      HomePage(),
      SignInScreen(),
      if (user != null) UserProfileScreen(firebaseUser: user!,),
      SystemAdminPage(),
      FloorplanPage(hospitalName: "UZ Groenplaats", floorNumber: -1),
    ];
  }

  void _onItemTapped(int index) {
    bool hasScaffold = index == 2;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => hasScaffold
            ? _pages[index]
            : MainScaffold(body: _pages[index], hasScaffold: false),
      ),
          (route) => false,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      Provider.of<UserProvider>(context, listen: false).setUser(null);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VitalRoutes', style: TextStyle(color: Colors.white)),
            if (user != null)
              Text(user!.email ?? 'User', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          if (user != null) PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(firebaseUser: user!,),
                  ),
                );
              } else if (value == 'logout') {
                _signOut(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
            icon: Icon(Icons.person, color: Colors.white),
          ) else TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
            },
            child: Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: CustomDrawer(onItemSelected: _onItemTapped, firebaseUser: user,),
      body: widget.body,
    );
  }
}


