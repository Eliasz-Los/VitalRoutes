import 'package:sensors_plus/sensors_plus.dart';

class SensorFusionService {
  double _accelerationX = 0.0;
  double _accelerationY = 0.0;
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  DateTime _lastUpdateTime = DateTime.now();

  SensorFusionService() {
    accelerometerEventStream.call().listen((AccelerometerEvent event) {
      _accelerationX = _lowPassFilter(event.x, _accelerationX);
      _accelerationY = _lowPassFilter(event.y, _accelerationY);
      _updateVelocity();
    });

    gyroscopeEventStream.call().listen((GyroscopeEvent event) {
      _gyroscopeX = event.x;
      _gyroscopeY = event.y;
    });
  }

  double _lowPassFilter(double newValue, double oldValue, [double alpha = 0.1]) {
    return oldValue + alpha * (newValue - oldValue);
  }

  void _updateVelocity() {
    final currentTime = DateTime.now();
    final deltaTime = currentTime.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = currentTime;

    _velocityX += _accelerationX * deltaTime;
    _velocityY += _accelerationY * deltaTime;

    // Reset velocity periodically to prevent it from growing indefinitely
    if (_velocityX.abs() > 10.0) _velocityX = 0.0;
    if (_velocityY.abs() > 10.0) _velocityY = 0.0;
  }

  Map<String, double> refinePosition(Map<String, double> estimatedPosition) {
    final currentTime = DateTime.now();
    final deltaTime = currentTime.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = currentTime;

    double refinedX = estimatedPosition['x']! + _velocityX * deltaTime + _gyroscopeX * 0.1;
    double refinedY = estimatedPosition['y']! + _velocityY * deltaTime + _gyroscopeY * 0.1;

    print('Acceleration: $_accelerationX, $_accelerationY');
    print('Velocity: $_velocityX, $_velocityY');
    print('Refined position: $refinedX, $refinedY');

    return {'x': refinedX, 'y': refinedY};
  }
}