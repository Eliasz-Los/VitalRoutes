import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import '../../Models/Enums/FunctionType.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import '../Admin/RoomAssignmentsPage.dart';
import '../Admin/DoctorPanel.dart';
import '../Alert/NurseNotificationPage.dart';
import '../Floorplan/FloorplanScreen.dart';
import '../home_page.dart';
import 'custom_drawer.dart';
import '../../Services/AuthService.dart';
import '../../Services/NotificationService.dart';
import '../../Models/NotificationModel.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final bool hasScaffold;

  MainScaffold({required this.body, this.hasScaffold = false, Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  User? user;
  List<NotificationModel> notifications = [];
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;

    Future.delayed(Duration.zero, () {
      _fetchNotifications();
    });

    _pages = [
      HomePage(),
      SignInScreen(),
      if (user != null) UserProfileScreen(firebaseUser: user!),
      DoctorPanel(),
      FloorplanPage(hospitalName: "UZ Groenplaats", initialFloorNumber: 0),
      if (user != null) RoomAssignmentsPage(),
    ];
  }
  
  Future<void> _fetchNotifications() async {
    if (user != null) {
      // Controleer of de gebruiker een Nurse of HeadNurse is
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final domainUser = userProvider.domainUser;
      
      if (domainUser != null &&
          (domainUser.function == FunctionType.Nurse || domainUser.function == FunctionType.Headnurse)) {
        try {
          final data = await NotificationService.getNotificationsForNurse(user!.uid);
          setState(() {
            notifications = data;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching notifications: $e')),
          );
        }
      }
    }
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
      Provider.of<UserProvider>(context, listen: false).setUser(null, null);
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
            Text('VitalRoutes', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),),
            if (user != null)
              Text(user!.email ?? 'User', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          if (user != null) Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notifications'),
                      content: notifications.isEmpty
                          ? Text('No notifications')
                          : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            title: Text(notification.patientName),
                            subtitle: Text('Urgency: ${notification.emergencyLevel}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NurseNotificationPage(nurseId: user!.uid),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          if (user != null) PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(firebaseUser: user!),
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