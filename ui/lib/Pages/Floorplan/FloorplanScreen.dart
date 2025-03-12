import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui/Models/Point.dart';
import 'package:ui/Services/PathService.dart';
import '../../Services/HospitalService.dart';
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
  bool _isPathfindingEnabled = false;
  List<Point> _path = [];
  Point? _startPoint;
  Point? _endPoint;

  @override
  void initState() {
    super.initState();
    HospitalService.getHospital(widget.hospitalName).then((hospital) {
      _maxFloorNumber = hospital.maxFloorNumber;
      _minFloorNumber = hospital.minFloorNumber;
    });
    _currentFloorNumber = widget.initialFloorNumber;
  }

  Future<custom_user.User?> _getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return await UserService.getUserByEmail(firebaseUser.email!);
    }
    return null;
  }
  
  void _incrementFloor() {
    if(_currentFloorNumber < _maxFloorNumber) {
      setState(() {
        _currentFloorNumber++;
        _path = [];
        _startPoint = null;
        _endPoint = null;
      });
    }
  }

  void _decrementFloor() {
    if(_currentFloorNumber > _minFloorNumber) {
      setState(() {
        _currentFloorNumber--;
        _path = [];
        _startPoint = null;
        _endPoint = null;
      });
    }
  }
  
  void _togglePathfinding() {
    setState(() {
      _isPathfindingEnabled = !_isPathfindingEnabled;
    });
  }

  void _updatePath(List<Point> path, startPoint, endPoint) {
    setState(() {
      _path = path;
      _startPoint = startPoint;
      _endPoint = endPoint;
    });
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
          IconButton(
              icon: Icon(_isPathfindingEnabled ? Icons.map : Icons.map_outlined),
            onPressed: _togglePathfinding,
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
                          FloorplanImage(hospitalName: widget.hospitalName, 
                              floorNumber: _currentFloorNumber,
                              isPathfindingEnabled: _isPathfindingEnabled,
                              path: _path,
                              startPoint: _startPoint,
                              endPoint: _endPoint,
                              onPathUpdated: _updatePath),
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