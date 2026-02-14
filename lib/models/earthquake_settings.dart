class EarthquakeSettings {
  final bool notificationsEnabled;
  final double minimumMagnitude;
  final bool tsunamiAlertsOnly;
  final int maxDistanceKm;
  final bool vibrate;
  final bool sound;

  const EarthquakeSettings({
    this.notificationsEnabled = true,
    this.minimumMagnitude = 5.0,
    this.tsunamiAlertsOnly = false,
    this.maxDistanceKm = 1000,
    this.vibrate = true,
    this.sound = true,
  });

  EarthquakeSettings copyWith({
    bool? notificationsEnabled,
    double? minimumMagnitude,
    bool? tsunamiAlertsOnly,
    int? maxDistanceKm,
    bool? vibrate,
    bool? sound,
  }) {
    return EarthquakeSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      minimumMagnitude: minimumMagnitude ?? this.minimumMagnitude,
      tsunamiAlertsOnly: tsunamiAlertsOnly ?? this.tsunamiAlertsOnly,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      vibrate: vibrate ?? this.vibrate,
      sound: sound ?? this.sound,
    );
  }

  Map<String, dynamic> toJson() => {
        'notifications_enabled': notificationsEnabled,
        'minimum_magnitude': minimumMagnitude,
        'tsunami_alerts_only': tsunamiAlertsOnly,
        'max_distance_km': maxDistanceKm,
        'vibrate': vibrate,
        'sound': sound,
      };

  factory EarthquakeSettings.fromJson(Map<String, dynamic> json) {
    return EarthquakeSettings(
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      minimumMagnitude: (json['minimum_magnitude'] as num?)?.toDouble() ?? 5.0,
      tsunamiAlertsOnly: json['tsunami_alerts_only'] as bool? ?? false,
      maxDistanceKm: json['max_distance_km'] as int? ?? 1000,
      vibrate: json['vibrate'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
    );
  }
}