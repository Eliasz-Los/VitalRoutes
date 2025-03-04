import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Services/UserService.dart';
import '../../Models/Users/User.dart' as domain;
import '../../Models/Enums/FunctionType.dart';
import '../Navigation/MainScaffold.dart';
import 'NursePanel.dart';

class NurseOverviewPage extends StatefulWidget {
  @override
  _NurseOverviewPageState createState() => _NurseOverviewPageState();
}

class _NurseOverviewPageState extends State<NurseOverviewPage> {
  List<domain.User> patients = [];
  List<domain.User> filteredPatients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

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
        SnackBar(content: Text('Error fetching supervisions: $e')),
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
          SnackBar(content: Text('Patient removed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting patient: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(
                body: NursePanel(),
                hasScaffold: true,
              ),
            ),
          ).then((_) {
            setState(() {
              patients.clear();
              filteredPatients.clear();
              isLoading = true;
            });
            _fetchSupervisions();
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
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
        'Patients Overview',
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
          hintText: 'Search patients by name...',
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
                          'Active',
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
                        title: Text('Confirm Removal'),
                        content: Text('Are you sure you want to remove ${user.firstName} ${user.lastName}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Remove'),
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
                  icon: Icon(FontAwesomeIcons.mapMarkerAlt, size: 24, color: Colors.blue),
                  onPressed: () {
                    // Eventueeel map-functionaliteit toevoegen
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