import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSupervisions();
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
        SnackBar(content: Text('Error fetching supervisions: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(domain.User user) async {
    try {
      final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final domain.User doctor = await UserService.getUserByEmail(currentUser.email!);
        await UserService.removeUnderSupervision(doctor.id!, user.id!);
        setState(() {
          nurses.remove(user);
          patients.remove(user);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Overview Supervisions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Nurses'),
            SizedBox(height: 10),
            ...nurses.map((nurse) => _buildUserTile(nurse)),

            SizedBox(height: 30),

            _buildSectionTitle('Patients'),
            SizedBox(height: 10),
            ...patients.map((patient) => _buildUserTile(patient)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(domain.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${user.firstName} ${user.lastName}',
            style: TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () => _deleteUser(user),
              ),
              SizedBox(width: 10),
              Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Colors.blue,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}