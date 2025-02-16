import 'package:flutter/material.dart';
import '../home_page.dart';
import '../SystemAdminPage.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/RegisterScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../widgets/MainScaffold.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  CustomDrawer({required this.onItemSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.home, 'Home', context, 0, false),
          _buildDrawerItem(Icons.login, 'Sign In', context, 1, true),
          _buildDrawerItem(Icons.app_registration, 'Register', context, 2, true),
          _buildDrawerItem(Icons.person, 'Profile', context, 3, true),
          _buildDrawerItem(Icons.admin_panel_settings, 'System Admin', context, 4, false),
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScaffold(body: _getPage(index), hasScaffold: hasScaffold)),
              (route) => false,
        );
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
        return RegisterScreen();
      case 3:
        return UserProfileScreen(email: "example@email.com");
      case 4:
        return SystemAdminPage();
      default:
        return HomePage();
    }
  }
}
