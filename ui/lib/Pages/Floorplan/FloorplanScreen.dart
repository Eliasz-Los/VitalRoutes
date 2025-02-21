import 'package:flutter/material.dart';
import 'FloorplanImage.dart';
import 'RoomLocations.dart';

class FloorplanPage extends StatelessWidget {
  final String hospitalName;
  final int floorNumber;

  const FloorplanPage({super.key, required this.hospitalName, required this.floorNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grondplan van ${hospitalName} - Verdieping ${floorNumber}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTapDown: (TapDownDetails details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset localOffset = box.globalToLocal(details.globalPosition);
                print('Coordinates: (${localOffset.dx}, ${localOffset.dy})');
              },
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.1,
                maxScale: 4,
                child: Stack(
                  children: [
                    FloorplanImage(hospitalName: hospitalName, floorNumber: floorNumber),
                    RoomLocations(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}