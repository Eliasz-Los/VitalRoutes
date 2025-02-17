class Hospital {
  final String name;

  Hospital({required this.name});

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'],
    );
  }
}