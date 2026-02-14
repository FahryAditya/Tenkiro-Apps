import 'dart:math' as math;
import '../models/sky_coordinates.dart';
import 'astronomy_engine.dart';

/// Coordinate transformation utilities
class CoordinateTransformer {
  /// Transform list of equatorial coordinates to horizontal
  static List<HorizontalCoordinates> batchEquatorialToHorizontal({
    required List<EquatorialCoordinates> equatorialList,
    required double latitude,
    required double localSiderealTime,
  }) {
    return equatorialList.map((eq) {
      return AstronomyEngine.equatorialToHorizontal(
        rightAscension: eq.rightAscension,
        declination: eq.declination,
        latitude: latitude,
        localSiderealTime: localSiderealTime,
      );
    }).toList();
  }
  
  /// Calculate angular distance between two equatorial coordinates
  static double angularDistance({
    required EquatorialCoordinates coord1,
    required EquatorialCoordinates coord2,
  }) {
    final ra1 = coord1.rightAscension * AstronomyEngine.deg2rad;
    final dec1 = coord1.declination * AstronomyEngine.deg2rad;
    final ra2 = coord2.rightAscension * AstronomyEngine.deg2rad;
    final dec2 = coord2.declination * AstronomyEngine.deg2rad;
    
    final cosDistance = 
        math.sin(dec1) * math.sin(dec2) +
        math.cos(dec1) * math.cos(dec2) * math.cos(ra1 - ra2);
    
    return math.acos(cosDistance.clamp(-1.0, 1.0)) * AstronomyEngine.rad2deg;
  }
  
  /// Calculate bearing between two horizontal coordinates
  static double calculateBearing({
    required HorizontalCoordinates from,
    required HorizontalCoordinates to,
  }) {
    final azDiff = to.azimuth - from.azimuth;
    return AstronomyEngine.normalizeAngle(azDiff);
  }
  
  /// Convert altitude-azimuth to cartesian (x, y, z on unit sphere)
  static Map<String, double> horizontalToCartesian(
    HorizontalCoordinates coords,
  ) {
    final azRad = coords.azimuth * AstronomyEngine.deg2rad;
    final altRad = coords.altitude * AstronomyEngine.deg2rad;
    
    final x = math.cos(altRad) * math.sin(azRad);
    final y = math.cos(altRad) * math.cos(azRad);
    final z = math.sin(altRad);
    
    return {'x': x, 'y': y, 'z': z};
  }
  
  /// Convert cartesian to altitude-azimuth
  static HorizontalCoordinates cartesianToHorizontal({
    required double x,
    required double y,
    required double z,
  }) {
    final r = math.sqrt(x * x + y * y + z * z);
    
    final altitude = math.asin(z / r) * AstronomyEngine.rad2deg;
    final azimuth = math.atan2(x, y) * AstronomyEngine.rad2deg;
    
    return HorizontalCoordinates(
      azimuth: AstronomyEngine.normalizeAngle(azimuth),
      altitude: altitude,
    );
  }
  
  /// Calculate parallactic angle
  /// (angle between north celestial pole and zenith)
  static double calculateParallacticAngle({
    required double latitude,
    required double declination,
    required double hourAngle,
  }) {
    final latRad = latitude * AstronomyEngine.deg2rad;
    final decRad = declination * AstronomyEngine.deg2rad;
    final haRad = hourAngle * AstronomyEngine.deg2rad;
    
    final sinQ = math.sin(haRad) * math.cos(latRad) / 
                  math.cos(decRad);
    final cosQ = (math.sin(latRad) - math.sin(decRad) * math.sin(latRad)) /
                  (math.cos(decRad) * math.cos(latRad));
    
    final q = math.atan2(sinQ, cosQ) * AstronomyEngine.rad2deg;
    return q;
  }
  
  /// Calculate airmass (atmospheric extinction)
  /// Returns relative airmass (1.0 at zenith)
  static double calculateAirmass(double altitude) {
    if (altitude <= 0) return double.infinity; // Below horizon
    
    final zenithAngle = 90 - altitude;
    final zenithRad = zenithAngle * AstronomyEngine.deg2rad;
    
    // Simplified Kasten-Young formula
    final airmass = 1.0 / 
        (math.cos(zenithRad) + 
         0.50572 * math.pow((96.07995 - zenithAngle), -1.6364));
    
    return airmass;
  }
  
