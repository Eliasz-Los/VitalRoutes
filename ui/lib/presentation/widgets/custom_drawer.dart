import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../SystemAdminPage.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../widgets/MainScaffold.dart';
import '../../Services/AuthService.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  CustomDrawer({required this.onItemSelected, Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
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
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.home, 'Home', context, 0, false),
          if (user == null) _buildDrawerItem(Icons.login, 'Sign In', context, 1, false),
          if (user != null) _buildDrawerItem(Icons.person, 'Profile', context, 2, true),
          _buildDrawerItem(Icons.admin_panel_settings, 'System Admin', context, 3, false),
          Divider(),
          if (user != null)
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => _signOut(context),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, int index, bool hasScaffold) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);

        if (index == 2) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in first!')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(email: user.email!),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(body: _getPage(index), hasScaffold: hasScaffold),
            ),
          );
        }
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return SignInScreen();
      case 2:
        return UserProfileScreen(email: "example@email.com");
      case 3:
        return SystemAdminPage();
      default:
        return HomePage();
    }
  }
}
