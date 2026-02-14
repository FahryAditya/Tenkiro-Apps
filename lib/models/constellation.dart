import 'package:flutter/widgets.dart';

/// Constellation model
/// Represents a constellation with its stars and connecting lines
class Constellation {
  final String id;
  final String name;
  final String abbreviation;
  final String nameIndonesia;
  final List<ConstellationLine> lines;
  final List<String> starIds; // HIP IDs of stars in this constellation
  final String? mythology; // Optional mythology description
  final double? declination; // Average declination for visibility
  
  const Constellation({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.nameIndonesia,
    required this.lines,
    required this.starIds,
    this.mythology,
    this.declination,
  });
  
  /// Get hemisphere (N/S/Equatorial)
  String get hemisphere {
    if (declination == null) return 'Equatorial';
    if (declination! > 30) return 'Northern';
    if (declination! < -30) return 'Southern';
    return 'Equatorial';
  }
  
  /// Get emoji based on constellation type
  String get emoji {
    if (id.contains('ursa')) return '🐻';
    if (id.contains('canis')) return '🐕';
    if (id.contains('leo')) return '🦁';
    if (id.contains('scorpius')) return '🦂';
    if (id.contains('taurus')) return '🐂';
    if (id.contains('aries')) return '🐏';
    if (id.contains('cancer')) return '🦀';
    if (id.contains('pisces')) return '🐟';
    if (id.contains('aquarius')) return '💧';
    if (id.contains('sagittarius')) return '🏹';
    if (id.contains('gemini')) return '👬';
    if (id.contains('virgo')) return '👧';
    if (id.contains('libra')) return '⚖️';
    if (id.contains('capricornus')) return '🐐';
    if (id.contains('orion')) return '🏹';
    if (id.contains('cygnus')) return '🦢';
    if (id.contains('aquila')) return '🦅';
    if (id.contains('phoenix')) return '🔥';
    if (id.contains('columba')) return '🕊️';
    if (id.contains('draco')) return '🐉';
    if (id.contains('lepus')) return '🐇';
    return '⭐';
  }
  
  factory Constellation.fromJson(Map<String, dynamic> json) {
    return Constellation(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbr'] as String,
      nameIndonesia: json['name_id'] as String,
      lines: (json['lines'] as List)
          .map((line) => ConstellationLine.fromJson(line))
          .toList(),
      starIds: (json['star_ids'] as List).cast<String>(),
      mythology: json['mythology'] as String?,
      declination: json['declination'] as double?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'abbr': abbreviation,
    'name_id': nameIndonesia,
    'lines': lines.map((l) => l.toJson()).toList(),
    'star_ids': starIds,
    'mythology': mythology,
    'declination': declination,
  };
}

/// Constellation line connecting two stars
class ConstellationLine {
  final String star1Id; // HIP ID of first star
  final String star2Id; // HIP ID of second star
  
  const ConstellationLine({
    required this.star1Id,
    required this.star2Id,
  });
  
  factory ConstellationLine.fromJson(Map<String, dynamic> json) {
    return ConstellationLine(
      star1Id: json['star1'] as String,
      star2Id: json['star2'] as String,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'star1': star1Id,
    'star2': star2Id,
  };
}

/// Positioned constellation line (with screen coordinates)
class PositionedConstellationLine {
  final ConstellationLine line;
  final Offset? point1; // Screen position of star1 (null if off-screen)
  final Offset? point2; // Screen position of star2 (null if off-screen)
  final String constellationId;
  
  const PositionedConstellationLine({
    required this.line,
    required this.point1,
    required this.point2,
    required this.constellationId,
  });
  
  /// Check if line is visible (both points on screen)
  bool get isVisible => point1 != null && point2 != null;
  
  /// Check if partially visible (one point on screen)
  bool get isPartiallyVisible => point1 != null || point2 != null;
}