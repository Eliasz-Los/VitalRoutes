import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Models/Users/User.dart' as domain;
import '../Admin/RoomAssignmentsPage.dart';
import '../Admin/SystemAdminPage.dart';
import '../Admin/OverviewPage.dart';
import '../../Models/Enums/FunctionType.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../../Services/AuthService.dart';
import '../../Services/UserService.dart';
import '../Floorplan/FloorplanScreen.dart';
import '../home_page.dart';
import 'MainScaffold.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onItemSelected;
  final firebase_auth.User? firebaseUser;

  CustomDrawer({required this.onItemSelected, required this.firebaseUser, super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  domain.User? domainUser;

  @override
  void initState() {
    super.initState();
    _fetchDomainUser();
  }

  Future<void> _fetchDomainUser() async {
    if (widget.firebaseUser != null) {
      try {
        domainUser = await UserService.getUserByEmail(widget.firebaseUser!.email!);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user: $e')),
        );
      }
    }
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
          if (domainUser != null && domainUser!.function == FunctionType.Doctor) _buildDrawerItem(Icons.list, 'Overview', context, 4, false),
          _buildDrawerItem(Icons.admin_panel_settings, 'System Admin', context, 3, false),
          _buildDrawerItem(Icons.map, 'Floorplan', context, 5, false),
          _buildDrawerItem(Icons.assignment, 'Room Assignment',context,6,false),
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
          if (widget.firebaseUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in first!')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(firebaseUser: widget.firebaseUser!),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: OverviewPage(),
                hasScaffold: true,
              ),
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
        return UserProfileScreen(firebaseUser: widget.firebaseUser!);
      case 3:
        return SystemAdminPage();
      case 4:
        return OverviewPage();
      case 5:
        return FloorplanPage(hospitalName: "UZ Groenplaats", initialFloorNumber: 0,);
      case 6:
        return RoomAssignmentsPage();
      default:
        return HomePage();
    }
  }
}