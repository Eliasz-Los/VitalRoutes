
import 'dart:convert';

import 'package:dio/dio.dart';

import '../Models/Room.dart';
import '../Models/Users/AssignPatientToRoom.dart';

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

  Future<void> assignPatientToRoom(AssignPatientToRoom dto) async {
    final response = await _dio.put(
      'http://10.0.2.2:5028/api/Room/assignPatient',
      data: jsonEncode(dto.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign patient');
    }
  }

  Future<Room> getRoomByUserId(String userId) async {
    try {
      final response = await _dio.get(
        'http://10.0.2.2:5028/api/Room/getRoomByUser/$userId',
      );
      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      } else {
        throw Exception('Failed to get room for user with id $userId');
      }
    } catch (e) {
      throw Exception('Error fetching room by userId $userId: $e');
    }
  }
  
}