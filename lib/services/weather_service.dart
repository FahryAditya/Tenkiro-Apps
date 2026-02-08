import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/location_model.dart';

class WeatherService {
  static const _weatherUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _airUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  Future<WeatherModel> getWeather(LocationModel location) async {
    try {
      final uri = Uri.parse(_weatherUrl).replace(
        queryParameters: {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
          'timezone': 'auto',

          // CURRENT (valid fields only)
          'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
              'weather_code,wind_speed_10m,cloud_cover,uv_index',

          // HOURLY
          'hourly': 'temperature_2m,apparent_temperature,relative_humidity_2m,'
              'weather_code,wind_speed_10m,uv_index,'
              'precipitation_probability,visibility,is_day',

          // DAILY
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
              'precipitation_probability_max,sunrise,sunset,uv_index_max',

          'forecast_days': '14',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<AirQualityModel> getAirQuality(LocationModel location) async {
    try {
      final uri = Uri.parse(_airUrl).replace(
        queryParameters: {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
          'timezone': 'auto',
          'current': 'pm10,pm2_5,carbon_monoxide,'
              'nitrogen_dioxide,sulphur_dioxide,ozone',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return AirQualityModel.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching air quality: $e');
    }
  }
}
