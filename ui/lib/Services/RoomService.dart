
import 'package:dio/dio.dart';

import '../Models/Room.dart';

class RoomService {
  final Dio _dio = Dio();
  
  Future<List<Room>> getRooms(String hospital, int floorNumber) async {
    final response = await _dio.get('http://10.0.2.2:5028/api/Room/getRooms/$hospital/$floorNumber');
    if (response.statusCode == 200) {
      List<dynamic> rooms = response.data;
      return rooms.map((room) => Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }
  
}