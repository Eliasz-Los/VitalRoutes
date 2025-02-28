import 'package:dio/dio.dart';
import 'package:ui/Models/Hospital.dart';

class HospitalService {
  static final Dio _dio = Dio();
  
  static Future<Hospital> getHospital(String hospitalName) async {
    try {
      final response = await _dio.get('http://10.0.2.2:5028/api/hospital/getHospital/$hospitalName');
      if (response.statusCode != 200) {
        throw Exception('Failed to load hospital data');
      }
      if (response.data == null) {
        throw Exception('Hospital not found');
      }
      return Hospital.fromJson(response.data);
    } catch (e) {
      throw Exception('Error getting hospital by name $hospitalName: \n$e');
    }
  }
}