import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ui/Pages/Floorplan/FloorplanScreen.dart';
import '../../Services/UserService.dart';
import '../../Models/Users/User.dart' as domain;
import '../../Models/Enums/FunctionType.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<domain.User> nurses = [];
  List<domain.User> patients = [];
  List<domain.User> filteredNurses = [];
  List<domain.User> filteredPatients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSupervisions();
    searchController.addListener(_filterUsers);
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
        final domain.User doctor = await UserService.getUserByEmail(user.email!);
        if (doctor.underSupervisions != null && doctor.underSupervisions!.isNotEmpty) {
          for (String id in doctor.underSupervisions!) {
            final domain.User supervisee = await UserService.getUserById(id);
            if (supervisee.function == FunctionType.Nurse) {
              nurses.add(supervisee);
            } else if (supervisee.function == FunctionType.Patient) {
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
        filteredNurses = nurses;
        filteredPatients = patients;
      });
    }
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNurses = nurses.where((nurse) {
        final fullName = '${nurse.firstName} ${nurse.lastName}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
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
        final domain.User doctor = await UserService.getUserByEmail(currentUser.email!);
        await UserService.removeUnderSupervision(doctor.id!, user.id!);
        setState(() {
          if (user.function == FunctionType.Nurse) {
            nurses.remove(user);
            filteredNurses.remove(user);
          } else if (user.function == FunctionType.Patient) {
            patients.remove(user);
            filteredPatients.remove(user);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gebruiker succesvol verwijderd')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verwijderen gebruiker: $e')),
      );
    }
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
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Verpleegkundigen'),
                      SizedBox(height: 10),
                      filteredNurses.isEmpty
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Geen verpleegkundigen gevonden', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                          : Column(
                        children: filteredNurses.map((nurse) => _buildUserCard(nurse)).toList(),
                      ),
                      SizedBox(height: 30),
                      _buildSectionTitle('Patiënten'),
                      SizedBox(height: 10),
                      filteredPatients.isEmpty
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Geen patiënten gevonden', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                          : Column(
                        children: filteredPatients.map((patient) => _buildUserCard(patient)).toList(),
                      ),
                    ],
                  ),
                ),
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
        'Overzicht supervisies',
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
          hintText: 'Zoek op naam...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              searchController.clear();
              _filterUsers();
            },
          )
              : null,
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildUserCard(domain.User user) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
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
                        content: Text('Wil je zeker gebruiker ${user.firstName} ${user.lastName} verwijderen?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Annuleren'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Verwijder'),
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
                  onPressed: () {
                    //TODO doorsturen naar FloorplanScreen
                  /*  Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => FloorplanPage(hospitalName: "UZ Groenplaats",
                            initialFloorNumber: -1, start)));*/
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

}