import 'package:dio/dio.dart';
import '../models/floorplan.dart';

class FloorplanService {
  final Dio _dio = Dio();

  Future<List<Floorplan>> getFloorplans(String hospitalName) async {
    try {
      final response = await _dio.get('http://10.0.2.2:5028/api/Floorplan/getFloorPlans/$hospitalName');

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
      final response = await _dio.get('http://10.0.2.2:5028/api/Floorplan/getFloorplan/$hospitalName/$floorNumber');

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