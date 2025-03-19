import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:ui/Services/PermissionService.dart';
import 'package:ui/Services/PositioningService.dart';
import 'ScalingService.dart';

class BluetoothService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final PositioningService _positioningService = PositioningService();
  StreamSubscription? _scanSubscription;
  final Set<DiscoveredDevice> _scannedBeacons = {};
  final Map<String, Offset> _beaconPositions = {
    'Pepes in action': Offset(ScalingService.scaleX(419.0), ScalingService.scaleX(1284.0)),
    'Pepes in action2': Offset(ScalingService.scaleX(1800.0), ScalingService.scaleX(650.0)),
    'Pepes in action3': Offset(ScalingService.scaleX(1350.0), ScalingService.scaleX(1515.0)),
  };

  Future<void> startScan(BuildContext context) async {
    if (!await PermissionService().arePermissionsGranted()) {
      _showPermissionDialog(context);
      return;
    }

    BleStatus bleStatus = await _ble.statusStream.first;
    if (bleStatus != BleStatus.ready) {
      _showBluetoothDialog(context);
      return;
    }
    print('Scanning for devices...');
    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (_beaconPositions.containsKey(device.name)) {
        _scannedBeacons.removeWhere((beacon) => beacon.name == device.name);
        _scannedBeacons.add(device);
      }
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Map<String, double> getEstimatedPosition() {
    return _positioningService.estimatePosition(_scannedBeacons.toList(), _beaconPositions);
  }

  void _showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth is off'),
          content: Text('Please enable Bluetooth to scan for beacons.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permissions required'),
          content: Text('Please grant Bluetooth and location permissions to scan for beacons.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}