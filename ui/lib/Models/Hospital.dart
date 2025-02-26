class Hospital {
  final String id;
  final String name;
  final int maxFloorNumber;
  final int minFloorNumber;

  Hospital({
    required this.id,
    required this.name,
    required this.maxFloorNumber, 
    required this.minFloorNumber
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json["id"],
      name: json['name'],
      maxFloorNumber: json['maxFloorNumber'],
      minFloorNumber: json['minFloorNumber']
    );
  }
}