import 'dart:math' as math;
import '../models/sky_coordinates.dart';
import '../models/celestial-object.dart';
import 'astronomy_engine.dart';

/// Lunar position calculator
/// Uses simplified theory (±1° accuracy)
class LunarCalculator {
  /// Calculate Moon's equatorial coordinates
  static EquatorialCoordinates calculateMoonPosition(DateTime dateTime) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    final d = jd - 2451545.0; // Days since J2000.0
    
    // Moon's mean longitude (degrees)
    var L = 218.316 + 13.176396 * d;
    L = AstronomyEngine.normalizeAngle(L);
    
    // Mean anomaly (degrees)
    var M = 134.963 + 13.064993 * d;
    M = AstronomyEngine.normalizeAngle(M);
    final MRad = M * AstronomyEngine.deg2rad;
    
    // Argument of latitude (degrees)
    var F = 93.272 + 13.229350 * d;
    F = AstronomyEngine.normalizeAngle(F);
    final FRad = F * AstronomyEngine.deg2rad;
    
    // Ecliptic longitude (degrees)
    var lambda = L + 6.289 * math.sin(MRad);
    lambda = AstronomyEngine.normalizeAngle(lambda);
    
    // Ecliptic latitude (degrees)
    final beta = 5.128 * math.sin(FRad);
    
    // Obliquity of ecliptic
    final obliquity = AstronomyEngine.calculateObliquity(jd);
    
    // Convert ecliptic to equatorial
    return AstronomyEngine.eclipticToEquatorial(
      lambda: lambda,
      beta: beta,
      obliquity: obliquity,
    );
  }
  
  /// Calculate Moon age (days since new moon)
  static double calculateMoonAge(DateTime dateTime) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    
    // Known new moon: January 6, 2000, 18:14 UTC
    const knownNewMoon = 2451550.26;
    const synodicMonth = 29.530588861; // Mean synodic month
    
    final daysSinceKnownNewMoon = jd - knownNewMoon;
    final moonAge = daysSinceKnownNewMoon % synodicMonth;
    
    return moonAge;
  }
  
  /// Calculate Moon phase (0-1, where 0=new, 0.5=full)
  static double calculateMoonPhase(DateTime dateTime) {
    final age = calculateMoonAge(dateTime);
    return age / 29.530588861;
  }
  
  /// Calculate Moon illumination (0-100%)
  static double calculateMoonIllumination(DateTime dateTime) {
    final phase = calculateMoonPhase(dateTime);
    
    // Illumination formula
    // 0% at new moon (phase=0)
    // 100% at full moon (phase=0.5)
    // 0% at next new moon (phase=1)
    final illumination = 50 * (1 - math.cos(phase * 2 * math.pi));
    
    return illumination;
  }
  
  /// Calculate Moon object with position and phase
  static Moon calculateMoon(DateTime dateTime) {
    final equatorial = calculateMoonPosition(dateTime);
    final phase = calculateMoonPhase(dateTime);
    final illumination = calculateMoonIllumination(dateTime);
    
    // Moon's apparent magnitude varies
    // Average: +12.7 at full, dimmer at other phases
    final magnitude = -12.74 + 2.5 * math.log(illumination / 100) / math.ln10;
    
    return Moon(
      equatorial: equatorial,
      magnitude: magnitude,
      phase: phase,
      illumination: illumination,
    );
  }
  
  /// Calculate Moon's distance from Earth (km)
  static double calculateMoonDistance(DateTime dateTime) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    final d = jd - 2451545.0;
    
    // Mean anomaly
    var M = 134.963 + 13.064993 * d;
    M = AstronomyEngine.normalizeAngle(M);
    final MRad = M * AstronomyEngine.deg2rad;
    
    // Distance in km (simplified)
    final distance = 385001 - 20905 * math.cos(MRad);
    
    return distance;
  }
  
  /// Calculate Moon's angular diameter (degrees)
  static double calculateMoonAngularDiameter(DateTime dateTime) {
    final distance = calculateMoonDistance(dateTime);
    
    // Moon's physical diameter: 3474 km
    // Angular diameter = 2 * arctan(radius / distance)
    const moonRadius = 1737.0; // km
    final angularDiameter = 2 * math.atan(moonRadius / distance) * 
                           AstronomyEngine.rad2deg;
    
    return angularDiameter;
  }
  
  /// Get Moon phase name
  static String getMoonPhaseName(double phase) {
    if (phase < 0.0625) return 'Bulan Baru';
    if (phase < 0.1875) return 'Sabit Awal';
    if (phase < 0.3125) return 'Kuarter Awal';
    if (phase < 0.4375) return 'Cembung Awal';
    if (phase < 0.5625) return 'Purnama';
    if (phase < 0.6875) return 'Cembung Akhir';
    if (phase < 0.8125) return 'Kuarter Akhir';
    return 'Sabit Akhir';
  }
  
  /// Get Moon phase emoji
  static String getMoonPhaseEmoji(double phase) {
    if (phase < 0.0625) return '🌑';
    if (phase < 0.1875) return '🌒';
    if (phase < 0.3125) return '🌓';
    if (phase < 0.4375) return '🌔';
    if (phase < 0.5625) return '🌕';
    if (phase < 0.6875) return '🌖';
    if (phase < 0.8125) return '🌗';
    return '🌘';
  }
  
  /// Calculate moonrise time (simplified)
  static DateTime? calculateMoonrise({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // Search for moonrise
    for (var hour = 0; hour < 24; hour++) {
      final testTime = DateTime(date.year, date.month, date.day, hour, 0);
      
      final moonPos = calculateMoonPosition(testTime);
      final lst = AstronomyEngine.calculateLST(testTime, longitude);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: moonPos.rightAscension,
        declination: moonPos.declination,
        latitude: latitude,
        localSiderealTime: lst,
      );
      
      if (horizontal.altitude > -1 && horizontal.altitude < 1 && hour < 12) {
        return testTime;
      }
    }
    
    return null;
  }
  
  /// Calculate moonset time (simplified)
  static DateTime? calculateMoonset({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // Search for moonset
    for (var hour = 12; hour < 24; hour++) {
      final testTime = DateTime(date.year, date.month, date.day, hour, 0);
      
      final moonPos = calculateMoonPosition(testTime);
      final lst = AstronomyEngine.calculateLST(testTime, longitude);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: moonPos.rightAscension,
        declination: moonPos.declination,
        latitude: latitude,
        localSiderealTime: lst,
      );
      
      if (horizontal.altitude > -1 && horizontal.altitude < 1 && hour > 12) {
        return testTime;
      }
    }
    
    return null;
  }
  
  /// Check if Moon is visible at given time and location
  static bool isMoonVisible({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
  }) {
    final moonPos = calculateMoonPosition(dateTime);
    final lst = AstronomyEngine.calculateLST(dateTime, longitude);
    final horizontal = AstronomyEngine.equatorialToHorizontal(
      rightAscension: moonPos.rightAscension,
      declination: moonPos.declination,
      latitude: latitude,
      localSiderealTime: lst,
    );
    
    return horizontal.altitude > 0;
  }
}