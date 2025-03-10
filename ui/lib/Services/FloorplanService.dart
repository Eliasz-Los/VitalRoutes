import 'package:dio/dio.dart';
import '../Config.dart';
import '../models/floorplan.dart';

class FloorplanService {
  final String baseUrl = Config.apiUrl;
  final Dio _dio = Dio();

  Future<List<Floorplan>> getFloorplans(String hospitalName) async {
    try {
      final response = await _dio.get('$baseUrl/api/Floorplan/getFloorPlans/$hospitalName');

      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        return body.map((dynamic item) => Floorplan.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load floorplans');
      }
    } catch (e) {
      throw Exception('Error fetching floorplans: $e');
    }
  }

  Future<Floorplan> getFloorplan(String hospitalName, int floorNumber) async {
    try {
      final response = await _dio.get('$baseUrl/api/Floorplan/getFloorplan/$hospitalName/$floorNumber');

      if (response.statusCode == 200) {
        return Floorplan.fromJson(response.data);
      } else {
        throw Exception('Failed to load floorplan');
      }
    } catch (e) {
      throw Exception('Error fetching floorplan: $e');
    }
  }
}