import 'package:flutter/material.dart';
import '../home_page.dart';
import '../SystemAdminPage.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/RegisterScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import 'custom_drawer.dart';

class MainScaffold extends StatefulWidget {
  final Widget body; // 

  MainScaffold({required this.body, Key? key}) : super(key: key); //

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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VitalRoutes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(onItemSelected: _onItemTapped), // 
      body: widget.body, // Toont de juiste pagina
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Sign In'),
        ],
        currentIndex: _selectedIndex > 1 ? 0 : _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
