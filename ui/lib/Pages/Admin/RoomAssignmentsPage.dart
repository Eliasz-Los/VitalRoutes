import 'package:flutter/material.dart';
import '../../Models/Room.dart';
import '../../Models/Users/AssignPatientToRoom.dart';
import '../../Models/Users/User.dart';
import '../../Services/RoomService.dart';
import '../../Services/UserService.dart';
import '../../Services/HospitalService.dart';

class RoomAssignmentsPage extends StatefulWidget {
  const RoomAssignmentsPage({super.key});

  @override
  RoomAssignmentsPageState createState() => RoomAssignmentsPageState();
}

class RoomAssignmentsPageState extends State<RoomAssignmentsPage> {
  final _roomService = RoomService();
  Map<int, List<Room>> _floors = {};
  List<User> _patients = [];
  String _message = '';
  List<int> _expandedFloors = [];
  int _minFloor = 0;
  int _maxFloor = 0;
  String _hospitalName = '';

  @override
  void initState() {
    super.initState();
    _fetchFloorsAndPatients();
  }

  Future<void> _fetchFloorsAndPatients() async {
    try {
      final hospital = await HospitalService.getHospital('UZ Groenplaats');
      _minFloor = hospital.minFloorNumber;
      _maxFloor = hospital.maxFloorNumber;
      _hospitalName = hospital.name;

      for (var floor = _minFloor; floor <= _maxFloor; floor++) {
        final rooms = await _roomService.getRooms('UZ Groenplaats', floor);
        _floors[floor] = rooms;
      }
      final allPatients = await UserService.getUsersByFunction('Patient');
      final assignedPatientIds = _floors.values.expand((rooms) => rooms).where((room) => room.assignedPatient != null).map((room) => room.assignedPatient!.id).toSet();
      _patients = allPatients.where((patient) => !assignedPatientIds.contains(patient.id)).toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Error: ${e.toString()}';
        });
      }
    }
  }

  void _toggleExpansion(int floor) {
    setState(() {
      if (_expandedFloors.contains(floor)) {
        _expandedFloors.remove(floor);
      } else {
        _expandedFloors.add(floor);
      }
    });
  }

  void _showAssignPatientDialog(Room room) {
    User? selectedPatient;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Patient to Room ${room.roomNumber}'),
          content: DropdownButtonFormField<User>(
            items: _patients.map((User patient) {
              return DropdownMenuItem<User>(
                value: patient,
                child: Text('${patient.firstName} ${patient.lastName}'),
              );
            }).toList(),
            onChanged: (User? newValue) {
              selectedPatient = newValue;
            },
            decoration: InputDecoration(labelText: 'Select Patient'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  if (selectedPatient != null) {
                    final dto = AssignPatientToRoom(
                      roomId: room.id,
                      patientId: selectedPatient!.id,
                    );
                    await _roomService.assignPatientToRoom(dto);
                    if (mounted) {
                      setState(() {
                        _message = 'Patient assigned successfully!';
                      });
                      Navigator.of(context).pop();
                      _fetchFloorsAndPatients();
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _message = 'Error: ${e.toString()}';
                    });
                  }
                }
              },
              child: Text('Assign'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removePatientFromRoom(Room room) async {
    try {
      final dto = AssignPatientToRoom(
        roomId: room.id,
        patientId: null,
      );
      await _roomService.assignPatientToRoom(dto);
      if (mounted) {
        setState(() {
          _message = 'Patient removed successfully!';
        });
        _fetchFloorsAndPatients();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Assignments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _floors.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    _toggleExpansion(_floors.keys.elementAt(index));
                  },
                  children: _floors.keys.map<ExpansionPanel>((int floor) {
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text('Floor $floor'),
                          onTap: () => _toggleExpansion(floor),
                        );
                      },
                      body: Column(
                        children: _floors[floor]!.map<Widget>((Room room) {
                          return ListTile(
                            title: Text('Room ${room.roomNumber}'),
                            subtitle: Text(room.assignedPatient != null
                                ? 'Assigned Patient: ${room.assignedPatient!.firstName} ${room.assignedPatient!.lastName}'
                                : 'No patient assigned'),
                            onTap: () => _showAssignPatientDialog(room),
                            trailing: room.assignedPatient != null
                                ? IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removePatientFromRoom(room),
                            )
                                : null,
                          );
                        }).toList(),
                      ),
                      isExpanded: _expandedFloors.contains(floor),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}