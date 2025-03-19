import 'dart:async';
import 'package:flutter/material.dart';
import '../../Services/BluetoothService.dart';
import '../../Services/PermissionService.dart';
import '../../Services/SensorFusionService.dart';
import '../../Models/Point.dart';

class UserPosition extends StatefulWidget {
  final Function(Point) onPositionUpdated; // Add this callback

  const UserPosition({Key? key, required this.onPositionUpdated})
      : super(key: key);

  @override
  _UserPositionState createState() => _UserPositionState();
}

class _UserPositionState extends State<UserPosition> {
  final BluetoothService _bluetoothService = BluetoothService();
  final PermissionService _permissionService = PermissionService();
  final SensorFusionService _sensorFusionService = SensorFusionService();
  late Map<String, double> _userPosition;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _userPosition = {'x': 0.0, 'y': 0.0};
    _checkAndRequestPermissions();
    Future.microtask(() => _startUpdatingPosition());
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
      final estimatedPosition = _bluetoothService.getEstimatedPosition();
      final refinedPosition =
          _sensorFusionService.refinePosition(estimatedPosition);
      setState(() {
        _userPosition = refinedPosition;
        widget.onPositionUpdated(Point(
            x: _userPosition['x']!, y: _userPosition['y']!)); // Notify parent
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _userPosition['x']!,
      top: _userPosition['y']!,
      child: Icon(Icons.person_pin_circle, color: Colors.deepPurple, size: 20),
    );
  }
}
