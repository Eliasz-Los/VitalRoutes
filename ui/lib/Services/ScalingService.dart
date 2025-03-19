class ScalingService{
  static double scaleY(double y) {
    //double scaled = (y / 7.46) * 0.65;
    double scaled = (y / 7.46) * 0.55;
    return scaled;
  }
  
  static double scaleX(double x) {
    //double scaled = x / 10.77;
    double scaled = x / 12.5;
    return scaled;
  }
}