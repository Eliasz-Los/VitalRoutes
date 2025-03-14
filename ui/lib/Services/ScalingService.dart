class ScalingService{
  static double scaleY(double y) {
    double scaled = (y / 7.46) * 0.65;
    return scaled;
  }
  
  static double scaleX(double x) {
    double scaled = x / 10.77;
    return scaled;
  }
}