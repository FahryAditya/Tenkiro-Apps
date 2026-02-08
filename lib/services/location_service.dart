import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class LocationService {
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(_geocodingUrl).replace(
        queryParameters: {
          'name': query,
          'count': '10',
          'language': 'id',
          'format': 'json',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic>? results = data['results'];

      if (results == null) return [];

      return results.map((e) {
        return LocationModel(
          city: e['name'] ?? '',
          latitude: (e['latitude'] as num).toDouble(),
          longitude: (e['longitude'] as num).toDouble(),
          timezone: e['timezone'] ?? 'UTC',
        );
      }).toList();
    } catch (e) {
      print('LocationService error: $e');
      return [];
    }
  }

  Future<LocationModel?> getLocationByName(String cityName) async {
    final locations = await searchLocations(cityName);
    return locations.isNotEmpty ? locations.first : null;
  }
}