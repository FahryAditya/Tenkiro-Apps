import 'dart:math' as math;
import '../models/sky_coordinates.dart';
import '../models/celestial-object.dart';
import 'astronomy_engine.dart';

/// Solar position calculator
/// Uses low-accuracy formula (±0.5° sufficient for visualization)
class SolarCalculator {
  /// Calculate Sun's equatorial coordinates
  static EquatorialCoordinates calculateSunPosition(DateTime dateTime) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    final n = jd - 2451545.0; // Days since J2000.0
    
    // Mean longitude of the Sun (degrees)
    var L = 280.460 + 0.9856474 * n;
    L = AstronomyEngine.normalizeAngle(L);
    
    // Mean anomaly (degrees)
    var g = 357.528 + 0.9856003 * n;
    g = AstronomyEngine.normalizeAngle(g);
    final gRad = g * AstronomyEngine.deg2rad;
    
    // Ecliptic longitude (degrees)
    var lambda = L + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad);
    lambda = AstronomyEngine.normalizeAngle(lambda);
    
    // Obliquity of ecliptic
    final obliquity = AstronomyEngine.calculateObliquity(jd);
    
    // Convert ecliptic to equatorial coordinates
    return AstronomyEngine.eclipticToEquatorial(
      lambda: lambda,
      beta: 0, // Sun is always on the ecliptic plane
      obliquity: obliquity,
    );
  }
  
  /// Calculate Sun object with position
  static Sun calculateSun(DateTime dateTime) {
    final equatorial = calculateSunPosition(dateTime);
    
    return Sun(
      equatorial: equatorial,
      magnitude: -26.74, // Apparent magnitude of Sun
    );
  }
  
  /// Calculate sunrise time (approximate)
  static DateTime? calculateSunrise({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // Start at midnight
    var testTime = DateTime(date.year, date.month, date.day, 0, 0);
    
    // Search for sunrise (Sun altitude crosses 0°)
    for (var hour = 0; hour < 24; hour++) {
      testTime = DateTime(date.year, date.month, date.day, hour, 0);
      
      final sunPos = calculateSunPosition(testTime);
      final lst = AstronomyEngine.calculateLST(testTime, longitude);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: sunPos.rightAscension,
        declination: sunPos.declination,
        latitude: latitude,
        localSiderealTime: lst,
      );
      
      // Check if Sun is rising (altitude near 0° and increasing)
      if (horizontal.altitude > -1 && horizontal.altitude < 1 && hour < 12) {
        return testTime;
      }
    }
    
    return null;
  }
  
  /// Calculate sunset time (approximate)
  static DateTime? calculateSunset({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // Start at noon
    var testTime = DateTime(date.year, date.month, date.day, 12, 0);
    
    // Search for sunset (Sun altitude crosses 0°)
    for (var hour = 12; hour < 24; hour++) {
      testTime = DateTime(date.year, date.month, date.day, hour, 0);
      
      final sunPos = calculateSunPosition(testTime);
      final lst = AstronomyEngine.calculateLST(testTime, longitude);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: sunPos.rightAscension,
        declination: sunPos.declination,
        latitude: latitude,
        localSiderealTime: lst,
      );
      
      // Check if Sun is setting (altitude near 0° and decreasing)
      if (horizontal.altitude > -1 && horizontal.altitude < 1 && hour > 12) {
        return testTime;
      }
    }
    
    return null;
  }
  
  /// Calculate solar noon (when Sun reaches highest altitude)
  static DateTime calculateSolarNoon({
    required DateTime date,
    required double longitude,
  }) {
    // Solar noon occurs when LST ≈ Sun's RA
    // Approximate calculation
    final sunPos = calculateSunPosition(
      DateTime(date.year, date.month, date.day, 12, 0)
    );
    
    // Calculate when LST = RA
    final gmst = AstronomyEngine.calculateGMST(
      DateTime(date.year, date.month, date.day, 12, 0)
    );
    
    var hourAngle = gmst + longitude - sunPos.rightAscension;
    hourAngle = AstronomyEngine.normalizeAngle(hourAngle);
    
    // Convert to time
    final hoursFromMidnight = 12 - (hourAngle / 15);
    final hour = hoursFromMidnight.floor();
    final minute = ((hoursFromMidnight - hour) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
  /// Get twilight type based on Sun altitude
  static TwilightType getTwilightType(double sunAltitude) {
    if (sunAltitude > 0) {
      return TwilightType.day;
    } else if (sunAltitude > -6) {
      return TwilightType.civil;
    } else if (sunAltitude > -12) {
      return TwilightType.nautical;
    } else if (sunAltitude > -18) {
      return TwilightType.astronomical;
    } else {
      return TwilightType.night;
    }
  }
  
  /// Calculate Sun's distance from Earth (AU)
  static double calculateSunDistance(DateTime dateTime) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    final n = jd - 2451545.0;
    
    // Mean anomaly
    var g = 357.528 + 0.9856003 * n;
    g = AstronomyEngine.normalizeAngle(g);
    final gRad = g * AstronomyEngine.deg2rad;
    
    // Distance in AU (approximate)
    final distance = 1.00014 - 0.01671 * math.cos(gRad) - 
                     0.00014 * math.cos(2 * gRad);
    
    return distance;
  }
}

enum TwilightType {
  day,           // Sun > 0°
  civil,         // -6° < Sun < 0°
  nautical,      // -12° < Sun < -6°
  astronomical,  // -18° < Sun < -12°
  night,         // Sun < -18°
}