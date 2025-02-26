import 'package:dio/dio.dart';
import 'package:ui/Models/Point.dart';

class PathService {
  static final Dio _dio = Dio();
  //TODO nachecken
  static Future<List<Point>> getPath(Point start, Point end, String hospitalName, String floorName) async {
    final response = await _dio.get(
      'http://10.0.2.2:5028/api/path/route',
      queryParameters: {
        'start': start.toJson(),
        'end': end.toJson(),
        'hospitalName': hospitalName,
        'floorName': floorName,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((point) => Point.fromJson(point)).toList();
    } else {
      throw Exception('Failed to load path');
    }
  }
}