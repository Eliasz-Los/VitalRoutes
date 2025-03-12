import 'dart:ui';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:math';

class PositioningService {
  Map<String, double> estimatePosition(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    print(beacons.length);
    if (beacons.isEmpty) {
      return {'x': 0.0, 'y': 0.0};
    } else if (beacons.length == 1) {
      final beacon = beacons[0];
      final position = beaconPositions[beacon.name]!;
      return {'x': position.dx, 'y': position.dy};
    } else if (beacons.length == 2) {
      print('pog its triangulating n stuff');
      print('beacon 1: ${beacons[0].rssi}, beacon 2: ${beacons[1].rssi}');
      return _triangulate(beacons, beaconPositions);
    } else {
      return _trilaterate(beacons, beaconPositions);
    }
  }

  static double _calculateDistance(int rssi) {
    int txPower = -59; // RSSI value at 1 meter distance
    if (rssi == 0) {
      return -1.0; // if we cannot determine distance
    }
    double ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    } else {
      double distance = (0.89976) * pow(ratio, 7.7095) + 0.111;
      return distance;
    }
  }

  static Map<String, double> _triangulate(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    final beacon1 = beacons[0];
    final beacon2 = beacons[1];
    final position1 = beaconPositions[beacon1.name]!;
    final position2 = beaconPositions[beacon2.name]!;
    final distance1 = _calculateDistance(beacon1.rssi);
    final distance2 = _calculateDistance(beacon2.rssi);

    // Calculate the weighted average based on distances
    final totalDistance = distance1 + distance2;
    final weight1 = distance2 / totalDistance;
    final weight2 = distance1 / totalDistance;

    final x = (position1.dx * weight1) + (position2.dx * weight2);
    final y = (position1.dy * weight1) + (position2.dy * weight2);

    print('x: $x, y: $y');
    return {'x': x, 'y': y};
  }

  static Map<String, double> _trilaterate(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    double x1 = beaconPositions[beacons[0].name]!.dx;
    double y1 = beaconPositions[beacons[0].name]!.dy;
    double r1 = _calculateDistance(beacons[0].rssi);

    double x2 = beaconPositions[beacons[1].name]!.dx;
    double y2 = beaconPositions[beacons[1].name]!.dy;
    double r2 = _calculateDistance(beacons[1].rssi);

    double x3 = beaconPositions[beacons[2].name]!.dx;
    double y3 = beaconPositions[beacons[2].name]!.dy;
    double r3 = _calculateDistance(beacons[2].rssi);

    print('Beacon 1: ($x1, $y1), r1: $r1');
    print('Beacon 2: ($x2, $y2), r2: $r2');
    print('Beacon 3: ($x3, $y3), r3: $r3');

    double A = 2 * x2 - 2 * x1;
    double B = 2 * y2 - 2 * y1;
    num C = pow(r1, 2) - pow(r2, 2) - pow(x1, 2) + pow(x2, 2) - pow(y1, 2) + pow(y2, 2);
    double D = 2 * x3 - 2 * x2;
    double E = 2 * y3 - 2 * y2;
    num F = pow(r2, 2) - pow(r3, 2) - pow(x2, 2) + pow(x3, 2) - pow(y2, 2) + pow(y3, 2);

    print('A: $A, B: $B, C: $C, D: $D, E: $E, F: $F');

    double x = (C * E - F * B) / (E * A - B * D);
    double y = (C * D - A * F) / (B * D - A * E);
    print('x: $x, y: $y');
    return {'x': x, 'y': y};
  }
}