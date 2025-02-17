import 'Point.dart';
import 'Hospital.dart';


class Floorplan {
  final String id;
  final String name;
  final int floorNumber;
  final String scale;
  final List<Point> nodes;
  final Hospital hospital;
  final String imageData;

  Floorplan({
    required this.id,
    required this.name,
    required this.floorNumber,
    required this.scale,
    required this.nodes,
    required this.hospital,
    required this.imageData,
  });

  factory Floorplan.fromJson(Map<String, dynamic> json) {
    return Floorplan(
      id: json['id'],
      name: json['name'],
      floorNumber: json['floorNumber'],
      scale: json['scale'],
      nodes: (json['nodes'] as List).map((i) => Point.fromJson(i)).toList(),
      hospital: Hospital.fromJson(json['hospital']),
      imageData: json['imageData'],
    );
  }
}