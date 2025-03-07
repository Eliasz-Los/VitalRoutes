import 'package:dio/dio.dart';
import 'package:ui/Models/Point.dart';

class PathService {
  static final Dio _dio = Dio();
  
  static Future<List<Point>> getPath(Point start, Point end, String hospitalName, int floorNumber) async {
   final requestPayload = {
     'Start': start.toJson(),
    'End': end.toJson(),
    'HospitalName': hospitalName,
    'FloorNumber': floorNumber,
   };
   
   print('Request payload: $requestPayload');
   try {
     final response = await _dio.get(
       'http://10.0.2.2:5028/api/path/route',
       data: requestPayload,
       options: Options(
         headers: {
           'Content-Type': 'application/json',
         },
       ),
     );

     if (response.statusCode == 200) {
       List<Point> path = (response.data as List).map((point) =>
           Point.fromJson(point)).toList();
       return path;
     } else {
       throw Exception('Failed to load path');
     }
   } on DioException catch (e) {
     print('DioException: ${e.message}');
     print('Response data: ${e.response?.data}');
     throw e;   
   }
  }
}