import 'dart:async';
import 'package:flutter/material.dart';
import '../../Services/BluetoothService.dart';
import '../../Services/PermissionService.dart';
import '../../Services/SensorFusionService.dart';

class UserPosition extends StatefulWidget {

  const UserPosition({Key? key}) : super(key: key);

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
          final refinedPosition = _sensorFusionService.refinePosition(estimatedPosition);
          setState(() {
            _userPosition = refinedPosition;
          });
        });
  }

  /*Future<Map<String, double>> _correctPosition(Map<String, double> position) async {
    int x = position['x']!.toInt();
    int y = position['y']!.toInt();
    if (await isValidPosition(x, y)) {
      return position;
    } else {
      return _findNearestValidPosition(x, y);
    }
  }

  Future<bool> isValidPosition(int x, int y) async {
    final ByteData? byteData = await widget.floorplanImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return false;

    final int pixelIndex = (y * widget.floorplanImage.width + x) * 4;
    final int red = byteData.getUint8(pixelIndex);
    final int green = byteData.getUint8(pixelIndex + 1);
    final int blue = byteData.getUint8(pixelIndex + 2);

    return !(red == 0 && green == 0 && blue == 0);
  }

  Future<Map<String, double>> _findNearestValidPosition(int x, int y) async {
    Queue<List<int>> queue = Queue();
    Set<List<int>> visited = {};

    queue.add([x, y]);
    visited.add([x, y]);

    List<List<int>> directions = [
      [0, 1], [1, 0], [0, -1], [-1, 0], // Right, Down, Left, Up
      [1, 1], [1, -1], [-1, 1], [-1, -1] // Diagonals
    ];

    while (queue.isNotEmpty) {
      List<int> current = queue.removeFirst();
      int currentX = current[0];
      int currentY = current[1];

      if (await isValidPosition(currentX, currentY)) {
        return {'x': currentX.toDouble(), 'y': currentY.toDouble()};
      }

      for (List<int> direction in directions) {
        int newX = currentX + direction[0];
        int newY = currentY + direction[1];

        if (!visited.contains([newX, newY])) {
          queue.add([newX, newY]);
          visited.add([newX, newY]);
        }
      }
    }

    return {'x': 0.0, 'y': 0.0};
  }*/

  @override
  Widget build(BuildContext context) {
    if (_userPosition['x'] == 0.0 && _userPosition['y'] == 0.0) {
      return SizedBox.shrink();
    }

    return Positioned(
      left: _userPosition['x']!,
      top: _userPosition['y']!,
      child: Icon(Icons.person_pin_circle, color: Colors.deepPurple, size: 20),
    );
  }
}