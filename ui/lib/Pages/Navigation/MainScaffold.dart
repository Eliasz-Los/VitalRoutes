import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Enums/FunctionType.dart';
import 'package:ui/Pages/Users/UserProvider.dart';
import '../../Pages/Users/SignInScreen.dart';
import '../../Pages/Users/UserProfileScreen.dart';
import 'custom_drawer.dart';
import '../../Services/AuthService.dart';
import '../../Services/NotificationService.dart';
import '../../Services/UserService.dart';
import '../../Models/NotificationModel.dart';
import '../../Models/Users/User.dart' as domain;
import '../Alert/NurseNotificationPage.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final bool hasScaffold;

  const MainScaffold({
    required this.body,
    this.hasScaffold = false,
    Key? key,
  }) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  User? firebaseUser;
  domain.User? domainUser;
  List<NotificationModel> notifications = [];
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    firebaseUser = Provider.of<UserProvider>(context, listen: false).user;
    _fetchDomainUser();
  }

  Future<void> _fetchDomainUser() async {
    if (firebaseUser != null) {
      try {
        domainUser = await UserService.getUserByEmail(firebaseUser!.email!);
        Provider.of<UserProvider>(context, listen: false).setUser(firebaseUser, domainUser);
        _fetchNotifications();
        _startNotificationPolling();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ophalen domein gebruiker: $e')),
        );
      }
    }
  }

  void _startNotificationPolling() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchNotifications();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchNotifications() async {
    if (domainUser != null) {
      try {
        final data = await NotificationService.getNotificationsForNurse(domainUser!.id.toString());
        setState(() {
          notifications = data;
        });
      } catch (e) {
        debugPrint('Error ophalen notificaties: $e');
      }
    }
  }

  /// Deze methode laat zien hoeveel notificaties 'Te behandelen' zijn.
  /// We filteren notifications op status == 'Te behandelen'.
  int get teBehandelenCount {
    return notifications.where((n) => n.status == 'Te behandelen').length;
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
        SnackBar(content: Text('Error bij uitloggen: $e')),
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
            Text(
              'VitalRoutes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            if (firebaseUser != null)
              Text(
                firebaseUser!.email ?? 'User',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Colors.indigo,
        actions: [
          if (firebaseUser != null && domainUser != null && domainUser!.function != FunctionType.Patient)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    _showNotificationsDropdown(context);
                  },
                ),
                // Als er teBehandelen notificaties zijn, toon het rode badge
                if (teBehandelenCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: GestureDetector(
                      onTap: () {
                        _showNotificationsDropdown(context);
                      },
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
                          '$teBehandelenCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (firebaseUser != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profiel') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(firebaseUser: firebaseUser!),
                    ),
                  );
                } else if (value == 'uitloggen') {
                  _signOut(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profiel',
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.black),
                    title: Text('Profiel'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'uitloggen',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.black),
                    title: Text('Uitloggen'),
                  ),
                ),
              ],
              icon: Icon(Icons.person, color: Colors.white),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      drawer: CustomDrawer(
        onItemSelected: _onItemTapped,
        firebaseUser: firebaseUser,
      ),
      body: widget.body,
    );
  }

  /// Hier laten we enkel de "Te behandelen" notificaties in de pop-up zien.
  void _showNotificationsDropdown(BuildContext context) {
    // Filter enkel notificaties die 'Te behandelen' zijn
    final teBehandelenList = notifications
        .where((n) => n.status == 'Te behandelen')
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notificaties'),
          content: Container(
            width: double.maxFinite,
            child: teBehandelenList.isEmpty
                ? Text('Geen te behandelen notificaties')
                : ListView.builder(
              shrinkWrap: true,
              itemCount: teBehandelenList.length,
              itemBuilder: (BuildContext context, int index) {
                final notification = teBehandelenList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.amber.shade600, width: 2),
                  ),
                  child: ListTile(
                    title: Text(
                      notification.patientName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${notification.status}',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          'Kamer: ${notification.roomNumber}',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          'Boodschap: ${notification.message}',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.navigation, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScaffold(
                            body: NurseNotificationPage(userId: firebaseUser!.uid),
                            hasScaffold: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Sluiten'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
