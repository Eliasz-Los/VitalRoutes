class Point {
  final String id;
  final double x;
  final double y;

  Point({
    required this.id,
    required this.x,
    required this.y
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'],
      x: json['xWidth'],
      y: json['yHeight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xWidth': x,
      'yHeight': y,
    };
  }
}