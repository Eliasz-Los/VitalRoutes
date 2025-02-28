import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Floorplan/FloorWithRoutingScreen.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import '../Admin/SystemAdminPage.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../../Services/AuthService.dart';
import '../Floorplan/FloorplanScreen.dart';
import '../home_page.dart';
import 'MainScaffold.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onItemSelected;
  final User? firebaseUser;

  CustomDrawer({required this.onItemSelected, required this.firebaseUser, super.key});
  
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
   // final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.home, 'Home', context, 0, false),
          if (widget.firebaseUser == null) _buildDrawerItem(Icons.login, 'Sign In', context, 1, false),
          if (widget.firebaseUser != null) _buildDrawerItem(Icons.person, 'Profile', context, 2, true),
          _buildDrawerItem(Icons.admin_panel_settings, 'System Admin', context, 3, false),
          _buildDrawerItem(Icons.map, 'Floorplan', context, 4, false),
          _buildDrawerItem(Icons.route, 'Floorplan with Routing', context, 5, false), //TODO: extra floor for testing
          Divider(),
          if (widget.firebaseUser != null)
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
        widget.onItemSelected(index);
        Navigator.pop(context);

        if (index == 2) {
         // final user = FirebaseAuth.instance.currentUser;
          if (widget.firebaseUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in first!')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(firebaseUser: widget.firebaseUser!,),
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
        return UserProfileScreen(firebaseUser: widget.firebaseUser!,);
      case 3:
        return SystemAdminPage();
      case 4:
        return FloorplanPage(hospitalName: "UZ Groenplaats", floorNumber: -1);
      case 5:
        return FloorWithRoutingScreen(hospitalName: "UZ Groenplaats", floorNumber: -1, floorName: "floor_minus1C"); //TODO: extra floor for testing
      default:
        return HomePage();
    }
  }
}
