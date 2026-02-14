import 'dart:math' as math;

/// Horizontal coordinates (Altitude-Azimuth)
class HorizontalCoordinates {
  final double azimuth;    // 0-360° (0=N, 90=E, 180=S, 270=W)
  final double altitude;   // -90 to 90° (0=horizon, 90=zenith)
  
  const HorizontalCoordinates({
    required this.azimuth,
    required this.altitude,
  });
  
  /// Is object above horizon
  bool get isVisible => altitude > 0;
  
  /// Distance from zenith
  double get zenithAngle => 90 - altitude;
  
  /// Cardinal direction
  String get cardinalDirection {
    if (azimuth >= 337.5 || azimuth < 22.5) return 'N';
    if (azimuth >= 22.5 && azimuth < 67.5) return 'NE';
    if (azimuth >= 67.5 && azimuth < 112.5) return 'E';
    if (azimuth >= 112.5 && azimuth < 157.5) return 'SE';
    if (azimuth >= 157.5 && azimuth < 202.5) return 'S';
    if (azimuth >= 202.5 && azimuth < 247.5) return 'SW';
    if (azimuth >= 247.5 && azimuth < 292.5) return 'W';
    return 'NW';
  }
}

/// Equatorial coordinates (Right Ascension - Declination)
class EquatorialCoordinates {
  final double rightAscension; // 0-360° or 0-24h
  final double declination;    // -90 to 90°
  
  const EquatorialCoordinates({
    required this.rightAscension,
    required this.declination,
  });
  
  /// RA in hours (0-24)
  double get raHours => rightAscension / 15.0;
  
  /// RA in HMS format
  String get raHMS {
    final hours = raHours.floor();
    final minutes = ((raHours - hours) * 60).floor();
    final seconds = ((raHours - hours - minutes / 60) * 3600).floor();
    return '${hours}h ${minutes}m ${seconds}s';
  }
  
  /// Dec in DMS format
  String get decDMS {
    final isNegative = declination < 0;
    final absDec = declination.abs();
    final degrees = absDec.floor();
    final minutes = ((absDec - degrees) * 60).floor();
    final seconds = ((absDec - degrees - minutes / 60) * 3600).round();
    return '${isNegative ? '-' : '+'}${degrees}° ${minutes}\' ${seconds}"';
  }
}

/// Geographic coordinates
class GeographicCoordinates {
  final double latitude;   // -90 to 90° (N positive)
  final double longitude;  // -180 to 180° (E positive)
  final double elevation;  // meters above sea level
  
  const GeographicCoordinates({
    required this.latitude,
    required this.longitude,
    this.elevation = 0,
  });
  
  /// Latitude in radians
  double get latRad => latitude * math.pi / 180;
  
  /// Longitude in radians
  double get lonRad => longitude * math.pi / 180;
}

/// Device orientation from sensors
class DeviceOrientation {
  final double azimuth;   // Compass direction (0-360°)
  final double pitch;     // Up/down tilt (-90 to 90°)
  final double roll;      // Left/right tilt (-180 to 180°)
  
  const DeviceOrientation({
    required this.azimuth,
    required this.pitch,
    required this.roll,
  });
  
  /// Convert to horizontal coordinates (center of screen)
  HorizontalCoordinates toHorizontalCoordinates() {
    // Altitude is affected by pitch
    // When phone is upright (pitch=0), altitude = 0 (horizon)
    // When phone points up (pitch=90), altitude = 90 (zenith)
    
    final altitude = pitch;
    final azimuth = this.azimuth;
    
    return HorizontalCoordinates(
      azimuth: azimuth,
      altitude: altitude,
    );
  }
}

/// Field of View
class FieldOfView {
  final double horizontal; // degrees
  final double vertical;   // degrees
  
  const FieldOfView({
    required this.horizontal,
    required this.vertical,
  });
  
  /// Default FOV for mobile device
  factory FieldOfView.standard() {
    return const FieldOfView(
      horizontal: 60,
      vertical: 45,
    );
  }
  
  /// Diagonal FOV
  double get diagonal {
    return math.sqrt(
      horizontal * horizontal + vertical * vertical
    );
  }
}

/// Sky region (visible portion)
class SkyRegion {
  final HorizontalCoordinates center;
  final FieldOfView fov;
  
  const SkyRegion({
    required this.center,
    required this.fov,
  });
  
  /// Check if object is in FOV
  bool contains(HorizontalCoordinates coords) {
    final azDiff = _angleDifference(center.azimuth, coords.azimuth);
    final altDiff = (center.altitude - coords.altitude).abs();
    
    return azDiff <= fov.horizontal / 2 && 
           altDiff <= fov.vertical / 2;
  }
  
  double _angleDifference(double a, double b) {
    var diff = (a - b).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
  
  /// Bounds
  double get minAzimuth => (center.azimuth - fov.horizontal / 2) % 360;
  double get maxAzimuth => (center.azimuth + fov.horizontal / 2) % 360;
  double get minAltitude => (center.altitude - fov.vertical / 2).clamp(-90, 90);
  double get maxAltitude => (center.altitude + fov.vertical / 2).clamp(-90, 90);
}