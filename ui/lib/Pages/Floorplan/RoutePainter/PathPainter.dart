import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:ui/Models/Point.dart';

class PathPainter extends CustomPainter {
  final Uint8List imageData;
  final List<Point> path;

  PathPainter(this.imageData, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < path.length - 1; i++) {
      final start = path[i];
      final end = path[i + 1];
      canvas.drawLine(
        Offset(start.x, start.y),
        Offset(end.x, end.y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}