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

class FloorplanImage extends StatefulWidget {
  final String hospitalName;
  final int floorNumber;
  final List<Point> path;

  const FloorplanImage(
      {Key? key, required this.hospitalName, required this.floorNumber, required this.path})
      : super(key: key);

  @override
  _FloorplanImageState createState() => _FloorplanImageState();
}
class _FloorplanImageState extends State<FloorplanImage> {
  Future<ui.Image> _loadImage(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final FloorplanService floorplanService = FloorplanService();
    return FutureBuilder<Floorplan>(
      future: floorplanService.getFloorplan(widget.hospitalName, widget.floorNumber),
      builder: (context, snapshot) {
        return StateHandler<Floorplan>(
          snapshot: snapshot,
          builder: (floorplan) {
            final decodedImageData = base64Decode(floorplan.imageData);
            return FutureBuilder<ui.Image>(
              future: _loadImage(decodedImageData),
              builder: (context, imageSnapshot) {
                return StateHandler(snapshot: imageSnapshot, builder: (image) {
                  return Stack(
                   children: [
                     Image.memory(
                       decodedImageData,
                       fit: BoxFit.contain,
                     ),
                    CustomPaint(
                      painter: PathPainter(image, widget.path),
                      child: Container(), //zo heeft die een kind 
                    ),
                  ],
                  );
                });
              }
            );
          },
        );
      },
    );
  }
}