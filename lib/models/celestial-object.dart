import 'dart:math' as Math;

import 'sky_coordinates.dart';
import 'dart:ui';

/// Base class for all celestial objects
abstract class CelestialObject {
  final String id;
  final String name;
  final EquatorialCoordinates equatorial;
  final double magnitude; // Visual magnitude (brightness)
  
  const CelestialObject({
    required this.id,
    required this.name,
    required this.equatorial,
    required this.magnitude,
  });
  
  /// Object type for rendering
  CelestialObjectType get type;
  
  /// Color for rendering
  Color get color;
  
  /// Size on screen (pixels) based on magnitude
  double get renderSize {
    // Brighter objects (lower magnitude) are larger
    if (magnitude < 0) return 12;
    if (magnitude < 1) return 10;
    if (magnitude < 2) return 8;
    if (magnitude < 3) return 6;
    if (magnitude < 4) return 5;
    return 3;
  }
  
  /// Is visible to naked eye (mag < 6)
  bool get isVisibleToNakedEye => magnitude < 6.0;
}

enum CelestialObjectType {
  star,
  planet,
  sun,
  moon,
  deepSky,
}

/// Star object
class Star extends CelestialObject {
  final String spectralType; // O, B, A, F, G, K, M
  final String? constellation;
  
  const Star({
    required super.id,
    required super.name,
    required super.equatorial,
    required super.magnitude,
    required this.spectralType,
    this.constellation,
  });
  
  @override
  CelestialObjectType get type => CelestialObjectType.star;
  
  @override
  Color get color {
    // Color by spectral type (approximate)
    final type = spectralType.toUpperCase();
    if (type.startsWith('O') || type.startsWith('B')) {
      return const Color(0xFFADD8E6); // Light blue
    }
    if (type.startsWith('A')) {
      return const Color(0xFFFFFFFF); // White
    }
    if (type.startsWith('F') || type.startsWith('G')) {
      return const Color(0xFFFFFFE0); // Light yellow
    }
    if (type.startsWith('K')) {
      return const Color(0xFFFFA500); // Orange
    }
    if (type.startsWith('M')) {
      return const Color(0xFFFF6347); // Red
    }
    return const Color(0xFFFFFFFF); // Default white
  }
  
  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'] as String,
      name: json['name'] as String,
      equatorial: EquatorialCoordinates(
        rightAscension: (json['ra'] as num).toDouble(),
        declination: (json['dec'] as num).toDouble(),
      ),
      magnitude: (json['mag'] as num).toDouble(),
      spectralType: json['spectral_type'] as String? ?? 'G',
      constellation: json['constellation'] as String?,
    );
  }
}

/// Planet object
class Planet extends CelestialObject {
  final PlanetType planetType;
  
  const Planet({
    required super.id,
    required super.name,
    required super.equatorial,
    required super.magnitude,
    required this.planetType,
  });
  
  @override
  CelestialObjectType get type => CelestialObjectType.planet;
  
  @override
  Color get color {
    switch (planetType) {
      case PlanetType.mercury:
        return const Color(0xFFA0522D); // Brown
      case PlanetType.venus:
        return const Color(0xFFFFF8DC); // Cream
      case PlanetType.mars:
        return const Color(0xFFCD5C5C); // Red
      case PlanetType.jupiter:
        return const Color(0xFFDAA520); // Gold
      case PlanetType.saturn:
        return const Color(0xFFF0E68C); // Khaki
      case PlanetType.uranus:
        return const Color(0xFF00CED1); // Cyan
      case PlanetType.neptune:
        return const Color(0xFF4169E1); // Royal blue
    }
  }
  
  @override
  double get renderSize {
    // Planets are larger than stars
    return super.renderSize + 4;
  }
}

enum PlanetType {
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
}

/// Sun object
class Sun extends CelestialObject {
  const Sun({
    required super.equatorial,
    required super.magnitude,
  }) : super(
    id: 'sun',
    name: 'Matahari',
  );
  
  @override
  CelestialObjectType get type => CelestialObjectType.sun;
  
  @override
  Color get color => const Color(0xFFFFD700); // Gold
  
  @override
  double get renderSize => 24; // Large
}

/// Moon object
class Moon extends CelestialObject {
  final double phase; // 0-1 (0=new, 0.5=full)
  final double illumination; // 0-100%
  
  const Moon({
    required super.equatorial,
    required super.magnitude,
    required this.phase,
    required this.illumination,
  }) : super(
    id: 'moon',
    name: 'Bulan',
  );
  
  @override
  CelestialObjectType get type => CelestialObjectType.moon;
  
  @override
  Color get color => const Color(0xFFF0F0F0); // Light gray
  
  @override
  double get renderSize => 20; // Large
  
  /// Moon phase name
  String get phaseName {
    if (phase < 0.0625) return 'Bulan Baru';
    if (phase < 0.1875) return 'Sabit Awal';
    if (phase < 0.3125) return 'Kuarter Awal';
    if (phase < 0.4375) return 'Cembung Awal';
    if (phase < 0.5625) return 'Purnama';
    if (phase < 0.6875) return 'Cembung Akhir';
    if (phase < 0.8125) return 'Kuarter Akhir';
    return 'Sabit Akhir';
  }
  
  /// Moon emoji
  String get emoji {
    if (phase < 0.0625) return '🌑';
    if (phase < 0.1875) return '🌒';
    if (phase < 0.3125) return '🌓';
    if (phase < 0.4375) return '🌔';
    if (phase < 0.5625) return '🌕';
    if (phase < 0.6875) return '🌖';
    if (phase < 0.8125) return '🌗';
    return '🌘';
  }
}

/// Positioned celestial object (with horizontal coordinates)
class PositionedCelestialObject {
  final CelestialObject object;
  final HorizontalCoordinates horizontal;
  final DateTime calculatedAt;
  
  const PositionedCelestialObject({
    required this.object,
    required this.horizontal,
    required this.calculatedAt,
  });
  
  /// Is visible above horizon
  bool get isVisible => horizontal.isVisible;
  
  /// Angular distance from another object (degrees)
  double angularDistance(PositionedCelestialObject other) {
    final az1 = horizontal.azimuth * 3.14159 / 180;
    final alt1 = horizontal.altitude * 3.14159 / 180;
    final az2 = other.horizontal.azimuth * 3.14159 / 180;
    final alt2 = other.horizontal.altitude * 3.14159 / 180;
    
    final cosDistance = 
        Math.sin(alt1) * Math.sin(alt2) +
        Math.cos(alt1) * Math.cos(alt2) * Math.cos(az1 - az2);
    
    return Math.acos(cosDistance.clamp(-1, 1)) * 180 / 3.14159;
  }
}