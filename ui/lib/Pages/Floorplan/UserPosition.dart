import 'dart:async';
import 'package:flutter/material.dart';
import '../../Services/BluetoothService.dart';
import '../../Services/PermissionService.dart';

class UserPosition extends StatefulWidget {
  const UserPosition({Key? key}) : super(key: key);

  @override
  _UserPositionState createState() => _UserPositionState();
}

class _UserPositionState extends State<UserPosition> {
  final BluetoothService _bluetoothService = BluetoothService();
  final PermissionService _permissionService = PermissionService();
  Map<String, double> _userPosition = {'x': 0.0, 'y': 0.0};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _startUpdatingPosition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bluetoothService.stopScan();
    super.dispose();
  }

  void _checkAndRequestPermissions() async {
    if (await _permissionService.requestPermissions()) {
      _bluetoothService.startScan(context);
    }
  }

  void _startUpdatingPosition() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _userPosition = _bluetoothService.getEstimatedPosition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _userPosition['x'],
      top: _userPosition['y'],
      child: Icon(Icons.person_pin_circle, color: Colors.deepPurple, size: 30),
    );
  }
}