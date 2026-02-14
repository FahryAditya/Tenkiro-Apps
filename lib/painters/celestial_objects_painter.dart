import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/celestial-object.dart';
import '../models/sky_coordinates.dart';

/// Celestial objects painter
/// Renders stars, planets, sun, moon
class CelestialObjectsPainter extends CustomPainter {
  final List<PositionedCelestialObject> objects;
  final DeviceOrientation deviceOrientation;
  final FieldOfView fieldOfView;
  final bool showLabels;
  
  const CelestialObjectsPainter({
    required this.objects,
    required this.deviceOrientation,
    required this.fieldOfView,
    this.showLabels = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate visible region
    final centerCoords = deviceOrientation.toHorizontalCoordinates();
    final visibleRegion = SkyRegion(
      center: centerCoords,
      fov: fieldOfView,
    );
    
    // Draw objects
    for (final positioned in objects) {
      if (!positioned.isVisible) continue; // Below horizon
      if (!visibleRegion.contains(positioned.horizontal)) continue; // Outside FOV
      
      final screenPos = _projectToScreen(
        positioned.horizontal,
        centerCoords,
        size,
      );
      
      // Skip if outside screen bounds
      if (!_isOnScreen(screenPos, size)) continue;
      
      // Draw based on type
      final obj = positioned.object;
      if (obj is Sun) {
        _drawSun(canvas, screenPos, obj);
      } else if (obj is Moon) {
        _drawMoon(canvas, screenPos, obj);
      } else if (obj is Planet) {
        _drawPlanet(canvas, screenPos, obj);
      } else if (obj is Star) {
        _drawStar(canvas, screenPos, obj);
      }
      
      // Draw label
      if (showLabels && obj.magnitude < 2.0) {
        _drawLabel(canvas, screenPos, obj.name);
      }
    }
  }
  
  /// Project horizontal coordinates to screen position
  Offset _projectToScreen(
    HorizontalCoordinates coords,
    HorizontalCoordinates center,
    Size size,
  ) {
    // Calculate angular offset from center
    final deltaAz = _angleDifference(coords.azimuth, center.azimuth);
    final deltaAlt = coords.altitude - center.altitude;
    
    // Normalize to -1 to 1
    final normX = deltaAz / (fieldOfView.horizontal / 2);
    final normY = -deltaAlt / (fieldOfView.vertical / 2); // Negative for screen coords
    
    // Convert to screen pixels
    final x = size.width / 2 + normX * size.width / 2;
    final y = size.height / 2 + normY * size.height / 2;
    
    return Offset(x, y);
  }
  
  /// Calculate angle difference (handling wrap-around)
  double _angleDifference(double a, double b) {
    var diff = a - b;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }
  
  /// Check if position is on screen
  bool _isOnScreen(Offset pos, Size size) {
    return pos.dx >= -50 && pos.dx <= size.width + 50 &&
           pos.dy >= -50 && pos.dy <= size.height + 50;
  }
  
  /// Draw sun
  void _drawSun(Canvas canvas, Offset position, Sun sun) {
    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(position, sun.renderSize + 10, glowPaint);
    
    // Main body
    final sunPaint = Paint()
      ..color = sun.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, sun.renderSize, sunPaint);
    
    // Corona rays
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(
        position.dx + math.cos(angle) * sun.renderSize,
        position.dy + math.sin(angle) * sun.renderSize,
      );
      final end = Offset(
        position.dx + math.cos(angle) * (sun.renderSize + 10),
        position.dy + math.sin(angle) * (sun.renderSize + 10),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }
  
  /// Draw moon
  void _drawMoon(Canvas canvas, Offset position, Moon moon) {
    // Glow
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(position, moon.renderSize + 8, glowPaint);
    
    // Main body
    final moonPaint = Paint()
      ..color = moon.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, moon.renderSize, moonPaint);
    
    // Phase shadow (simplified)
    if (moon.illumination < 99) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      final shadowOffset = (1 - moon.illumination / 100) * moon.renderSize * 2;
      final shadowRect = Rect.fromCenter(
        center: Offset(position.dx + shadowOffset, position.dy),
        width: moon.renderSize * 2,
        height: moon.renderSize * 2,
      );
      
      canvas.drawOval(shadowRect, shadowPaint);
    }
  }
  
  /// Draw planet
  void _drawPlanet(Canvas canvas, Offset position, Planet planet) {
    // Glow
    final glowPaint = Paint()
      ..color = planet.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(position, planet.renderSize + 4, glowPaint);
    
    // Main body
    final planetPaint = Paint()
      ..color = planet.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, planet.renderSize, planetPaint);
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(position.dx - planet.renderSize / 3, position.dy - planet.renderSize / 3),
      planet.renderSize / 3,
      highlightPaint,
    );
  }
  
  /// Draw star
  void _drawStar(Canvas canvas, Offset position, Star star) {
    final starPaint = Paint()
      ..color = star.color
      ..style = PaintingStyle.fill;
    
    // Brighter stars have glow
    if (star.magnitude < 2) {
      final glowPaint = Paint()
        ..color = star.color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(position, star.renderSize + 3, glowPaint);
    }
    
    canvas.drawCircle(position, star.renderSize, starPaint);
  }
  
  /// Draw label
  void _drawLabel(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Draw below object
    final labelPosition = Offset(
      position.dx - textPainter.width / 2,
      position.dy + 15,
    );
    
    textPainter.paint(canvas, labelPosition);
  }
  
  @override
  bool shouldRepaint(CelestialObjectsPainter oldDelegate) {
    // Repaint if orientation changed significantly
    final azDiff = (deviceOrientation.azimuth - oldDelegate.deviceOrientation.azimuth).abs();
    final pitchDiff = (deviceOrientation.pitch - oldDelegate.deviceOrientation.pitch).abs();
    
    return azDiff > 0.5 || pitchDiff > 0.5 || objects.length != oldDelegate.objects.length;
  }
}