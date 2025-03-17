import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Pages/Alert/NurseNotificationPage.dart';
import 'package:ui/Services/UserService.dart';
import 'package:ui/Models/Users/User.dart' as domain;
import '../Admin/HeadNursePanel.dart';
import '../Admin/RoomAssignmentsPage.dart';
import '../Admin/NurseOverviewPage.dart';
import '../Admin/NursePanel.dart';
import '../Admin/DoctorPanel.dart';
import '../Admin/OverviewPage.dart';
import '../../Models/Enums/FunctionType.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../../Services/AuthService.dart';
import '../Alert/AlertDoctorPage.dart';
import '../Alert/AlertNursePage.dart';
import '../Alert/DoctorNotificationPage.dart';
import '../Alert/NurseToDoctorSentPage.dart';
import '../Alert/PatientToNurseSentPage.dart';
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
        Provider.of<UserProvider>(context, listen: false).setUser(widget.firebaseUser, domainUser);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error bij ophalen gebruiker: $e')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      Provider.of<UserProvider>(context, listen: false).setUser(null, null);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error bij uitloggen: $e')),
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
          _buildDrawerItem(Icons.home, 'Startpagina', context, 0, false),
          if (widget.firebaseUser == null) _buildDrawerItem(Icons.login, 'Login', context, 1, false),
          if (widget.firebaseUser != null) _buildDrawerItem(Icons.person, 'Profiel', context, 2, true),
          if (domainUser != null && (domainUser!.function == FunctionType.Headnurse || domainUser!.function == FunctionType.Nurse)) _buildDrawerItem(Icons.notifications, 'Notificaties', context, 11, false),
          if (domainUser != null && domainUser!.function == FunctionType.Doctor) _buildDrawerItem(Icons.notifications, 'Notificaties', context, 15, false),
          if (domainUser != null && domainUser!.function == FunctionType.Patient) _buildDrawerItem(Icons.send, 'Verzonden alerts', context, 12, false),
          if (domainUser != null && (domainUser!.function == FunctionType.Doctor || domainUser!.function == FunctionType.Headnurse)) _buildDrawerItem(Icons.supervised_user_circle, 'Personeel & Patiënten', context, 4, false),
          if (domainUser != null && domainUser!.function == FunctionType.SystemAdmin) _buildDrawerItem(Icons.dashboard, 'Dokterspaneel', context, 3, false),
          if (domainUser != null && domainUser!.function == FunctionType.Nurse) _buildDrawerItem(Icons.supervised_user_circle, 'Patiënten ovezicht', context, 7, false),
          if (domainUser != null && domainUser!.function == FunctionType.SystemAdmin) _buildDrawerItem(Icons.dashboard, 'Verplegerspaneel', context, 8, false),
          if (domainUser != null && domainUser!.function == FunctionType.SystemAdmin) _buildDrawerItem(Icons.supervised_user_circle, 'Hoofdverplegerspaneel', context, 9, false),
          if (domainUser != null && domainUser!.function == FunctionType.Patient) _buildDrawerItem(Icons.campaign , 'Alert verpleegkundige', context, 10, false),
          if (domainUser != null && domainUser!.function != FunctionType.Patient) _buildDrawerItem(Icons.map, 'Vloerplan', context, 5, false),
          if (domainUser != null && domainUser!.function != FunctionType.Patient) _buildDrawerItem(Icons.assignment, 'Kamerindeling', context, 6, false),
          if (domainUser != null && (domainUser!.function == FunctionType.Nurse || domainUser!.function == FunctionType.Headnurse)) _buildDrawerItem(Icons.campaign, 'Alert Dokter', context, 13, false),
          if (domainUser != null && (domainUser!.function == FunctionType.Nurse || domainUser!.function == FunctionType.Headnurse)) _buildDrawerItem(Icons.send, 'Verzonden alerts ', context, 14, false),
          Divider(),
          if (widget.firebaseUser != null)
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Uitloggen'),
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
              SnackBar(content: Text('Gelieve eerst in te loggen!')),
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
        } else if (index == 7) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: NurseOverviewPage(),
                hasScaffold: true,
              ),
            ),
          );
        } else if (index == 8) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: NursePanel(),
                hasScaffold: true,
              ),
            ),
          );
        } else if (index == 11) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: NurseNotificationPage(userId: widget.firebaseUser!.uid),
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
        return DoctorPanel();
      case 4:
        return OverviewPage();
      case 5:
        return FloorplanPage(hospitalName: "UZ Groenplaats", initialFloorNumber: 0);
      case 6:
        return RoomAssignmentsPage();
      case 7:
        return NurseOverviewPage();
      case 8:
        return NursePanel();
      case 9:
        return HeadNursePanel();
      case 10:
        return AlertNursePage();
      case 11:
        return NurseNotificationPage(userId: domainUser!.id.toString());
      case 12:
        return PatientToNurseSentPage(userId: domainUser!.id.toString());
      case 13:
        return AlertDoctorPage();
      case 14:
        return NurseToDoctorSentPage(userId: domainUser!.id.toString());
      case 15:
        return DoctorNotificationPage(userId: domainUser!.id.toString());
      default:
        return HomePage();
    }
  }
}