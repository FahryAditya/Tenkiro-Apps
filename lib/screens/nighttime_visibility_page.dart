import 'package:flutter/material.dart';
import '../widgets/night_sky_visibility_widget.dart';

class NighttimeVisibilityPage extends StatelessWidget {
  const NighttimeVisibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    const int cloudCover = 20; // 0-100%
    const double moonIllumination = 30; // 0-100%
    const double visibility = 15; // km

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
          'Nighttime Visibility',
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
            const Text(
              'Current Conditions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            NightSkyVisibilityWidget(
              cloudCover: cloudCover,
              moonIllumination: moonIllumination,
              visibility: visibility,
              humidity: 60, // Sample humidity value
            ),
            const SizedBox(height: 24),
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
                    'Factors Affecting Visibility',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFactorRow(
                      'Cloud Cover', '$cloudCover%', 'Lower is better'),
                  _buildFactorRow('Moon Light', '${moonIllumination.round()}%',
                      'Lower is better for stargazing'),
                  _buildFactorRow(
                      'Atmospheric Visibility',
                      '${visibility.toStringAsFixed(1)} km',
                      'Higher is better'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(String factor, String value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              factor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
