import 'package:flutter/material.dart';

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
          _buildDrawerItem(Icons.home, 'Home', context, 0),
          _buildDrawerItem(Icons.login, 'Sign In', context, 1),
          _buildDrawerItem(Icons.app_registration, 'Register', context, 2),
          _buildDrawerItem(Icons.person, 'Profile', context, 3),
          _buildDrawerItem(Icons.admin_panel_settings, 'System Admin', context, 4),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        onItemSelected(index); //
        Navigator.pop(context); //
      },
    );
  }
}

