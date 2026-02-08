class LocationModel {
  final String city;
  final double latitude;
  final double longitude;
  final String timezone;

  LocationModel({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory LocationModel.defaultLocation() {
    return LocationModel(
      city: 'Balikpapan',
      latitude: -1.2379,
      longitude: 116.8529,
      timezone: 'Asia/Makassar',
    );
  }

  LocationModel copyWith({
    String? city,
    double? latitude,
    double? longitude,
    String? timezone,
  }) {
    return LocationModel(
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }
}