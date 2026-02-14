import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple compass overlay painter (Minimalist design)
/// Shows only N E S W without complex rings
class SimpleCompassPainter extends CustomPainter {
  final double deviceAzimuth;
  
  const SimpleCompassPainter({
    required this.deviceAzimuth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 50.0; // Small, subtle compass
    
    // Draw cardinal directions only
    _drawCardinalDirections(canvas, center, radius);
    
    // Draw simple arrow
    _drawAzimuthArrow(canvas, center, radius);
  }
  
  /// Draw N E S W only (minimalist)
  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = [
      {'label': 'N', 'angle': 0.0, 'color': Colors.red},
      {'label': 'E', 'angle': 90.0, 'color': Colors.white},
      {'label': 'S', 'angle': 180.0, 'color': Colors.white},
      {'label': 'W', 'angle': 270.0, 'color': Colors.white},
    ];
    
    for (final dir in directions) {
      final label = dir['label'] as String;
      final angle = ((dir['angle'] as double) - deviceAzimuth) * math.pi / 180 - math.pi / 2;
      final color = dir['color'] as Color;
      
      final position = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      
      _drawText(
        canvas,
        position,
        label,
        color,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );
    }
  }
  
  /// Draw simple arrow pointing up
  void _drawAzimuthArrow(Canvas canvas, Offset center, double radius) {
    final arrowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Arrow line
    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx, center.dy - 15),
      arrowPaint,
    );
    
    // Arrow head
    final arrowHeadPath = Path()
      ..moveTo(center.dx, center.dy - 15)
      ..lineTo(center.dx - 5, center.dy - 10)
      ..moveTo(center.dx, center.dy - 15)
      ..lineTo(center.dx + 5, center.dy - 10);
    
    canvas.drawPath(arrowHeadPath, arrowPaint);
    
    // Azimuth value below
    _drawText(
      canvas,
      Offset(center.dx, center.dy + 25),
      '${deviceAzimuth.toStringAsFixed(0)}°',
      Colors.cyan,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
  }
  
  void _drawText(
    Canvas canvas,
    Offset position,
    String text,
    Color color, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, offset);
  }
  
  @override
  bool shouldRepaint(SimpleCompassPainter oldDelegate) {
    return (deviceAzimuth - oldDelegate.deviceAzimuth).abs() > 1.0;
  }
}