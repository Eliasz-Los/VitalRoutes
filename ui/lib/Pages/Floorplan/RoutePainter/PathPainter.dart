import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ui/Models/Point.dart';

class PathPainter extends CustomPainter {
  final ui.Image image;
  final List<Point> path;
  final Point? startPoint;
  final Point? endPoint;

  PathPainter(this.image, this.path, this.startPoint, this.endPoint);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) {
      return;}

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final double scaleX = (size.width / image.width);
    final double scaleY = (image.height / 1624.0) *0.08 ; //IDK EVEN FK KNOW 0.09 / 0.092
    // print('PATHPAINTER scale: x ${scaleX}, y ${scaleY}');
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
    
    //TODO draw start and end points
    final pointPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    if (startPoint != null) {
      canvas.drawCircle(Offset(startPoint!.x * scaleX, startPoint!.y * scaleY), 4.0, pointPaint);
    }

    if (endPoint != null) {
      canvas.drawCircle(Offset(endPoint!.x * scaleX, endPoint!.y * scaleY), 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}