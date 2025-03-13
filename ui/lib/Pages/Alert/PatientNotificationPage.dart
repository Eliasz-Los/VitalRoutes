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

class PatientNotificationPage extends StatefulWidget {
  final String userId;

  PatientNotificationPage({required this.userId, Key? key}) : super(key: key);

  @override
  _PatientNotificationPageState createState() => _PatientNotificationPageState();
}

class _PatientNotificationPageState extends State<PatientNotificationPage> {
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
          SnackBar(content: Text('Error ophalen domein gebruiker: $e')),
        );
      }
    }
  }

  void _startNotificationPolling() {
    Timer.periodic(Duration(seconds: 3), (timer) {
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
        final data = await NotificationService.getNotificationsForPatient(domainUser!.id.toString());
        setState(() {
          notifications = data;
        });
      } catch (e) {
        debugPrint('Error ophalen patiënt notificaties: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // Vetgedrukte titel, gecentreerd
            Text(
              "Mijn verstuurde notificaties",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            // Lijst met notificaties
            Expanded(
              child: notifications.isEmpty
                  ? Center(child: Text('Nog geen meldingen verstuurd.'))
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final bool isTeBehandelen = notif.status == 'Te behandelen';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6), // Kleiner maken
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.amber, width: 2), // Gouden rand
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0), // Minder padding
                      child: Column(
                        children: [
                          // Grote, vetgedrukte, gecentreerde titel
                          Text(
                            "Notificatie voor ${notif.message}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),

                          // Status
                          Text(
                            isTeBehandelen
                                ? "Status: Verzonden (nog niet opgepakt)"
                                : "Status: Verwerkt (opgepakt)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          SizedBox(height: 4),

                          // Kamerinfo
                          Text(
                            "Kamer: ${notif.roomNumber}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                          ),
                        ],
                      ),
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
