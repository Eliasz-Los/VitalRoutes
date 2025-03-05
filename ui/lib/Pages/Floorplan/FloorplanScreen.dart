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
/*TODO: Fix zooming in, show 2 points from a to b and lets perhaps add a button for that so its easier*/
class FloorplanPageState extends State<FloorplanPage> {
  late int _currentFloorNumber;
  late int _maxFloorNumber;
  late int _minFloorNumber;
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

  Future<void> _fetchPath(Point start, Point end) async{
    final response = await PathService.getPath(start, end, widget.hospitalName, "floor_minus1C.png");
    setState(() {
      _path = response;
    });
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
  
  //TODO dit is gay goe nachecken
  void _handleTap(TapDownDetails details){
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    
    final double scaledX = localOffset.dx *10.77; //TODO hardcoded scaling
    final double scaledY = localOffset.dy *7.46;
    final Point point = Point(x: scaledX.roundToDouble(), y: scaledY.roundToDouble());
    
    if(_startPoint == null){
      setState(() {
        _startPoint = point;
        print('Start point set: $_startPoint');
      });
    } else if(_endPoint == null){
      setState(() {
        _endPoint = point;
        print('End point set: $_endPoint');
        //1507.0,1148.0),room -100 (2096.0,1466.0)
        // _fetchPath(Point(x: 1507.0, y: 1148.0), Point(x: 2096.0, y: 1466.0));
        _fetchPath(_startPoint!, _endPoint!);

      });
    } else {
      setState(() {
        _startPoint = point;
        _endPoint = null;
        _path = [];
        print('Start point reset: $_startPoint');
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
                      onTapDown: _handleTap(details);
           /*           final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localOffset = box.globalToLocal(details.globalPosition);
                      print('Coordinates: (${localOffset.dx}, ${localOffset.dy})');*/
                    },
                    child: InteractiveViewer(
                      boundaryMargin: EdgeInsets.all(20),
                      minScale: 0.1,
                      maxScale: 4,
                      child: Stack(
                        children: [
                          FloorplanImage(hospitalName: widget.hospitalName, floorNumber: _currentFloorNumber, path: _path),
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