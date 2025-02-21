import 'package:flutter/material.dart';
import '../../Models/Room.dart';
import '../../services/roomservice.dart';
import '../StateHandler/StateHandler.dart';

class RoomLocations extends StatelessWidget {
  const RoomLocations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoomService roomService = RoomService();
    Future<List<Room>> futureRooms = roomService.getRooms();
    return FutureBuilder<List<Room>>(
      future: futureRooms,
      builder: (context, AsyncSnapshot<List<Room>> snapshot) {
        return StateHandler<List<Room>>(
          snapshot: snapshot,
          builder: (rooms) {
            return Container(
              height: 500,
              child: Stack(
                children: [
                  ...rooms.map((room) {
                    return Positioned(
                      left: room.point.x,
                      top: room.point.y,
                      child: Icon(Icons.circle, color: Colors.red, size: 15)
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}