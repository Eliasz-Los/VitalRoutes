import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:ui/Models/Point.dart';
import 'package:ui/Services/PathService.dart';
import 'RoutePainter/PathPainter.dart';

class FloorplanWithPath extends StatefulWidget {
  final String hospitalName;
  final String floorName;
  final Uint8List imageData;

  const FloorplanWithPath({super.key, required this.hospitalName, required this.floorName, required this.imageData});

  @override
  _FloorplanWithPathState createState() => _FloorplanWithPathState();
}

class _FloorplanWithPathState extends State<FloorplanWithPath> {
  Point? startPoint;
  Point? endPoint;
  List<Point> path = [];
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(widget.imageData, (img) {
      setState(() {
        image = img;
      });
      completer.complete(img);
    });
    await completer.future;
  }

  void _onTapDown(TapDownDetails details) {
    if (image == null) return; // Prevent selecting points before image is loaded

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final Point tappedPoint = Point(x: localOffset.dx, y: localOffset.dy);

    setState(() {
      if (startPoint == null) {
        startPoint = tappedPoint;
      } else if (endPoint == null) {
        endPoint = tappedPoint;
        _fetchPath();
      } else {
        startPoint = tappedPoint;
        endPoint = null;
        path = [];
      }
    });
  }

  void _fetchPath() async {
    if (startPoint != null && endPoint != null) {
      try {
        final fetchedPath = await PathService.getPath(startPoint!, endPoint!, widget.hospitalName, widget.floorName);
        setState(() {
          path = fetchedPath;
        });
      } catch (e) {
        print('Failed to load path: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: image == null
        ? Center(child: CircularProgressIndicator())
        : CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: PathPainter(image!, path),
          ),
    );
  }
}