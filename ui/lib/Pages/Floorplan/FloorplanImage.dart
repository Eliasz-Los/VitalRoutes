import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/floorplan.dart';
import '../../services/floorplanservice.dart';
import '../StateHandler/StateHandler.dart';

class FloorplanImage extends StatelessWidget {
  final String hospitalName;
  final int floorNumber;

  const FloorplanImage({Key? key, required this.hospitalName, required this.floorNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FloorplanService floorplanService = FloorplanService();
    return FutureBuilder<Floorplan>(
      future: floorplanService.getFloorplan(hospitalName, floorNumber),
      builder: (context, snapshot) {
        return StateHandler<Floorplan>(
          snapshot: snapshot,
          builder: (floorplan) {
            final decodedImageData = base64Decode(floorplan.imageData);
            return Image.memory(
              decodedImageData,
              fit: BoxFit.contain,
            );
          },
        );
      },
    );
  }
}