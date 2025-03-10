import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/BluetoothService.dart';
import '../../Services/HospitalService.dart';
import '../../Services/PermissionService.dart';
import '../../Services/UserService.dart';
import 'FloorplanImage.dart';
import 'RoomLocations.dart';
import '../../Models/Users/User.dart' as custom_user;

class FloorplanPage extends StatefulWidget {
  final String hospitalName;
  final int initialFloorNumber;

  const FloorplanPage({super.key, required this.hospitalName, required this.initialFloorNumber});

  @override
  FloorplanPageState createState() => FloorplanPageState();
}

class FloorplanPageState extends State<FloorplanPage> {
  late int _currentFloorNumber;
  late int _maxFloorNumber;
  late int _minFloorNumber;
  final PermissionService _permissionService = PermissionService();
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    HospitalService.getHospital(widget.hospitalName).then((hospital) {
      _maxFloorNumber = hospital.maxFloorNumber;
      _minFloorNumber = hospital.minFloorNumber;
    });
    _currentFloorNumber = widget.initialFloorNumber;
    _checkAndRequestPermissions();
  }

  Future<custom_user.User?> _getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return await UserService.getUserByEmail(firebaseUser.email!);
    }
    return null;
  }

  void _checkAndRequestPermissions() async {
    if (await _permissionService.requestPermissions()) {
      _bluetoothService.startScan(context);
    }
  }
  
  void _incrementFloor() {
    if(_currentFloorNumber < _maxFloorNumber) {
      setState(() {
        _currentFloorNumber++;
      });
    }
  }

  void _decrementFloor() {
    if(_currentFloorNumber > _minFloorNumber) {
      setState(() {
        _currentFloorNumber--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floorplan of ${widget.hospitalName} - Floor $_currentFloorNumber'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: _incrementFloor,
          ),
          IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: _decrementFloor,
          ),
        ],
      ),
      body: FutureBuilder<custom_user.User?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final user = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localOffset = box.globalToLocal(details.globalPosition);
                      print('Coordinates: (${localOffset.dx}, ${localOffset.dy})');
                    },
                    child: InteractiveViewer(
                      boundaryMargin: EdgeInsets.all(20),
                      minScale: 0.1,
                      maxScale: 4,
                      child: Stack(
                        children: [
                          FloorplanImage(hospitalName: widget.hospitalName, floorNumber: _currentFloorNumber),
                          RoomLocations(user: user, floorNumber: _currentFloorNumber),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}