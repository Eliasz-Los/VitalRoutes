import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/NotificationService.dart';
import 'package:ui/Services/UserService.dart';
import 'package:ui/Models/NotificationModel.dart';
import 'package:ui/Models/Users/User.dart' as domain;
import 'package:ui/Pages/Users/UserProvider.dart';

import '../Navigation/MainScaffold.dart';

class NurseNotificationPage extends StatefulWidget {
  final String userId;

  NurseNotificationPage({required this.userId, Key? key}) : super(key: key);

  @override
  _NurseNotificationPageState createState() => _NurseNotificationPageState();
}

class _NurseNotificationPageState extends State<NurseNotificationPage> {
  User? firebaseUser;
  domain.User? domainUser;
  List<NotificationModel> notifications = [];

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
          SnackBar(content: Text('Error fetching domain user: $e')),
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
        debugPrint('Error fetching notifications: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Notificaties',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16),
            Expanded(
              child: notifications.isEmpty
                  ? Center(child: Text('Geen notificaties'))
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.amber.shade600, width: 2),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        notification.patientName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${notification.status}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Kamer: ${notification.roomNumber}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Boodschap: ${notification.message}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.navigation, color: Colors.black),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScaffold(
                              body: NurseNotificationPage(userId: widget.userId),
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
          ],
        ),
      ),
    );
  }
}