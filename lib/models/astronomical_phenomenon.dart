/// Astronomical phenomenon model
class AstronomicalPhenomenon {
  final String id;
  final String name;
  final String type; // meteor_shower, comet, planet, eclipse
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final String icon;
  final bool isVisible;
  
  AstronomicalPhenomenon({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.description,
    required this.icon,
    this.isVisible = true,
  });
  
  /// Days until event
  int get daysUntil {
    final now = DateTime.now();
    final diff = startDate.difference(now);
    return diff.inDays;
  }
  
  /// Is happening now
  bool get isActive {
    final now = DateTime.now();
    if (endDate != null) {
      return now.isAfter(startDate) && now.isBefore(endDate!);
    }
    return now.day == startDate.day && 
           now.month == startDate.month && 
           now.year == startDate.year;
  }
  
  /// Is upcoming (within 30 days)
  bool get isUpcoming {
    return daysUntil >= 0 && daysUntil <= 30;
  }
  
  /// Get type emoji
  String get typeEmoji {
    switch (type) {
      case 'meteor_shower':
        return '☄️';
      case 'comet':
        return '☄️';
      case 'planet':
        return '🪐';
      case 'eclipse':
        return '🌑';
      case 'conjunction':
        return '✨';
      default:
        return '⭐';
    }
  }
  
  /// From JSON (for API response)
  factory AstronomicalPhenomenon.fromJson(Map<String, dynamic> json) {
    return AstronomicalPhenomenon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      description: json['description'] ?? '',
      icon: json['icon'] ?? '⭐',
      isVisible: json['is_visible'] ?? true,
    );
  }
}

/// Night sky object (constellation, planet, etc)
class NightSkyObject {
  final String id;
  final String name;
  final String type; // constellation, planet, star, nebula, galaxy
  final double rightAscension; // RA in degrees
  final double declination; // Dec in degrees
  final double magnitude; // Brightness
  
  NightSkyObject({
    required this.id,
    required this.name,
    required this.type,
    required this.rightAscension,
    required this.declination,
    required this.magnitude,
  });
  
  /// Get type emoji
  String get typeEmoji {
    switch (type) {
      case 'constellation':
        return '✨';
      case 'planet':
        return '🪐';
      case 'star':
        return '⭐';
      case 'nebula':
        return '🌌';
      case 'galaxy':
        return '🌀';
      default:
        return '✨';
    }
  }
  
  /// From JSON
  factory NightSkyObject.fromJson(Map<String, dynamic> json) {
    return NightSkyObject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'star',
      rightAscension: (json['ra'] ?? 0).toDouble(),
      declination: (json['dec'] ?? 0).toDouble(),
      magnitude: (json['magnitude'] ?? 0).toDouble(),
    );
  }
}

/// Object visibility status
enum VisibilityStatus {
  visible,    // 🟢 Terlihat jelas (≥70)
  partial,    // 🟠 Terlihat sebagian (40-69)
  notVisible, // 🔴 Tidak terlihat (<40)
}

/// Object visibility data
class ObjectVisibility {
  final NightSkyObject object;
  final int score; // 0-100
  final VisibilityStatus status;
  final double altitude; // degrees above horizon
  final String reason;
  
  ObjectVisibility({
    required this.object,
    required this.score,
    required this.status,
    required this.altitude,
    required this.reason,
  });
  
  /// Get color for status
  String get colorHex {
    switch (status) {
      case VisibilityStatus.visible:
        return '#4CAF50'; // Green
      case VisibilityStatus.partial:
        return '#FF9800'; // Orange
      case VisibilityStatus.notVisible:
        return '#F44336'; // Red
    }
  }
  
  /// Get status text
  String get statusText {
    switch (status) {
      case VisibilityStatus.visible:
        return 'Terlihat Jelas';
      case VisibilityStatus.partial:
        return 'Terlihat Sebagian';
      case VisibilityStatus.notVisible:
        return 'Tidak Terlihat';
    }
  }
  
  /// Get emoji indicator
  String get emoji {
    switch (status) {
      case VisibilityStatus.visible:
        return '🟢';
      case VisibilityStatus.partial:
        return '🟠';
      case VisibilityStatus.notVisible:
        return '🔴';
    }
  }
}