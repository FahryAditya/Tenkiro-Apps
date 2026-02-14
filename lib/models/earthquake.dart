import 'package:flutter/material.dart';

enum MagnitudeCategory {
  minor,
  light,
  moderate,
  strong,
  major,
  great;

  static MagnitudeCategory fromMagnitude(double magnitude) {
    if (magnitude < 4.0) return MagnitudeCategory.minor;
    if (magnitude < 5.0) return MagnitudeCategory.light;
    if (magnitude < 6.0) return MagnitudeCategory.moderate;
    if (magnitude < 7.0) return MagnitudeCategory.strong;
    if (magnitude < 8.0) return MagnitudeCategory.major;
    return MagnitudeCategory.great;
  }

  Color get color {
    switch (this) {
      case MagnitudeCategory.minor:
        return const Color(0xFF4CAF50);
      case MagnitudeCategory.light:
        return const Color(0xFF8BC34A);
      case MagnitudeCategory.moderate:
        return const Color(0xFFFFC107);
      case MagnitudeCategory.strong:
        return const Color(0xFFFF9800);
      case MagnitudeCategory.major:
        return const Color(0xFFFF5722);
      case MagnitudeCategory.great:
        return const Color(0xFFF44336);
    }
  }

  String get label {
    switch (this) {
      case MagnitudeCategory.minor:
        return 'Ringan';
      case MagnitudeCategory.light:
        return 'Sedang';
      case MagnitudeCategory.moderate:
        return 'Kuat';
      case MagnitudeCategory.strong:
        return 'Sangat Kuat';
      case MagnitudeCategory.major:
        return 'Dahsyat';
      case MagnitudeCategory.great:
        return 'Mega';
    }
  }
}

enum TsunamiStatus {
  none,
  warning,
  alert;

  static TsunamiStatus fromString(String? value) {
    if (value == null) return TsunamiStatus.none;
    switch (value.toLowerCase()) {
      case 'ya':
      case 'alert':
        return TsunamiStatus.alert;
      case 'waspada':
      case 'warning':
        return TsunamiStatus.warning;
      default:
        return TsunamiStatus.none;
    }
  }

  String get label {
    switch (this) {
      case TsunamiStatus.none:
        return 'Tidak Berpotensi';
      case TsunamiStatus.warning:
        return 'Waspada Tsunami';
      case TsunamiStatus.alert:
        return 'Peringatan Tsunami';
    }
  }

  Color get color {
    switch (this) {
      case TsunamiStatus.none:
        return Colors.grey;
      case TsunamiStatus.warning:
        return const Color(0xFF2196F3);
      case TsunamiStatus.alert:
        return const Color(0xFFE91E63);
    }
  }

  IconData get icon {
    switch (this) {
      case TsunamiStatus.none:
        return Icons.check_circle_outline;
      case TsunamiStatus.warning:
        return Icons.warning_amber;
      case TsunamiStatus.alert:
        return Icons.warning;
    }
  }
}

class Epicenter {
  final double latitude;
  final double longitude;
  final String description;

  const Epicenter({
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory Epicenter.fromJson(Map<String, dynamic> json) {
    return Epicenter(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
      };
}

class Earthquake {
  final String id;
  final DateTime timestamp;
  final DateTime localTime;
  final double magnitude;
  final double depth;
  final Epicenter epicenter;
  final String region;
  final int? mmi;
  final TsunamiStatus tsunami;
  final String source;
  final List<String>? affectedAreas;
  final double? distanceFromUser;
  final String? shakemapUrl;

  const Earthquake({
    required this.id,
    required this.timestamp,
    required this.localTime,
    required this.magnitude,
    required this.depth,
    required this.epicenter,
    required this.region,
    this.mmi,
    required this.tsunami,
    required this.source,
    this.affectedAreas,
    this.distanceFromUser,
    this.shakemapUrl,
  });

  MagnitudeCategory get category => MagnitudeCategory.fromMagnitude(magnitude);
  Color get alertColor => category.color;
  String get alertLevel => category.label;
  bool get isSignificant => magnitude >= 5.0 || tsunami != TsunamiStatus.none;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  String get depthCategory {
    if (depth < 60) return 'Dangkal';
    if (depth < 300) return 'Menengah';
    return 'Dalam';
  }

  double get impactRadius {
    return magnitude * 50;
  }

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      localTime: DateTime.parse(json['local_time'] as String),
      magnitude: (json['magnitude'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
      epicenter: Epicenter.fromJson(json['epicenter'] as Map<String, dynamic>),
      region: json['region'] as String,
      mmi: json['mmi'] as int?,
      tsunami: TsunamiStatus.fromString(json['tsunami'] as String?),
      source: json['source'] as String? ?? 'BMKG',
      affectedAreas: (json['affected_areas'] as List<dynamic>?)?.cast<String>(),
      distanceFromUser: (json['distance_from_user'] as num?)?.toDouble(),
      shakemapUrl: json['shakemap_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'local_time': localTime.toIso8601String(),
        'magnitude': magnitude,
        'depth': depth,
        'epicenter': epicenter.toJson(),
        'region': region,
        'mmi': mmi,
        'tsunami': tsunami.name,
        'source': source,
        'affected_areas': affectedAreas,
        'distance_from_user': distanceFromUser,
        'shakemap_url': shakemapUrl,
      };

  Earthquake copyWith({
    String? id,
    DateTime? timestamp,
    DateTime? localTime,
    double? magnitude,
    double? depth,
    Epicenter? epicenter,
    String? region,
    int? mmi,
    TsunamiStatus? tsunami,
    String? source,
    List<String>? affectedAreas,
    double? distanceFromUser,
    String? shakemapUrl,
  }) {
    return Earthquake(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      localTime: localTime ?? this.localTime,
      magnitude: magnitude ?? this.magnitude,
      depth: depth ?? this.depth,
      epicenter: epicenter ?? this.epicenter,
      region: region ?? this.region,
      mmi: mmi ?? this.mmi,
      tsunami: tsunami ?? this.tsunami,
      source: source ?? this.source,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
      shakemapUrl: shakemapUrl ?? this.shakemapUrl,
    );
  }
}