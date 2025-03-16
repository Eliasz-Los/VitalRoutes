import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/NotificationService.dart';
import 'package:ui/Services/UserService.dart';
import 'package:ui/Models/NotificationModel.dart';
import 'package:ui/Models/Users/User.dart' as domain;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Pages/Users/UserProvider.dart';

class NurseToDoctorSentPage extends StatefulWidget {
  final String userId;

  const NurseToDoctorSentPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NurseToDoctorSentPageState createState() => _NurseToDoctorSentPageState();
}

class _NurseToDoctorSentPageState extends State<NurseToDoctorSentPage> {
  User? firebaseUser;
  domain.User? domainUser;
  List<NotificationModel> sentNotifications = [];

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
        _fetchSentNotifications();
        _startPolling();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij ophalen Nurse user: $e')),
        );
      }
    }
  }

  void _startPolling() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchSentNotifications();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchSentNotifications() async {
    if (domainUser == null) return;
    try {
      final data = await NotificationService.getSentNotificationsForNurse(domainUser!.id.toString());
      setState(() {
        sentNotifications = data;
      });
    } catch (e) {
      debugPrint('Fout bij ophalen notificaties nurse->doctor: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            Text(
              "Mijn verstuurde notificaties",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: sentNotifications.isEmpty
                  ? Center(
                child: Text(
                  'Nog geen meldingen verstuurd.',
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: sentNotifications.length,
                itemBuilder: (context, index) {
                  final notif = sentNotifications[index];
                  final bool isTeBehandelen = notif.status == 'Te behandelen';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    color: isTeBehandelen ? Colors.white : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isTeBehandelen ? Colors.amber : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notificatie voor: ${notif.message}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),

                          Text(
                            isTeBehandelen
                                ? "Status: Verzonden"
                                : "Status: Verwerkt",
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          SizedBox(height: 6),

                          Text(
                            "Kamer: ${notif.roomNumber}",
                            style: TextStyle(fontSize: 17, color: Colors.black),
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
