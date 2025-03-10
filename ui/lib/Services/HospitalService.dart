import 'package:dio/dio.dart';
import 'package:ui/Models/Hospital.dart';

import '../Config.dart';

class HospitalService {
  static final Dio _dio = Dio();
  static final String baseUrl = Config.apiUrl;
  
  static Future<Hospital> getHospital(String hospitalName) async {
    try {
      print('$baseUrl');
      final response = await _dio.get('$baseUrl/api/hospital/getHospital/$hospitalName');
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