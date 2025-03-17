import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/NotificationService.dart';
import 'package:ui/Services/UserService.dart';
import 'package:ui/Models/NotificationModel.dart';
import 'package:ui/Models/Users/User.dart' as domain;
import 'package:ui/Pages/Users/UserProvider.dart';
import 'package:ui/Models/Point.dart' as custom_point;
import '../../Models/Room.dart';
import '../../Services/RoomService.dart';
import '../Floorplan/FloorplanScreen.dart';
import '../Navigation/MainScaffold.dart';

class DoctorNotificationPage extends StatefulWidget {
  final RoomService roomService = RoomService();
  final String userId;

  DoctorNotificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _DoctorNotificationPageState createState() => _DoctorNotificationPageState();
}

class _DoctorNotificationPageState extends State<DoctorNotificationPage> {
  User? firebaseUser;
  domain.User? domainUser;
  List<NotificationModel> notifications = [];

  Map<String, String> selectedStatuses = {};

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
          SnackBar(content: Text('Fout bij ophalen doctor-user: $e')),
        );
      }
    }
  }

  Future<void> navigateToFloorplanForNurse(BuildContext context, NotificationModel notification) async {
    try {
      final domain.User patientUser = await UserService.getUserById(notification.userId);

      final Room userRoom = await widget.roomService.getRoomByUserId(patientUser.id!);

      int floorNumber = 1;
      if (userRoom.roomNumber < 0) {
        floorNumber = (userRoom.roomNumber ~/ 100);
      } else {
        String numStr = userRoom.roomNumber.toString();
        floorNumber = int.parse(numStr[0]);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScaffold(
              body: FloorplanPage(
                hospitalName: 'UZ Groenplaats',
                initialFloorNumber: floorNumber,
                initialStartPoint: custom_point.Point(x: 807.0, y: 1289.0),
                initialEndPoint: userRoom.point,
                isPathfindingEnabledFromParams: true,
              ),
              hasScaffold: true,
            )
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij navigeren naar Floorplan: $e')),
      );
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
    if (domainUser == null) return;
    try {
      final data = await NotificationService.getNotificationsForDoctor(domainUser!.id.toString());
      setState(() {
        notifications = data;
        for (var notif in data) {
          selectedStatuses.putIfAbsent(notif.id, () => notif.status);
        }
      });
    } catch (e) {
      debugPrint('Fout bij ophalen doctor-notificaties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  final notif = notifications[index];
                  final dbStatus = notif.status;
                  final currSelectedStatus = selectedStatuses[notif.id] ?? dbStatus;
                  final isBehandeld = (dbStatus == 'Behandeld');

                  return Card(
                    color: isBehandeld ? Colors.grey[350] : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: isBehandeld
                          ? BorderSide(color: Colors.transparent, width: 0)
                          : BorderSide(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],  
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  notif.userName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kamer: ${notif.roomNumber}',
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          Text(
                            'Boodschap: ${notif.message}',
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          // Status
                          Text(
                            'Status:',
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          DropdownButton<String>(
                            value: currSelectedStatus,
                            style: TextStyle(fontSize: 17, color: Colors.black),
                            items: ['Te behandelen', 'In behandeling', 'Behandeld']
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedStatuses[notif.id] = val;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await NotificationService.updateNotificationStatus(
                                      notif.id,
                                      currSelectedStatus,
                                    );
                                    _fetchNotifications();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Update gelukt',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Fout bij updaten status: $e'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent.shade700,
                                ),
                                child: Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.navigation, size: 44, color: Colors.blue),
                                onPressed: () async {
                                  await navigateToFloorplanForNurse(context, notif);
                                },
                              ),
                            ],
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
