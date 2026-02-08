import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../widgets/air_quality_card.dart';

class EarthScreen extends StatelessWidget {
  const EarthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              final currentTime = provider.weather != null
                  ? DateTime.parse(provider.weather!.current.time)
                  : DateTime.now();

              return RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                backgroundColor: Colors.white,
                color: const Color(0xFF1976D2),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    _buildHeader(
                        context, provider.currentLocation.city, currentTime),

                    const SizedBox(height: 24),

                    // Air Quality Card (from existing widget)
                    const AirQualityCard(),

                    const SizedBox(height: 24),

                    // Additional Air Info
                    if (provider.weather != null)
                      _buildAdditionalAirInfo(provider.weather!),

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
            const Icon(Icons.air, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Air Quality',
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

  Widget _buildAdditionalAirInfo(dynamic weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Atmospheric Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildAtmosphericRow(
            Icons.cloud,
            'Cloud Cover',
            '${weather.current.cloudCover}%',
          ),
          const SizedBox(height: 16),

          _buildAtmosphericRow(
            Icons.visibility,
            'Visibility',
            '${weather.current.visibility.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 16),

          _buildAtmosphericRow(
            Icons.water_drop,
            'Humidity',
            '${weather.current.humidity}%',
          ),
          const SizedBox(height: 16),

          _buildAtmosphericRow(
            Icons.speed,
            'Pressure',
            '${weather.current.pressure} hPa',
          ),

          const SizedBox(height: 24),

          // Health Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.health_and_safety,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getHealthTips(
                      weather.current.humidity, weather.current.cloudCover),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphericRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getHealthTips(int humidity, int cloudCover) {
    if (humidity > 80) {
      return '💧 Kelembaban tinggi. Minum banyak air dan hindari aktivitas berat di luar ruangan.';
    } else if (humidity < 30) {
      return '🏜️ Kelembaban rendah. Gunakan pelembab dan hindari dehidrasi.';
    } else if (cloudCover > 80) {
      return '☁️ Langit berawan. Kondisi baik untuk aktivitas outdoor tanpa sinar UV berlebih.';
    } else {
      return '✅ Kondisi atmosfer normal. Cocok untuk aktivitas luar ruangan.';
    }
  }
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
