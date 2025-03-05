import 'package:flutter/material.dart';
import '../../Models/Room.dart';
import '../../services/roomservice.dart';
import '../StateHandler/StateHandler.dart';
import '../../Models/Users/User.dart' as custom_user;
import '../../Models/Enums/FunctionType.dart';

class RoomLocations extends StatelessWidget {
  final custom_user.User? user;
  final int floorNumber;

  const RoomLocations({super.key, this.user, required this.floorNumber});

  @override
  Widget build(BuildContext context) {
    final RoomService roomService = RoomService();
    Future<List<Room>> futureRooms = roomService.getRooms('UZ Groenplaats', floorNumber);
    return FutureBuilder<List<Room>>(
      future: futureRooms,
      builder: (context, AsyncSnapshot<List<Room>> snapshot) {
        return StateHandler<List<Room>>(
          snapshot: snapshot,
          builder: (rooms) {
            return SizedBox(
              height: 500.0, 
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      ...rooms.map((room) {
                        Color dotColor = Colors.grey;
                        if (user != null) {
                          if (user!.function == FunctionType.Doctor && user!.underSupervisions?.contains(room.assignedPatient?.id) == true) {
                            dotColor = Colors.green;
                          } else if (user!.function == FunctionType.Nurse && user!.underSupervisions?.contains(room.assignedPatient?.id) == true) {
                            dotColor = Colors.green;
                          }
                        }
                        double scaledX = room.point.x;
                        double scaledY = room.point.y * 0.75; //TODO: scaling terug kapot door who knows what
                        print("Room: ${room.id}, X: $scaledX, Y: $scaledY"); // Debugging

                        return Positioned(
                          left: scaledX,
                          top: scaledY,
                          child: Icon(Icons.circle, color: dotColor, size: 15),
                        );
                      }),
                    ],
                  );
                },
              )
            );
          },
        );
      },
    );
  }
}