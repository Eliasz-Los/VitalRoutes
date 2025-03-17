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
  final Point? initialStartPoint;
  final Point? initialEndPoint;
  final bool? isPathfindingEnabledFromParams;

  const FloorplanPage({
    Key? key,
    required this.hospitalName,
    required this.initialFloorNumber,
    this.initialStartPoint,
    this.initialEndPoint,
    this.isPathfindingEnabledFromParams,
  }) : super(key: key);

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

    // Ophalen min/max floors
    HospitalService.getHospital(widget.hospitalName).then((hospital) {
      _maxFloorNumber = hospital.maxFloorNumber;
      _minFloorNumber = hospital.minFloorNumber;
    });

    _currentFloorNumber = widget.initialFloorNumber;
    _startPoint = widget.initialStartPoint;
    _endPoint = widget.initialEndPoint;
    _isPathfindingEnabled = widget.isPathfindingEnabledFromParams ?? false;

    // Als start/end meteen aanwezig en pathfinding aanstaat => route laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_startPoint != null && _endPoint != null && _isPathfindingEnabled) {
        _fetchPath(_startPoint!, _endPoint!);
      }
    });
  }

  Future<custom_user.User?> _getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return await UserService.getUserByEmail(firebaseUser.email!);
    }
    return null;
  }

  void _incrementFloor() {
    if (_currentFloorNumber < _maxFloorNumber) {
      setState(() {
        _currentFloorNumber++;
        // Reset path
        _path = [];
        _startPoint = null;
        _endPoint = null;
      });
    }
  }

  void _decrementFloor() {
    if (_currentFloorNumber > _minFloorNumber) {
      setState(() {
        _currentFloorNumber--;
        // Reset path
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

  Future<void> _fetchPath(Point start, Point end) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fetching path...'),
        backgroundColor: Colors.green,
        duration: Duration(minutes: 1),
      ),
    );

    try {
      final path = await PathService.getPath(
        start,
        end,
        widget.hospitalName,
        _currentFloorNumber,
      );
      setState(() {
        _path = path;
      });
    } catch (e) {
      debugPrint('Error fetching path: $e');
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _isPathfindingEnabled = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        title: Text(
          'Verdieping $_currentFloorNumber',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: _incrementFloor,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5, // 50% of screen
                  margin: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localOffset = box.globalToLocal(details.globalPosition);
                      debugPrint('Coordinates: (${localOffset.dx}, ${localOffset.dy})');
                    },
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.1,
                      maxScale: 4,
                      child: Stack(
                        children: [
                          FloorplanImage(
                            hospitalName: widget.hospitalName,
                            floorNumber: _currentFloorNumber,
                            isPathfindingEnabled: _isPathfindingEnabled,
                            path: _path,
                            startPoint: _startPoint,
                            endPoint: _endPoint,
                            onPathUpdated: _updatePath,
                          ),
                          RoomLocations(
                            user: user,
                            floorNumber: _currentFloorNumber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Instructie-sectie
                Container(
                  margin: const EdgeInsets.only(top: 0, left: 16, right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "Navigatie Instructies",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Om van punt A naar punt B te navigeren, tik je op het kaart-icoontje zodat "
                            "het donker wordt.\nVervolgens tik je op de kaart om jouw begin- en eindpunt "
                            "te selecteren. \nDe route wordt automatisch getekend.\n"
                            "Met de pijltjes (omhoog/omlaag) kun je van verdieping wisselen.\n",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ), // evt. extra spacer
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}