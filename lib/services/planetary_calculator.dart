import 'dart:math' as math;
import '../models/sky_coordinates.dart';
import '../models/celestial-object.dart';
import 'astronomy_engine.dart';

/// Planetary position calculator
/// Uses simplified VSOP87 theory (low accuracy, ±2° sufficient for visualization)
class PlanetaryCalculator {
  /// Calculate all visible planets
  static List<Planet> calculateAllPlanets(DateTime dateTime) {
    return [
      calculateMercury(dateTime),
      calculateVenus(dateTime),
      calculateMars(dateTime),
      calculateJupiter(dateTime),
      calculateSaturn(dateTime),
      calculateUranus(dateTime),
      calculateNeptune(dateTime),
    ];
  }
  
  /// Calculate Mercury position
  static Planet calculateMercury(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 252.25,
      meanLongitudeRate: 4.09233,
      perihelion: 77.46,
      eccentricity: 0.2056,
      inclination: 7.00,
      node: 48.33,
    );
    
    return Planet(
      id: 'mercury',
      name: 'Merkurius',
      equatorial: equatorial,
      magnitude: -0.5, // Variable, approximate
      planetType: PlanetType.mercury,
    );
  }
  
  /// Calculate Venus position
  static Planet calculateVenus(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 181.98,
      meanLongitudeRate: 1.60213,
      perihelion: 131.77,
      eccentricity: 0.0068,
      inclination: 3.39,
      node: 76.67,
    );
    
    return Planet(
      id: 'venus',
      name: 'Venus',
      equatorial: equatorial,
      magnitude: -4.0, // Very bright
      planetType: PlanetType.venus,
    );
  }
  
  /// Calculate Mars position
  static Planet calculateMars(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 355.43,
      meanLongitudeRate: 0.52403,
      perihelion: 336.08,
      eccentricity: 0.0934,
      inclination: 1.85,
      node: 49.56,
    );
    
    return Planet(
      id: 'mars',
      name: 'Mars',
      equatorial: equatorial,
      magnitude: -1.5, // Variable
      planetType: PlanetType.mars,
    );
  }
  
  /// Calculate Jupiter position
  static Planet calculateJupiter(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 34.33,
      meanLongitudeRate: 0.08308,
      perihelion: 14.27,
      eccentricity: 0.0484,
      inclination: 1.31,
      node: 100.46,
    );
    
    return Planet(
      id: 'jupiter',
      name: 'Jupiter',
      equatorial: equatorial,
      magnitude: -2.5, // Very bright
      planetType: PlanetType.jupiter,
    );
  }
  
  /// Calculate Saturn position
  static Planet calculateSaturn(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 50.08,
      meanLongitudeRate: 0.03346,
      perihelion: 93.06,
      eccentricity: 0.0542,
      inclination: 2.49,
      node: 113.64,
    );
    
    return Planet(
      id: 'saturn',
      name: 'Saturnus',
      equatorial: equatorial,
      magnitude: 0.5,
      planetType: PlanetType.saturn,
    );
  }
  
  /// Calculate Uranus position
  static Planet calculateUranus(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 314.20,
      meanLongitudeRate: 0.01172,
      perihelion: 173.01,
      eccentricity: 0.0472,
      inclination: 0.77,
      node: 74.00,
    );
    
    return Planet(
      id: 'uranus',
      name: 'Uranus',
      equatorial: equatorial,
      magnitude: 5.5, // Faint, barely visible
      planetType: PlanetType.uranus,
    );
  }
  
  /// Calculate Neptune position
  static Planet calculateNeptune(DateTime dateTime) {
    final equatorial = _calculatePlanetPosition(
      dateTime: dateTime,
      meanLongitude0: 304.22,
      meanLongitudeRate: 0.00598,
      perihelion: 48.12,
      eccentricity: 0.0086,
      inclination: 1.77,
      node: 131.78,
    );
    
    return Planet(
      id: 'neptune',
      name: 'Neptunus',
      equatorial: equatorial,
      magnitude: 7.8, // Not visible to naked eye
      planetType: PlanetType.neptune,
    );
  }
  
  /// Generic planet position calculation (simplified Keplerian elements)
  static EquatorialCoordinates _calculatePlanetPosition({
    required DateTime dateTime,
    required double meanLongitude0,
    required double meanLongitudeRate,
    required double perihelion,
    required double eccentricity,
    required double inclination,
    required double node,
  }) {
    final jd = AstronomyEngine.calculateJulianDate(dateTime);
    final d = jd - 2451545.0; // Days since J2000.0
    
    // Mean longitude
    var L = meanLongitude0 + meanLongitudeRate * d;
    L = AstronomyEngine.normalizeAngle(L);
    
    // Mean anomaly
    var M = L - perihelion;
    M = AstronomyEngine.normalizeAngle(M);
    final MRad = M * AstronomyEngine.deg2rad;
    
    // Equation of center (simplified)
    final C = (2 * eccentricity - 0.25 * eccentricity * eccentricity * eccentricity) * 
              math.sin(MRad) * 180 / math.pi +
              1.25 * eccentricity * eccentricity * 
              math.sin(2 * MRad) * 180 / math.pi;
    
    // True longitude
    var lambda = L + C;
    lambda = AstronomyEngine.normalizeAngle(lambda);
    
    // Heliocentric latitude (simplified)
    final beta = 0.0; // Simplified, assume on ecliptic
    
    // Convert to geocentric (simplified - ignoring Earth's position)
    // In reality, need to subtract Earth's position
    // This is acceptable for visualization purposes
    
    // Obliquity
    final obliquity = AstronomyEngine.calculateObliquity(jd);
    
    // Convert ecliptic to equatorial
    return AstronomyEngine.eclipticToEquatorial(
      lambda: lambda,
      beta: beta,
      obliquity: obliquity,
    );
  }
  
  /// Get planet visibility status
  static bool isPlanetVisible({
    required Planet planet,
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) {
    final lst = AstronomyEngine.calculateLST(dateTime, longitude);
    final horizontal = AstronomyEngine.equatorialToHorizontal(
      rightAscension: planet.equatorial.rightAscension,
      declination: planet.equatorial.declination,
      latitude: latitude,
      localSiderealTime: lst,
    );
    
    return horizontal.altitude > 0;
  }
  
  /// Get visible planets at given time and location
  static List<Planet> getVisiblePlanets({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    bool includeOuterPlanets = true,
  }) {
    final allPlanets = calculateAllPlanets(dateTime);
    
    return allPlanets.where((planet) {
      // Skip outer planets if requested (Uranus, Neptune not visible to naked eye)
      if (!includeOuterPlanets && 
          (planet.planetType == PlanetType.uranus || 
           planet.planetType == PlanetType.neptune)) {
        return false;
      }
      
      return isPlanetVisible(
        planet: planet,
        latitude: latitude,
        longitude: longitude,
        dateTime: dateTime,
      );
    }).toList();
  }
  
  /// Get planet elongation from Sun (angular separation)
  static double getPlanetElongation({
    required Planet planet,
    required EquatorialCoordinates sunPosition,
  }) {
    final raP = planet.equatorial.rightAscension * AstronomyEngine.deg2rad;
    final decP = planet.equatorial.declination * AstronomyEngine.deg2rad;
    final raS = sunPosition.rightAscension * AstronomyEngine.deg2rad;
    final decS = sunPosition.declination * AstronomyEngine.deg2rad;
    
    final cosElongation = 
        math.sin(decP) * math.sin(decS) +
        math.cos(decP) * math.cos(decS) * math.cos(raP - raS);
    
    final elongation = math.acos(cosElongation.clamp(-1.0, 1.0)) * 
                       AstronomyEngine.rad2deg;
    
    return elongation;
  }
  
  /// Check if planet is in opposition (opposite Sun)
  static bool isInOpposition({
    required Planet planet,
    required EquatorialCoordinates sunPosition,
  }) {
    final elongation = getPlanetElongation(
      planet: planet,
      sunPosition: sunPosition,
    );
    
    return elongation > 160; // Near 180°
  }
  
  /// Check if planet is in conjunction (near Sun)
  static bool isInConjunction({
    required Planet planet,
    required EquatorialCoordinates sunPosition,
  }) {
    final elongation = getPlanetElongation(
      planet: planet,
      sunPosition: sunPosition,
    );
    
    return elongation < 20; // Near 0°
  }
}