  /// Convert galactic coordinates to equatorial (J2000)
  /// Simplified transformation
  static EquatorialCoordinates galacticToEquatorial({
    required double galacticLongitude,
    required double galacticLatitude,
  }) {
    // Galactic pole (J2000): RA=192.8595°, Dec=27.1284°
    const poleRA = 192.8595;
    const poleDec = 27.1284;
    const nodeAscending = 32.9319;
    
    final lRad = galacticLongitude * AstronomyEngine.deg2rad;
    final bRad = galacticLatitude * AstronomyEngine.deg2rad;
    final poleRad = poleDec * AstronomyEngine.deg2rad;
    final nodeRad = (nodeAscending - poleRA) * AstronomyEngine.deg2rad;
    
    final sinDec = math.cos(bRad) * math.cos(poleRad) * 
                   math.sin(lRad - nodeRad) +
                   math.sin(bRad) * math.sin(poleRad);
    final dec = math.asin(sinDec) * AstronomyEngine.rad2deg;
    
    final y = math.cos(bRad) * math.cos(lRad - nodeRad);
    final x = math.sin(bRad) * math.cos(poleRad) - 
              math.cos(bRad) * math.sin(poleRad) * math.sin(lRad - nodeRad);
    
    var ra = math.atan2(y, x) * AstronomyEngine.rad2deg + poleRA;
    ra = AstronomyEngine.normalizeAngle(ra);
    
    return EquatorialCoordinates(
      rightAscension: ra,
      declination: dec,
    );
  }
  
  /// Calculate rise/set azimuth for given declination and latitude
  static Map<String, double> calculateRiseSetAzimuth({
    required double latitude,
    required double declination,
  }) {
    final latRad = latitude * AstronomyEngine.deg2rad;
    final decRad = declination * AstronomyEngine.deg2rad;
    
    final cosAz = -math.sin(decRad) / math.cos(latRad);
    
    // If object is circumpolar or never rises
    if (cosAz < -1 || cosAz > 1) {
      return {'rise': double.nan, 'set': double.nan};
    }
    
    final azRise = math.acos(cosAz) * AstronomyEngine.rad2deg;
    final azSet = 360 - azRise;
    
    return {'rise': azRise, 'set': azSet};
  }
  
  /// Convert screen coordinates to horizontal coordinates
  /// Given device orientation and field of view
  static HorizontalCoordinates screenToHorizontal({
    required double screenX,
    required double screenY,
    required double screenWidth,
    required double screenHeight,
    required DeviceOrientation deviceOrientation,
    required FieldOfView fieldOfView,
  }) {
    // Normalize screen coordinates to -1 to 1
    final normX = (screenX / screenWidth - 0.5) * 2;
    final normY = (screenY / screenHeight - 0.5) * 2;
    
    // Calculate angular offset from center
    final deltaAz = normX * fieldOfView.horizontal / 2;
    final deltaAlt = -normY * fieldOfView.vertical / 2; // Negative for screen coords
    
    // Get center coordinates
    final centerCoords = deviceOrientation.toHorizontalCoordinates();
    
    // Add offset
    final azimuth = AstronomyEngine.normalizeAngle(
      centerCoords.azimuth + deltaAz
    );
    final altitude = (centerCoords.altitude + deltaAlt).clamp(-90.0, 90.0);
    
    return HorizontalCoordinates(
      azimuth: azimuth,
      altitude: altitude,
    );
  }
  
  /// Convert horizontal coordinates to screen coordinates
  static Map<String, double>? horizontalToScreen({
    required HorizontalCoordinates coords,
    required double screenWidth,
    required double screenHeight,
    required DeviceOrientation deviceOrientation,
    required FieldOfView fieldOfView,
  }) {
    final centerCoords = deviceOrientation.toHorizontalCoordinates();
    
    // Calculate angular offset from center
    var deltaAz = coords.azimuth - centerCoords.azimuth;
    
    // Handle wrap-around
    if (deltaAz > 180) deltaAz -= 360;
    if (deltaAz < -180) deltaAz += 360;
    
    final deltaAlt = coords.altitude - centerCoords.altitude;
    
    // Check if in field of view
    if (deltaAz.abs() > fieldOfView.horizontal / 2 ||
        deltaAlt.abs() > fieldOfView.vertical / 2) {
      return null; // Outside FOV
    }
    
    // Normalize to -1 to 1
    final normX = deltaAz / (fieldOfView.horizontal / 2);
    final normY = -deltaAlt / (fieldOfView.vertical / 2);
    
    // Convert to screen coordinates
    final screenX = (normX / 2 + 0.5) * screenWidth;
    final screenY = (normY / 2 + 0.5) * screenHeight;
    
    return {'x': screenX, 'y': screenY};
  }
}