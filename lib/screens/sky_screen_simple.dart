import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

/// Simplified Sky Screen - Use this if full version has issues
class SkyScreenSimple extends StatelessWidget {
  const SkyScreenSimple({super.key});

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
              return RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                backgroundColor: Colors.white,
                color: const Color(0xFF395886),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.nights_stay,
                                color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Sky Watch',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              provider.currentLocation.city,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, d MMM yyyy', 'id_ID')
                                  .format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.stars,
                            size: 80,
                            color: Colors.white,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Astronomy Features',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Solar Tracker, Moon Phase, and Sky Visibility features are being initialized...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features List
                    _buildFeatureCard(
                      Icons.wb_sunny,
                      'Solar Tracker',
                      'Real-time sun position, golden hour detection',
                      Colors.orange,
                    ),

                    const SizedBox(height: 16),

                    _buildFeatureCard(
                      Icons.nightlight_round,
                      'Moon Phase',
                      'Current moon phase and illumination',
                      Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    _buildFeatureCard(
                      Icons.visibility,
                      'Sky Visibility Index',
                      'Stargazing condition analysis',
                      Colors.purple,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
