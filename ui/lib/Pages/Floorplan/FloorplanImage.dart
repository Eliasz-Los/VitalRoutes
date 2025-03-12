import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ui/Models/Point.dart';
import 'package:ui/Pages/Floorplan/RoutePainter/PathPainter.dart';
import 'dart:convert';
import '../../Services/PathService.dart';
import '../../models/floorplan.dart';
import '../../services/floorplanservice.dart';
import '../StateHandler/StateHandler.dart';

//TODO: make it so that the image doesnt always need to reload
class FloorplanImage extends StatefulWidget {
  final String hospitalName;
  final int floorNumber;
  final bool isPathfindingEnabled;
  final List<Point> path;
  final Point? startPoint;
  final Point? endPoint;
  final Function(List<Point>, Point?, Point?) onPathUpdated;

  const FloorplanImage(
      {Key? key, required this.hospitalName, required this.floorNumber, 
        required this.isPathfindingEnabled,
         required this.path,
         this.startPoint,
         this.endPoint,
         required this.onPathUpdated
      })
      : super(key: key);

  @override
  _FloorplanImageState createState() => _FloorplanImageState();
}

class _FloorplanImageState extends State<FloorplanImage> {

  
  
  Future<void> _fetchPath(Point start, Point end) async{
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching path...'), backgroundColor: Colors.green, duration: Duration(seconds: 5),)
    );
    final response = await PathService.getPath(start, end, widget.hospitalName, widget.floorNumber );
    widget.onPathUpdated(response, start, end);
  }

  void _handleTap(TapDownDetails details){
    if(!widget.isPathfindingEnabled) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    final double scaledX = localOffset.dx *10.77; //TODO hardcoded scaling *10.77, *7.46
    final double scaledY = (localOffset.dy *7.46) *1.5;
    final Point point = Point(x: scaledX.roundToDouble(), y: scaledY.roundToDouble());

    if (widget.startPoint == null) {
      
      widget.onPathUpdated(widget.path, point, widget.endPoint);
      
    } else if (widget.endPoint == null) {
      widget.onPathUpdated(widget.path, widget.startPoint, point);
      _fetchPath(widget.startPoint!, point);
    } else {
      widget.onPathUpdated([], null, null);
    }
  }

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
                  return GestureDetector(
                    onTapDown: _handleTap,
                    child: Stack(
                     children: [
                       Image.memory(
                         decodedImageData,
                         fit: BoxFit.contain,
                       ),
                      CustomPaint(
                        painter: PathPainter(image, widget.path, widget.startPoint, widget.endPoint),
                        child: Container(), //zo heeft die een kind 
                      ),
                  ],
                  )
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