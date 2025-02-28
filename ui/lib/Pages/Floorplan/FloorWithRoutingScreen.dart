import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/floorplan.dart';
import '../../services/floorplanservice.dart';
import 'FloorplanWithPath.dart';

class FloorWithRoutingScreen extends StatefulWidget {
  final String hospitalName;
  final int floorNumber;
  final String floorName;

  const FloorWithRoutingScreen({super.key, required this.hospitalName, required this.floorNumber, required this.floorName});

  @override
  _FloorWithRoutingScreenState createState() => _FloorWithRoutingScreenState();
}

class _FloorWithRoutingScreenState extends State<FloorWithRoutingScreen> {
  late Future<Floorplan> futureFloorplan;
  final FloorplanService floorplanService = FloorplanService();

  @override
  void initState() {
    super.initState();
    futureFloorplan = floorplanService.getFloorplan(widget.hospitalName, widget.floorNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grondplan van ${widget.hospitalName} - Verdieping ${widget.floorNumber}'),
      ),
      body: FutureBuilder<Floorplan>(
        future: futureFloorplan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No floorplan found'));
          } else {
            final floorplan = snapshot.data!;
            final decodedImageData = base64Decode(floorplan.imageData);
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(floorplan.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Verdieping: ${floorplan.floorNumber}'),
                  Text('Schaal: ${floorplan.scale}'),
                  InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(20),
                    minScale: 0.1,
                    maxScale: 4,
                    child: Image.memory(
                      decodedImageData,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}