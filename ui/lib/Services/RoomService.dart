
import 'dart:convert';

import 'package:dio/dio.dart';

import '../Config.dart';
import '../Models/Room.dart';
import '../Models/Users/AssignPatientToRoom.dart';

class RoomService {
  final Dio _dio = Dio();
  final String baseUrl = Config.apiUrl;
  
  Future<List<Room>> getRooms(String hospital, int floorNumber) async {
    final response = await _dio.get('$baseUrl/api/Room/getRooms/$hospital/$floorNumber');
    if (response.statusCode == 200) {
      List<dynamic> rooms = response.data;
      return rooms.map((room) => Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> assignPatientToRoom(AssignPatientToRoom dto) async {
    final response = await _dio.put(
      '$baseUrl/api/Room/assignPatient',
      data: jsonEncode(dto.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign patient');
    }
  }
  
}