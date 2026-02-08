import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../utils/astronomy_utils.dart';

class SolarTrackerWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;

  const SolarTrackerWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate solar data
    final elevation = AstronomyUtils.calculateSolarElevation(
      currentTime,
      latitude,
      longitude,
    );

    final goldenHourStatus = AstronomyUtils.getGoldenHourStatus(elevation);
    final dayLength = AstronomyUtils.calculateDayLength(
      currentTime,
      latitude,
      longitude,
      sunrise,
      sunset,
    );

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getSkyGradient(elevation),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Solar Tracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Solar Arc Visualization
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: SolarArcPainter(
                sunrise: sunrise,
                sunset: sunset,
                currentTime: currentTime,
                elevation: elevation,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfo(
                '🌅 Sunrise',
                DateFormat('HH:mm').format(sunrise),
              ),
              _buildTimeInfo(
                '🌇 Sunset',
                DateFormat('HH:mm').format(sunset),
              ),
              _buildTimeInfo(
                '⏱️ Day Length',
                '${dayLength.floor()}h ${((dayLength % 1) * 60).round()}m',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Solar Data
          _buildDataRow('Solar Elevation', '${elevation.toStringAsFixed(1)}°'),
          const SizedBox(height: 12),
          _buildDataRow('Golden Hour', _getGoldenHourText(goldenHourStatus)),

          // Golden Hour Indicator
          if (goldenHourStatus == GoldenHourStatus.morningGolden ||
              goldenHourStatus == GoldenHourStatus.eveningGolden)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Perfect for photography!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
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

  String _getGoldenHourText(GoldenHourStatus status) {
    switch (status) {
      case GoldenHourStatus.morningGolden:
        return 'Morning Golden Hour ✨';
      case GoldenHourStatus.eveningGolden:
        return 'Evening Golden Hour ✨';
      case GoldenHourStatus.blueHour:
        return 'Blue Hour 💙';
      case GoldenHourStatus.daylight:
        return 'Full Daylight ☀️';
      case GoldenHourStatus.night:
        return 'Night Time 🌙';
    }
  }

  List<Color> _getSkyGradient(double elevation) {
    if (elevation > 6) {
      // Daytime
      return [
        const Color(0xFF4A90E2),
        const Color(0xFF87CEEB),
      ];
    } else if (elevation > -0.833) {
      // Golden hour
      return [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFA500),
      ];
    } else if (elevation > -6) {
      // Blue hour
      return [
        const Color(0xFF1A2332),
        const Color(0xFF4A5F7F),
      ];
    } else {
      // Night
      return [
        const Color(0xFF0A0E27),
        const Color(0xFF1A2332),
      ];
    }
  }
}

/// Custom painter untuk solar arc
class SolarArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;
  final double elevation;

  SolarArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
    required this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.3);

    // Draw horizon line
    final horizonY = size.height * 0.8;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      paint,
    );

    // Draw arc path
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.5);

    final arcRect = Rect.fromLTWH(
      size.width * 0.1,
      horizonY - size.height * 0.5,
      size.width * 0.8,
      size.height * 0.5,
    );

    canvas.drawArc(
      arcRect,
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    // Calculate sun position
    final totalMinutes = sunset.difference(sunrise).inMinutes;
    final currentMinutes = currentTime.difference(sunrise).inMinutes;
    final progress = (currentMinutes / totalMinutes).clamp(0.0, 1.0);

    if (currentTime.isAfter(sunrise) && currentTime.isBefore(sunset)) {
      // Sun is above horizon
      final angle = math.pi + (progress * math.pi);
      final sunX = size.width * 0.5 + (size.width * 0.4) * math.cos(angle);
      final sunY = horizonY + (size.height * 0.5) * math.sin(angle);

      // Draw sun
      final sunPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.yellow;

      // Glow effect
      for (int i = 3; i > 0; i--) {
        canvas.drawCircle(
          Offset(sunX, sunY),
          12.0 + (i * 4),
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.yellow.withOpacity(0.2 / i),
        );
      }

      // Sun circle
      canvas.drawCircle(
        Offset(sunX, sunY),
        12,
        sunPaint,
      );

      // Draw path line
      final pathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.yellow.withOpacity(0.5);

      final path = Path();
      path.moveTo(size.width * 0.1, horizonY);

      for (double i = 0; i <= progress; i += 0.01) {
        final a = math.pi + (i * math.pi);
        final x = size.width * 0.5 + (size.width * 0.4) * math.cos(a);
        final y = horizonY + (size.height * 0.5) * math.sin(a);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, pathPaint);
    }

    // Draw sunrise/sunset markers
    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.6);

    // Sunrise marker
    canvas.drawCircle(
      Offset(size.width * 0.1, horizonY),
      6,
      markerPaint,
    );

    // Sunset marker
    canvas.drawCircle(
      Offset(size.width * 0.9, horizonY),
      6,
      markerPaint,
    );

    // Draw labels
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Sunrise label
    textPainter.text = TextSpan(
      text: DateFormat('HH:mm').format(sunrise),
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.1 - textPainter.width / 2, horizonY + 12),
    );

    // Sunset label
    textPainter.text = TextSpan(
      text: DateFormat('HH:mm').format(sunset),
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.9 - textPainter.width / 2, horizonY + 12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
