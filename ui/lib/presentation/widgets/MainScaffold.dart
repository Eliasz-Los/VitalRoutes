import 'package:flutter/material.dart';
import '../home_page.dart';
import '../SystemAdminPage.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/RegisterScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import 'custom_drawer.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final bool hasScaffold; 

  MainScaffold({required this.body, this.hasScaffold = false, Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomePage(),
    SignInScreen(),
    RegisterScreen(),
    UserProfileScreen(email: "example@email.com"),
    SystemAdminPage(),
  ];

  void _onItemTapped(int index) {
    bool hasScaffold = index == 1 || index == 2 || index == 3;

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


  @override
  Widget build(BuildContext context) {
    return widget.hasScaffold 
        ? widget.body
        : Scaffold(
      appBar: AppBar(
        title: Text('VitalRoutes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(onItemSelected: _onItemTapped),
      body: widget.body);
  }
}

