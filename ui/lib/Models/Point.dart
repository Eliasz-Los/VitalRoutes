class Point {
  final String? id;
  final double x;
  final double y;

  Point({
    this.id,
    required this.x,
    required this.y
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'],
      x: (json['xWidth'] as num).toDouble(),
      y: (json['yHeight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'xWidth': x,
      'yHeight': y,
    };
  }
  
  @override
  String toString() {
    return 'Point{ x: $x, y: $y}';
  }
}