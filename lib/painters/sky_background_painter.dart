import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Sky background painter
/// Renders realistic sky gradient based on sun position and time of day
class SkyBackgroundPainter extends CustomPainter {
  final double sunAltitude; // Sun's altitude in degrees (-90 to 90)
  final DateTime currentTime;
  final bool showStars; // Show background stars at night
  
  const SkyBackgroundPainter({
    required this.sunAltitude,
    required this.currentTime,
    this.showStars = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw sky gradient
    final gradient = _createSkyGradient(size);
    final paint = Paint()..shader = gradient;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    
    // Draw subtle stars for night sky
    if (showStars && sunAltitude < -6) {
      _drawBackgroundStars(canvas, size);
    }
    
    // Optional: Draw atmospheric glow near horizon
    if (sunAltitude > -18 && sunAltitude < 6) {
      _drawAtmosphericGlow(canvas, size);
    }
  }
  
  /// Create sky gradient based on sun altitude
  Shader _createSkyGradient(Size size) {
    final colors = _getSkyColors();
    
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  }
  
  /// Get sky colors based on sun altitude
  List<Color> _getSkyColors() {
    if (sunAltitude > 6) {
      // Daytime (Sun well above horizon)
      return [
        const Color(0xFF4EA8DE), // Sky blue (top)
        const Color(0xFF87CEEB), // Light sky blue (middle)
        const Color(0xFFADE8F4), // Pale blue (horizon)
      ];
    } else if (sunAltitude > 0) {
      // Sun near horizon (sunrise/sunset starting)
      final t = sunAltitude / 6; // 0 to 1
      return [
        Color.lerp(const Color(0xFF87CEEB), const Color(0xFFFFB347), 1 - t)!,
        Color.lerp(const Color(0xFFADE8F4), const Color(0xFFFFA500), 1 - t)!,
        Color.lerp(const Color(0xFFE0F6FF), const Color(0xFFFFD700), 1 - t)!,
      ];
    } else if (sunAltitude > -6) {
      // Civil twilight (bright twilight)
      final t = (sunAltitude + 6) / 6; // 0 to 1
      return [
        Color.lerp(const Color(0xFF003566), const Color(0xFFFFB347), t)!,
        Color.lerp(const Color(0xFFFFA500), const Color(0xFFFF8C00), t)!,
        Color.lerp(const Color(0xFFFFD700), const Color(0xFFFFE4B5), t)!,
      ];
    } else if (sunAltitude > -12) {
      // Nautical twilight
      final t = (sunAltitude + 12) / 6; // 0 to 1
      return [
        Color.lerp(const Color(0xFF001845), const Color(0xFF003566), t)!,
        Color.lerp(const Color(0xFF003566), const Color(0xFF0077B6), t)!,
        Color.lerp(const Color(0xFF005F99), const Color(0xFFFF8C00), t)!,
      ];
    } else if (sunAltitude > -18) {
      // Astronomical twilight
      final t = (sunAltitude + 18) / 6; // 0 to 1
      return [
        Color.lerp(const Color(0xFF000814), const Color(0xFF001845), t)!,
        Color.lerp(const Color(0xFF001D3D), const Color(0xFF003566), t)!,
        Color.lerp(const Color(0xFF002855), const Color(0xFF005F99), t)!,
      ];
    } else {
      // Night (Sun well below horizon)
      return const [
        Color(0xFF000814), // Almost black (top)
        Color(0xFF001D3D), // Very dark blue (middle)
        Color(0xFF002855), // Dark blue (horizon)
      ];
    }
  }
  
  /// Draw subtle background stars (for atmosphere)
  void _drawBackgroundStars(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent stars
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw 100 subtle background stars
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      
      // Opacity increases with night darkness
      final opacity = ((18 + sunAltitude).abs() / 18 * 0.4).clamp(0.0, 0.4);
      starPaint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }
  
  /// Draw atmospheric glow near horizon during twilight
  void _drawAtmosphericGlow(Canvas canvas, Size size) {
    // Only during twilight
    if (sunAltitude < -18 || sunAltitude > 6) return;
    
    // Calculate glow intensity
    final intensity = sunAltitude > 0
        ? (6 - sunAltitude) / 6
        : (sunAltitude + 18) / 18;
    
    // Glow color (orange/yellow)
    final glowColor = sunAltitude > -6
        ? const Color(0xFFFFA500) // Orange
        : const Color(0xFFFF8C00); // Dark orange
    
    // Draw radial gradient at bottom
    final glowGradient = RadialGradient(
      center: Alignment.bottomCenter,
      radius: 1.0,
      colors: [
        glowColor.withOpacity(intensity * 0.3),
        glowColor.withOpacity(intensity * 0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      );
    
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      glowPaint,
    );
  }
  
  @override
  bool shouldRepaint(SkyBackgroundPainter oldDelegate) {
    // Repaint if sun altitude changed significantly (>1°)
    return (sunAltitude - oldDelegate.sunAltitude).abs() > 1.0;
  }
  
  /// Get twilight type as string
  String getTwilightType() {
    if (sunAltitude > 0) return 'Day';
    if (sunAltitude > -6) return 'Civil Twilight';
    if (sunAltitude > -12) return 'Nautical Twilight';
    if (sunAltitude > -18) return 'Astronomical Twilight';
    return 'Night';
  }
  
  /// Get dominant sky color for UI elements
  Color getDominantColor() {
    final colors = _getSkyColors();
    return colors[1]; // Middle color
  }
}

/// Simple widget wrapper for sky background
class SkyBackground extends StatelessWidget {
  final double sunAltitude;
  final DateTime currentTime;
  final Widget? child;
  
  const SkyBackground({
    super.key,
    required this.sunAltitude,
    required this.currentTime,
    this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SkyBackgroundPainter(
        sunAltitude: sunAltitude,
        currentTime: currentTime,
      ),
      child: child,
    );
  }
}

/// Twilight type enum for convenience
enum TwilightType {
  day,
  civilTwilight,
  nauticalTwilight,
  astronomicalTwilight,
  night,
}

/// Extension to get twilight type from sun altitude
extension SunAltitudeTwilight on double {
  TwilightType get twilightType {
    if (this > 0) return TwilightType.day;
    if (this > -6) return TwilightType.civilTwilight;
    if (this > -12) return TwilightType.nauticalTwilight;
    if (this > -18) return TwilightType.astronomicalTwilight;
    return TwilightType.night;
  }
  
  String get twilightName {
    switch (twilightType) {
      case TwilightType.day:
        return 'Siang';
      case TwilightType.civilTwilight:
        return 'Senja Sipil';
      case TwilightType.nauticalTwilight:
        return 'Senja Nautika';
      case TwilightType.astronomicalTwilight:
        return 'Senja Astronomi';
      case TwilightType.night:
        return 'Malam';
    }
  }
}