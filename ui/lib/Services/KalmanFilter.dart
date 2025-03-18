class KalmanFilter {
  late double _q; // Process noise covariance
  late double _r; // Measurement noise covariance
  late double _x; // Value
  late double _p; // Estimation error covariance
  late double _k = 0.0; // Kalman gain

  KalmanFilter({double q = 0.01, double r = 0.1, double initialValue = 0.0}) {
    _q = q;
    _r = r;
    _x = initialValue;
    _p = 1.0;
  }

  double filter(double measurement) {
    // Prediction update
    _p = _p + _q;
    
    // Measurement update
    _k = _p / (_p + _r);
    _x = _x + _k * (measurement - _x);
    _p = (1 - _k) * _p;

    return _x;
  }
}