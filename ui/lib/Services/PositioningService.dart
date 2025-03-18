import 'dart:ui';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:math';
import 'KalmanFilter.dart';

class PositioningService {
  final KalmanFilter _kalmanFilterX = KalmanFilter();
  final KalmanFilter _kalmanFilterY = KalmanFilter();

  Map<String, double> estimatePosition(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    if (beacons.isEmpty) {
      return {'x': 0.0, 'y': 0.0};
    } else if (beacons.length == 1) {
      final beacon = beacons[0];
      final position = beaconPositions[beacon.name]!;
      return {'x': position.dx, 'y': position.dy};
    } else if (beacons.length == 2) {
      return _triangulate(beacons, beaconPositions);
    } else {
      return _trilaterate(beacons, beaconPositions);
    }
  }

  double _calculateDistance(int rssi) {
    int txPower = -42; // RSSI value at 1 meter distance
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

  Map<String, double> _triangulate(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    final beacon1 = beacons[0];
    final beacon2 = beacons[1];
    final position1 = beaconPositions[beacon1.name]!;
    final position2 = beaconPositions[beacon2.name]!;
    final distance1 = _calculateDistance(beacon1.rssi);
    final distance2 = _calculateDistance(beacon2.rssi);

    final totalDistance = distance1 + distance2;
    final weight1 = distance2 / totalDistance;
    final weight2 = distance1 / totalDistance;

    final x = (position1.dx * weight1) + (position2.dx * weight2);
    final y = (position1.dy * weight1) + (position2.dy * weight2);

    return {'x': _kalmanFilterX.filter(x), 'y': _kalmanFilterY.filter(y)};
  }

Map<String, double> _trilaterate(List<DiscoveredDevice> beacons, Map<String, Offset> beaconPositions) {
    double totalWeight = 0.0;
    double weightedX = 0.0;
    double weightedY = 0.0;

    for (var beacon in beacons) {
      final position = beaconPositions[beacon.name]!;
      final distance = _calculateDistance(beacon.rssi);
      final weight = 1 / (distance * distance); // Weight inversely proportional to the square of the distance

      weightedX += position.dx * weight;
      weightedY += position.dy * weight;
      totalWeight += weight;
    }

    final x = weightedX / totalWeight;
    final y = weightedY / totalWeight;

    return {'x': _kalmanFilterX.filter(x), 'y': _kalmanFilterY.filter(y)};
  }
}