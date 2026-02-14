import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/solar_calculator.dart';
import '../services/astronomy_engine.dart';
import '../models/sky_coordinates.dart';
import '../widgets/solar_tracker_widget.dart';

class SunTrackerPage extends StatefulWidget {
  const SunTrackerPage({super.key});

  @override
  State<SunTrackerPage> createState() => _SunTrackerPageState();
}

class _SunTrackerPageState extends State<SunTrackerPage> {
  GeographicCoordinates _location = const GeographicCoordinates(
    latitude: -6.2088, // Jakarta default
    longitude: 106.8456,
  );

  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _sunData;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _calculateSunData();
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _location = GeographicCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          elevation: position.altitude,
        );
      });
      _calculateSunData();
    } catch (e) {
      print('Location error: $e');
      // Use default Jakarta location
      _calculateSunData();
    }
  }

  void _calculateSunData() {
    final lst =
        AstronomyEngine.calculateLST(_selectedDate, _location.longitude);
    final sun = SolarCalculator.calculateSun(_selectedDate);
    final horizontal = AstronomyEngine.equatorialToHorizontal(
      rightAscension: sun.equatorial.rightAscension,
      declination: sun.equatorial.declination,
      latitude: _location.latitude,
      localSiderealTime: lst,
    );

    // Calculate sunrise/sunset times
    final sunrise = _calculateSunriseTime();
    final sunset = _calculateSunsetTime();

    setState(() {
      _sunData = {
        'altitude': horizontal.altitude,
        'azimuth': horizontal.azimuth,
        'sunrise': sunrise,
        'sunset': sunset,
        'dayLength': sunset != null && sunrise != null
            ? sunset.difference(sunrise).inMinutes
            : null,
      };
    });
  }

  DateTime? _calculateSunriseTime() {
    // Simplified sunrise calculation
    for (int hour = 5; hour < 12; hour++) {
      final testTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
      );
      final lst = AstronomyEngine.calculateLST(testTime, _location.longitude);
      final sun = SolarCalculator.calculateSun(testTime);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: sun.equatorial.rightAscension,
        declination: sun.equatorial.declination,
        latitude: _location.latitude,
        localSiderealTime: lst,
      );

      if (horizontal.altitude > -0.5) {
        // Sun is above horizon
        return testTime;
      }
    }
    return null;
  }

  DateTime? _calculateSunsetTime() {
    // Simplified sunset calculation
    for (int hour = 18; hour > 12; hour--) {
      final testTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
      );
      final lst = AstronomyEngine.calculateLST(testTime, _location.longitude);
      final sun = SolarCalculator.calculateSun(testTime);
      final horizontal = AstronomyEngine.equatorialToHorizontal(
        rightAscension: sun.equatorial.rightAscension,
        declination: sun.equatorial.declination,
        latitude: _location.latitude,
        localSiderealTime: lst,
      );

      if (horizontal.altitude > -0.5) {
        // Sun is above horizon
        return testTime;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sun Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _calculateSunData();
                      }
                    },
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_sunData != null) ...[
              // Current Position
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Sun Position',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Altitude',
                        '${_sunData!['altitude'].toStringAsFixed(1)}°'),
                    _buildInfoRow('Azimuth',
                        '${_sunData!['azimuth'].toStringAsFixed(1)}°'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sun Times
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sun Times',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_sunData!['sunrise'] != null)
                      _buildInfoRow(
                          'Sunrise', _formatTime(_sunData!['sunrise'])),
                    if (_sunData!['sunset'] != null)
                      _buildInfoRow('Sunset', _formatTime(_sunData!['sunset'])),
                    if (_sunData!['dayLength'] != null)
                      _buildInfoRow(
                          'Day Length', '${_sunData!['dayLength']} minutes'),
                  ],
                ),
              ),
            ] else ...[
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
