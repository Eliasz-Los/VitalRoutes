import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ui/Models/Point.dart';
import 'package:ui/Pages/Floorplan/RoutePainter/PathPainter.dart';
import 'dart:convert';
import '../../models/floorplan.dart';
import '../../services/floorplanservice.dart';
import '../StateHandler/StateHandler.dart';

class FloorplanImage extends StatelessWidget {
  final String hospitalName;
  final int floorNumber;
  final List<Point> path;

  const FloorplanImage({Key? key, required this.hospitalName, required this.floorNumber, required this.path}) : super(key: key);

  Future<ui.Image> _loadImage(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
  //TODO: fix custom paint

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


