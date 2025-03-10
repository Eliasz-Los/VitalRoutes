import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription? _scanSubscription;

  Future<void> startScan(BuildContext context) async {
    if (!await _checkPermissions()) {
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
      if (device.name == "Pepes in action") {
        print('Device found: ${device.id}, RSSI: ${device.rssi}');
      }
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool> _checkPermissions() async {
    return await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.locationWhenInUse.isGranted;
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
