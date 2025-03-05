import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ui/Models/Point.dart';

class PathPainter extends CustomPainter {
  final ui.Image image;
  final List<Point> path;

  PathPainter(this.image, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    //Scaling
    double scaleX = size.width / 4454.0;
    double scaleY = (size.height / 1624.0) ; // * 0.28
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;


      canvas.drawImage(image, Offset.zero, Paint());  
//extra debugging
    final debugPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < path.length; i++) {
      final point = path[i];
      final x = point.x * scaleX;
      final y = point.y * scaleY;
      if(x != 0.0 && y != 0.0) {
        canvas.drawCircle(Offset(x, y), 5.0, debugPaint);
      }
    }
    
      
      for (int i = 0; i < path.length - 1; i++) {
        final start = path[i];
        final end = path[i + 1];
        final startX = start.x * scaleX;
        final startY = start.y * scaleY;
        final endX = end.x * scaleX;
        final endY = end.y * scaleY;
        //debugging
        // print("StartX: $startX, StartY: $startY, EndX: $endX, EndY: $endY");

        if (startX != 0.0 && startY != 0.0 && endX != 0.0 && endY != 0.0) {
          canvas.drawLine(
            Offset(startX, startY),
            Offset(endX, endY),
            paint,
          );
        }
      }
      
      
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}