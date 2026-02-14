 import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Compass overlay painter
/// Displays cardinal directions (N, E, S, W) around the edge of screen
class CompassOverlayPainter extends CustomPainter {
  final double deviceAzimuth; // Current compass direction (0-360°)
  final bool showInterCardinal; // Show NE, SE, SW, NW
  final bool showDegrees; // Show degree markings
  
  const CompassOverlayPainter({
    required this.deviceAzimuth,
    this.showInterCardinal = false,
    this.showDegrees = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 60;
    
    // Draw compass ring
    _drawCompassRing(canvas, center, radius);
    
    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);
    
    // Draw intercardinal directions (optional)
    if (showInterCardinal) {
      _drawInterCardinalDirections(canvas, center, radius);
    }
    
    // Draw degree markings (optional)
    if (showDegrees) {
      _drawDegreeMarkings(canvas, center, radius);
    }
    
    // Draw azimuth indicator (current direction)
    _drawAzimuthIndicator(canvas, center, radius);
  }
  
  /// Draw compass ring
  void _drawCompassRing(Canvas canvas, Offset center, double radius) {
    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, ringPaint);
    
    // Inner ring (smaller)
    canvas.drawCircle(center, radius - 10, ringPaint);
  }
  
  /// Draw cardinal directions (N, E, S, W)
  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = [
      {'label': 'N', 'angle': 0.0, 'color': Colors.red}, // North (red)
      {'label': 'E', 'angle': 90.0, 'color': Colors.white},
      {'label': 'S', 'angle': 180.0, 'color': Colors.white},
      {'label': 'W', 'angle': 270.0, 'color': Colors.white},
    ];
    
    for (final dir in directions) {
      final label = dir['label'] as String;
      // Subtract deviceAzimuth to rotate compass ring
      final angle = ((dir['angle'] as double) - deviceAzimuth) * math.pi / 180 - math.pi / 2;
      final color = dir['color'] as Color;
      
      final position = Offset(
        center.dx + math.cos(angle) * (radius + 25),
        center.dy + math.sin(angle) * (radius + 25),
      );
      
      _drawText(
        canvas,
        position,
        label,
        color,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      );
    }
  }
  
  /// Draw intercardinal directions (NE, SE, SW, NW)
  void _drawInterCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = [
      {'label': 'NE', 'angle': 45.0},
      {'label': 'SE', 'angle': 135.0},
      {'label': 'SW', 'angle': 225.0},
      {'label': 'NW', 'angle': 315.0},
    ];
    
    for (final dir in directions) {
      final label = dir['label'] as String;
      final angle = ((dir['angle'] as double) - deviceAzimuth) * math.pi / 180 - math.pi / 2;
      
      final position = Offset(
        center.dx + math.cos(angle) * (radius + 20),
        center.dy + math.sin(angle) * (radius + 20),
      );
      
      _drawText(
        canvas,
        position,
        label,
        Colors.white.withOpacity(0.7),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
    }
  }
  
  /// Draw degree markings around compass
  void _drawDegreeMarkings(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 36; i++) {
      final degree = i * 10;
      final angle = (degree - deviceAzimuth) * math.pi / 180 - math.pi / 2;
      
      // Major tick at 30° intervals
      final isMajor = degree % 30 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      final tickWidth = isMajor ? 2.0 : 1.0;
      
      final startRadius = radius - tickLength;
      final endRadius = radius;
      
      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );
      
      final tickPaint = Paint()
        ..color = Colors.white.withOpacity(isMajor ? 0.7 : 0.4)
        ..strokeWidth = tickWidth;
      
      canvas.drawLine(start, end, tickPaint);
    }
  }
  
  /// Draw azimuth indicator (current phone direction)
  void _drawAzimuthIndicator(Canvas canvas, Offset center, double radius) {
    // Arrow pointing to top of screen (current direction)
    final angle = -math.pi / 2; // Always point up
    
    // Draw arrow
    final arrowPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;
    
    final arrowTip = Offset(
      center.dx + math.cos(angle) * (radius - 15),
      center.dy + math.sin(angle) * (radius - 15),
    );
    
    final arrowLeft = Offset(
      center.dx + math.cos(angle - 0.4) * (radius - 30),
      center.dy + math.sin(angle - 0.4) * (radius - 30),
    );
    
    final arrowRight = Offset(
      center.dx + math.cos(angle + 0.4) * (radius - 30),
      center.dy + math.sin(angle + 0.4) * (radius - 30),
    );
    
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();
    
    canvas.drawPath(arrowPath, arrowPaint);
    
    // Draw azimuth value in center
    _drawText(
      canvas,
      center,
      '${deviceAzimuth.toStringAsFixed(0)}°',
      Colors.cyan,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    );
  }
  
  /// Helper: Draw text at position
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
  bool shouldRepaint(CompassOverlayPainter oldDelegate) {
    // Repaint if azimuth changed by more than 1°
    return (deviceAzimuth - oldDelegate.deviceAzimuth).abs() > 1.0;
  }
}

/// Simple compass widget for easy use
class CompassOverlay extends StatelessWidget {
  final double azimuth;
  final bool showInterCardinal;
  final bool showDegrees;
  
  const CompassOverlay({
    super.key,
    required this.azimuth,
    this.showInterCardinal = false,
    this.showDegrees = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CompassOverlayPainter(
        deviceAzimuth: azimuth,
        showInterCardinal: showInterCardinal,
        showDegrees: showDegrees,
      ),
      child: Container(),
    );
  }
}