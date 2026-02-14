import 'dart:math' as math;
import '../models/sky_coordinates.dart';

/// Core astronomy calculations engine
class AstronomyEngine {
  static const double deg2rad = math.pi / 180.0;
  static const double rad2deg = 180.0 / math.pi;
  
  /// Calculate Julian Date from DateTime
  static double calculateJulianDate(DateTime dateTime) {
    final y = dateTime.year;
    final m = dateTime.month;
    final d = dateTime.day;
    final hour = dateTime.hour + dateTime.minute / 60.0 + dateTime.second / 3600.0;
    
    final a = (14 - m) ~/ 12;
    final y1 = y + 4800 - a;
    final m1 = m + 12 * a - 3;
    
    final jdn = d + (153 * m1 + 2) ~/ 5 + 365 * y1 + 
                y1 ~/ 4 - y1 ~/ 100 + y1 ~/ 400 - 32045;
    
    return jdn + (hour - 12) / 24.0;
  }
  
  /// Calculate Julian Day Number (integer part)
  static int calculateJDN(DateTime dateTime) {
    return calculateJulianDate(dateTime).floor();
  }
  
  /// Calculate Julian centuries from J2000.0
  static double calculateJulianCenturies(double jd) {
    return (jd - 2451545.0) / 36525.0;
  }
  
  /// Calculate Greenwich Mean Sidereal Time (GMST) in degrees
  static double calculateGMST(DateTime dateTime) {
    final jd = calculateJulianDate(dateTime);
    final t = (jd - 2451545.0) / 36525.0;
    
    // GMST at 0h UT
    var gmst = 280.46061837 + 
               360.98564736629 * (jd - 2451545.0) +
               0.000387933 * t * t -
               t * t * t / 38710000.0;
    
    // Normalize to 0-360
    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;
    
    return gmst;
  }
  
  /// Calculate Local Sidereal Time (LST) in degrees
  static double calculateLST(DateTime dateTime, double longitude) {
    final gmst = calculateGMST(dateTime);
    var lst = gmst + longitude;
    
    // Normalize to 0-360
    lst = lst % 360.0;
    if (lst < 0) lst += 360.0;
    
    return lst;
  }
  
  /// Transform equatorial coordinates to horizontal coordinates
  /// RA, Dec in degrees
  /// Latitude in degrees
  /// LST in degrees
  static HorizontalCoordinates equatorialToHorizontal({
    required double rightAscension,
    required double declination,
    required double latitude,
    required double localSiderealTime,
  }) {
    // Calculate hour angle
    var hourAngle = localSiderealTime - rightAscension;
    
    // Normalize hour angle
    hourAngle = hourAngle % 360.0;
    if (hourAngle < 0) hourAngle += 360.0;
    
    // Convert to radians
    final haRad = hourAngle * deg2rad;
    final decRad = declination * deg2rad;
    final latRad = latitude * deg2rad;
    
    // Calculate altitude
    final sinAlt = math.sin(decRad) * math.sin(latRad) +
                   math.cos(decRad) * math.cos(latRad) * math.cos(haRad);
    final altitude = math.asin(sinAlt.clamp(-1.0, 1.0)) * rad2deg;
    
    // Calculate azimuth
    final cosAz = (math.sin(decRad) - math.sin(latRad) * math.sin(altitude * deg2rad)) /
                  (math.cos(latRad) * math.cos(altitude * deg2rad));
    var azimuth = math.acos(cosAz.clamp(-1.0, 1.0)) * rad2deg;
    
    // Adjust azimuth based on hour angle
    if (math.sin(haRad) > 0) {
      azimuth = 360.0 - azimuth;
    }
    
    return HorizontalCoordinates(
      azimuth: azimuth,
      altitude: altitude,
    );
  }
  
  /// Apply atmospheric refraction correction
  /// Altitude in degrees
  /// Returns corrected altitude in degrees
  static double applyRefraction(double altitude) {
    if (altitude < -2) return altitude; // Below horizon, no correction
    
    // Simple refraction formula (Bennett's formula)
    // R ≈ 1.02 / tan(h + 10.3/(h + 5.11)) arcminutes
    final h = altitude;
    final r = 1.02 / math.tan((h + 10.3 / (h + 5.11)) * deg2rad);
    
    return altitude + r / 60.0; // Convert arcminutes to degrees
  }
  
  /// Calculate angular separation between two points
  /// All coordinates in degrees
  static double angularSeparation({
    required double az1,
    required double alt1,
    required double az2,
    required double alt2,
  }) {
    final az1Rad = az1 * deg2rad;
    final alt1Rad = alt1 * deg2rad;
    final az2Rad = az2 * deg2rad;
    final alt2Rad = alt2 * deg2rad;
    
    final cosDistance = 
        math.sin(alt1Rad) * math.sin(alt2Rad) +
        math.cos(alt1Rad) * math.cos(alt2Rad) * math.cos(az1Rad - az2Rad);
    
    return math.acos(cosDistance.clamp(-1.0, 1.0)) * rad2deg;
  }
  
  /// Normalize angle to 0-360 range
  static double normalizeAngle(double angle) {
    var normalized = angle % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized;
  }
  
  /// Calculate mean obliquity of ecliptic (axial tilt)
  /// Returns obliquity in degrees
  static double calculateObliquity(double jd) {
    final t = calculateJulianCenturies(jd);
    
    // IAU formula
    final obliquity = 23.439291 - 
                     0.0130042 * t -
                     0.00000164 * t * t +
                     0.000000504 * t * t * t;
    
    return obliquity;
  }
  
  /// Convert ecliptic coordinates to equatorial
  /// Lambda (longitude), Beta (latitude) in degrees
  /// Returns RA, Dec in degrees
  static EquatorialCoordinates eclipticToEquatorial({
    required double lambda,
    required double beta,
    required double obliquity,
  }) {
    final lambdaRad = lambda * deg2rad;
    final betaRad = beta * deg2rad;
    final oblRad = obliquity * deg2rad;
    
    // Calculate RA
    final ra = math.atan2(
      math.sin(lambdaRad) * math.cos(oblRad) - 
      math.tan(betaRad) * math.sin(oblRad),
      math.cos(lambdaRad)
    ) * rad2deg;
    
    // Calculate Dec
    final dec = math.asin(
      math.sin(betaRad) * math.cos(oblRad) +
      math.cos(betaRad) * math.sin(oblRad) * math.sin(lambdaRad)
    ) * rad2deg;
    
    return EquatorialCoordinates(
      rightAscension: normalizeAngle(ra),
      declination: dec,
    );
  }
}