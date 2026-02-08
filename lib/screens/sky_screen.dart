import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/astronomy_utils.dart';
import '../utils/color_utils.dart';
import '../widgets/solar_tracker_widget.dart';
import '../widgets/moon_phase_widget.dart';
import '../widgets/sky_visibility_widget.dart';

class SkyScreen extends StatelessWidget {
  const SkyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2332),
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              // Handle loading state
              if (provider.isLoading && provider.weather == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Loading sky data...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              // Handle error state
              if (provider.error != null && provider.weather == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error ?? 'Unknown error',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadWeatherData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1A2332),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Handle no data state
              if (provider.weather == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.nights_stay,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final weather = provider.weather!;
              final location = provider.currentLocation;
              final currentTime = DateTime.parse(weather.current.time);

              return RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                backgroundColor: Colors.white,
                color: const Color(0xFF395886),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    _buildHeader(context, location.city, currentTime),

                    const SizedBox(height: 24),

                    // Solar Tracker
                    SolarTrackerWidget(
                      latitude: location.latitude,
                      longitude: location.longitude,
                      sunrise: DateTime.parse(weather.daily.sunrise[0]),
                      sunset: DateTime.parse(weather.daily.sunset[0]),
                      currentTime: currentTime,
                    ),

                    const SizedBox(height: 24),

                    // Moon Phase
                    MoonPhaseWidget(
                      currentTime: currentTime,
                    ),

                    const SizedBox(height: 24),

                    // Sky Visibility Index
                    SkyVisibilityWidget(
                      cloudCover: weather.current.cloudCover,
                      visibility: weather.current.visibility,
                      humidity: weather.current.humidity,
                      currentTime: currentTime,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String city, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.nights_stay, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Sky Watch',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              city,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMM yyyy', 'id_ID').format(time),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
