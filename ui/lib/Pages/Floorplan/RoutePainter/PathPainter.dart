import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ui/Models/Point.dart';

class PathPainter extends CustomPainter {
  final ui.Image image;
  final List<Point> path;

  PathPainter(this.image, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) {
      print("Path is empty?????");
      return;}

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double scaleX = size.width / image.width;
    final double scaleY = (image.height / 1624.0) *0.09 ; //IDK EVEN FK KNOW
    
    final pathToDraw = Path();
    pathToDraw.moveTo(path[0].x * scaleX, path[0].y * scaleY);

    for (var point in path) {
      final x = point.x * scaleX;
      final y = point.y * scaleY;
       if (x != 0.0 && y != 0.0) {
         pathToDraw.lineTo(x, y);
       }

    }

    canvas.drawPath(pathToDraw, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}