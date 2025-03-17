import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ui/Models/Room.dart';
import 'package:ui/Services/RoomService.dart';
import '../../Services/UserService.dart';
import '../../Models/Users/User.dart' as domain;
import '../../Models/Enums/FunctionType.dart';
import '../Floorplan/FloorplanScreen.dart';
import 'package:ui/Models/Point.dart' as custom_point;
import '../Navigation/MainScaffold.dart';

class NurseOverviewPage extends StatefulWidget {
  @override
  _NurseOverviewPageState createState() => _NurseOverviewPageState();
}

class _NurseOverviewPageState extends State<NurseOverviewPage> {
  List<domain.User> patients = [];
  List<domain.User> filteredPatients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  final RoomService roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _fetchSupervisions();
    searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSupervisions() async {
    try {
      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final domain.User nurse = await UserService.getUserByEmail(user.email!);
        if (nurse.underSupervisions != null && nurse.underSupervisions!.isNotEmpty) {
          for (String id in nurse.underSupervisions!) {
            final domain.User supervisee = await UserService.getUserById(id);
            if (supervisee.function == FunctionType.Patient) {
              patients.add(supervisee);
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ophalen supervisies: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        filteredPatients = patients;
      });
    }
  }

  void _filterPatients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPatients = patients.where((patient) {
        final fullName = '${patient.firstName} ${patient.lastName}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteUser(domain.User user) async {
    try {
      final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final domain.User nurse = await UserService.getUserByEmail(currentUser.email!);
        await UserService.removeUnderSupervision(nurse.id!, user.id!);
        setState(() {
          patients.remove(user);
          _filterPatients();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patiënt succesvol verwijderd!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verwijderen patiënt: $e')),
      );
    }
  }

  void navigateToFloorplan(BuildContext context, RoomService roomService, domain.User user) async {
    final Room userRoom = await roomService.getRoomByUserId(user.id!);
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
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildTitle(),
            SizedBox(height: 10),
            _buildSearchBar(),
            SizedBox(height: 30),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredPatients.isEmpty
                  ? Center(
                child: Text(
                  'Nog geen patiënten gekoppeld.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) => _buildPatientCard(filteredPatients[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Patiënten overzicht',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Zoek patiënten op naam...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              searchController.clear();
              _filterPatients();
            },
          )
              : null,
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildPatientCard(domain.User user) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue[200],
                  child: Text(
                    user.firstName != null && user.firstName!.isNotEmpty ? user.firstName![0] : '?',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Actief',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.delete, size: 24, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bevestig het verwijderen'),
                        content: Text('Wil je zeker patiënt ${user.firstName} ${user.lastName} verwijderen?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Annuleren'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Verwijderen'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _deleteUser(user);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.locationDot, size: 24, color: Colors.blue),
                  onPressed: () async {
                   navigateToFloorplan(context, roomService, user);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}