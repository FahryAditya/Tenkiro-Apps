import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  LocationModel _currentLocation = LocationModel.defaultLocation();
  WeatherModel? _weather;
  AirQualityModel? _airQuality;
  bool _isLoading = false;
  String? _error;

  LocationModel get currentLocation => _currentLocation;
  WeatherModel? get weather => _weather;
  AirQualityModel? get airQuality => _airQuality;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    loadWeatherData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationModel(
        city: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: 'auto',
      );
    } catch (e) {
      _error = 'Failed to get location: $e';
    }
  }

  Future<void> loadWeatherData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final weatherData = await _weatherService.getWeather(_currentLocation);
      final airQualityData =
          await _weatherService.getAirQuality(_currentLocation);

      _weather = weatherData;
      _airQuality = airQualityData;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeatherData() async {
    await loadWeatherData();
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    return await _locationService.searchLocations(query);
  }

  Future<void> changeLocation(LocationModel newLocation) async {
    _currentLocation = newLocation;
    await loadWeatherData();
  }

  Future<void> changeLocationByName(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.getLocationByName(cityName);
      if (location != null) {
        _currentLocation = location;
        await loadWeatherData();
      } else {
        _error = 'Lokasi tidak ditemukan';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal mengubah lokasi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
