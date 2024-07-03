import 'dart:math';
import 'package:flutter/material.dart';

import 'detection_page.dart';


class DetectionsLayer extends StatelessWidget {
  const DetectionsLayer({
    Key? key,
    required this.shapes,
  }) : super(key: key);

  final List<ShapeResult> shapes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShapesPainter(shapes: shapes),
    );
  }
}

class ShapesPainter extends CustomPainter {
  ShapesPainter({required this.shapes});

  final List<ShapeResult> shapes;

  @override
  void paint(Canvas canvas, Size size) {
    if (shapes.isEmpty) {
      return;
    }

    for (final shape in shapes) {
      // Paint object for drawing the shape
      final paint = Paint()
        ..strokeWidth = 2.0
        ..color = Color.fromRGBO(shape.dominantColor[0], shape.dominantColor[1], shape.dominantColor[2], 1.0)
        ..style = PaintingStyle.stroke;

      // Draw the shape lines
      for (int i = 0; i < shape.corners.length; ++i) {
        final from = Offset(shape.corners[i].x.toDouble(), shape.corners[i].y.toDouble());
        final to = Offset(
          shape.corners[(i + 1) % shape.corners.length].x.toDouble(),
          shape.corners[(i + 1) % shape.corners.length].y.toDouble(),
        );
        canvas.drawLine(from, to, paint);
      }

      // Draw the shape name and dominant color at the center of the shape
      final dominantColorName = getColorNameFromRGB(shape.dominantColor);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${shape.shapeName} ($dominantColorName)',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final centerX = shape.corners.map((p) => p.x).reduce((a, b) => a + b) / shape.corners.length;
      final centerY = shape.corners.map((p) => p.y).reduce((a, b) => a + b) / shape.corners.length;
      final textOffset = Offset(centerX.toDouble(), centerY.toDouble());
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

String getColorNameFromRGB(List<int> rgb) {
  // Simple mapping for some common colors, you can expand this as needed
  Map<String, List<int>> colors = {
    'Red': [255, 0, 0],
    'Green': [0, 255, 0],
    'Blue': [0, 0, 255],
    'Yellow': [255, 255, 0],
    'Cyan': [0, 255, 255],
    'Magenta': [255, 0, 255],
    'White': [255, 255, 255],
    'Black': [0, 0, 0],
    // Add more colors if needed
  };

  String colorName = 'Unknown';
  double minDistance = double.infinity;

  for (var entry in colors.entries) {
    double distance = sqrt(
      pow(rgb[0] - entry.value[0], 2) +
          pow(rgb[1] - entry.value[1], 2) +
          pow(rgb[2] - entry.value[2], 2),
    );

    if (distance < minDistance) {
      minDistance = distance;
      colorName = entry.key;
    }
  }

  return colorName;
}
