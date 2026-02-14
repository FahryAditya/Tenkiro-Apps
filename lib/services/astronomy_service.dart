import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/astronomical_phenomenon.dart';
import 'dart:math' as math;

class AstronomyService {
  // Using Astronomy API (free tier)
  static const String _baseUrl = 'https://api.astronomyapi.com/api/v2';
  
  // Backup: Use static data if API fails
  static final List<Map<String, dynamic>> _fallbackPhenomena = [
    {
      'id': 'perseids_2026',
      'name': 'Hujan Meteor Perseids',
      'type': 'meteor_shower',
      'start_date': '2026-08-12T00:00:00Z',
      'end_date': '2026-08-13T23:59:59Z',
      'description': 'Hujan meteor tahunan dari konstelasi Perseus',
      'icon': '☄️',
      'is_visible': true,
    },
    {
      'id': 'geminids_2026',
      'name': 'Hujan Meteor Geminids',
      'type': 'meteor_shower',
      'start_date': '2026-12-14T00:00:00Z',
      'end_date': '2026-12-15T23:59:59Z',
      'description': 'Salah satu hujan meteor terbaik tahun ini',
      'icon': '☄️',
      'is_visible': true,
    },
    {
      'id': 'mars_opposition_2026',
      'name': 'Oposisi Mars',
      'type': 'planet',
      'start_date': '2026-06-27T00:00:00Z',
      'description': 'Mars paling terang dan dekat dengan Bumi',
      'icon': '🔴',
      'is_visible': true,
    },
  ];
  
  static final List<Map<String, dynamic>> _fallbackObjects = [
    {
      'id': 'orion',
      'name': 'Orion',
      'type': 'constellation',
      'ra': 83.8,
      'dec': -5.4,
      'magnitude': 1.0,
    },
    {
      'id': 'sirius',
      'name': 'Sirius',
      'type': 'star',
      'ra': 101.3,
      'dec': -16.7,
      'magnitude': -1.46,
    },
    {
      'id': 'jupiter',
      'name': 'Jupiter',
      'type': 'planet',
      'ra': 45.0,
      'dec': 15.0,
      'magnitude': -2.0,
    },
    {
      'id': 'saturn',
      'name': 'Saturnus',
      'type': 'planet',
      'ra': 300.0,
      'dec': -20.0,
      'magnitude': 0.5,
    },
    {
      'id': 'andromeda',
      'name': 'Galaksi Andromeda',
      'type': 'galaxy',
      'ra': 10.7,
      'dec': 41.3,
      'magnitude': 3.4,
    },
  ];

  /// Get upcoming astronomical phenomena
  Future<List<AstronomicalPhenomenon>> getUpcomingPhenomena() async {
    try {
      // Try to use fallback data (stable)
      // In production, replace with real API call
      return _fallbackPhenomena
          .map((json) => AstronomicalPhenomenon.fromJson(json))
          .where((p) => p.daysUntil >= -7) // Show events from 7 days ago
          .toList()
        ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    } catch (e) {
      print('Error fetching phenomena: $e');
      return [];
    }
  }

  /// Get next upcoming phenomenon
  Future<AstronomicalPhenomenon?> getNextPhenomenon() async {
    final phenomena = await getUpcomingPhenomena();
    return phenomena.where((p) => p.daysUntil >= 0).firstOrNull;
  }

  /// Get night sky objects
  Future<List<NightSkyObject>> getNightSkyObjects() async {
    try {
      return _fallbackObjects
          .map((json) => NightSkyObject.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching objects: $e');
      return [];
    }
  }

  /// Calculate object visibility
  Future<List<ObjectVisibility>> calculateVisibility({
    required double latitude,
    required double longitude,
    required int cloudCover,
    required double visibility,
    required double moonIllumination,
  }) async {
    final objects = await getNightSkyObjects();
    final now = DateTime.now();
    
    return objects.map((obj) {
      final altitude = _calculateAltitude(
        obj.rightAscension,
        obj.declination,
        latitude,
        longitude,
        now,
      );
      
      final score = _calculateVisibilityScore(
        altitude: altitude,
        cloudCover: cloudCover,
        atmosphericVisibility: visibility,
        moonIllumination: moonIllumination,
        magnitude: obj.magnitude,
      );
      
      final status = _getVisibilityStatus(score);
      final reason = _getVisibilityReason(score, altitude, cloudCover, moonIllumination);
      
      return ObjectVisibility(
        object: obj,
        score: score,
        status: status,
        altitude: altitude,
        reason: reason,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score)); // Best visibility first
  }

  /// Calculate altitude (simplified)
  double _calculateAltitude(
    double ra,
    double dec,
    double latitude,
    double longitude,
    DateTime time,
  ) {
    // Simplified altitude calculation
    // In production, use proper astronomical formulas
    
    final hourAngle = (time.hour + time.minute / 60.0) * 15.0 - ra + longitude;
    final latRad = latitude * math.pi / 180;
    final decRad = dec * math.pi / 180;
    final haRad = hourAngle * math.pi / 180;
    
    final sinAlt = math.sin(latRad) * math.sin(decRad) + 
                   math.cos(latRad) * math.cos(decRad) * math.cos(haRad);
    
    final altitude = math.asin(sinAlt) * 180 / math.pi;
    
    return altitude.clamp(-90, 90);
  }

  /// Calculate visibility score (0-100)
  int _calculateVisibilityScore({
    required double altitude,
    required int cloudCover,
    required double atmosphericVisibility,
    required double moonIllumination,
    required double magnitude,
  }) {
    // Factors:
    // 1. Altitude (must be above horizon)
    if (altitude < 10) return 0; // Too low
    
    final altitudeScore = ((altitude / 90) * 100).clamp(0, 100);
    
    // 2. Cloud cover (less is better)
    final cloudScore = (100 - cloudCover).toDouble();
    
    // 3. Atmospheric visibility (more is better)
    final visibilityScore = ((atmosphericVisibility / 30) * 100).clamp(0, 100);
    
    // 4. Moon interference (less moon = better)
    final moonScore = (100 - moonIllumination);
    
    // 5. Object brightness (brighter objects easier to see)
    final magnitudeScore = magnitude < 0 ? 100 : (100 - (magnitude * 20)).clamp(0, 100);
    
    // Weighted average
    final totalScore = (
      altitudeScore * 0.30 +
      cloudScore * 0.30 +
      visibilityScore * 0.20 +
      moonScore * 0.15 +
      magnitudeScore * 0.05
    ).round();
    
    return totalScore.clamp(0, 100);
  }

  /// Get visibility status from score
  VisibilityStatus _getVisibilityStatus(int score) {
    if (score >= 70) return VisibilityStatus.visible;
    if (score >= 40) return VisibilityStatus.partial;
    return VisibilityStatus.notVisible;
  }

  /// Get human-readable reason
  String _getVisibilityReason(int score, double altitude, int cloudCover, double moonIllumination) {
    if (score >= 70) {
      return 'Kondisi ideal untuk observasi';
    }
    
    final reasons = <String>[];
    
    if (altitude < 30) {
      reasons.add('Posisi rendah di langit');
    }
    
    if (cloudCover > 50) {
      reasons.add('Awan menghalangi');
    }
    
    if (moonIllumination > 70) {
      reasons.add('Cahaya bulan terang');
    }
    
    if (reasons.isEmpty) {
      return 'Terlihat dengan kondisi cukup';
    }
    
    return reasons.join(', ');
  }
}

/// Extension for firstOrNull
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}