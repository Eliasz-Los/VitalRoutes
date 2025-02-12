import 'package:flutter/material.dart';
import '../SystemAdminPage.dart';

class CustomDrawer extends StatelessWidget {
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
          ListTile(
            
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('System Admin'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SystemAdminPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

