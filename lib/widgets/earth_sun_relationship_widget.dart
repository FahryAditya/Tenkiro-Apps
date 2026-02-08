import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/astronomy_utils.dart';

class EarthSunRelationshipWidget extends StatelessWidget {
  final DateTime date;
  final bool northernHemisphere;

  const EarthSunRelationshipWidget({
    super.key,
    required this.date,
    this.northernHemisphere = true,
  });

  @override
  Widget build(BuildContext context) {
    final declination = AstronomyUtils.calculateSolarDeclination(date);
    final season = AstronomyUtils.getSeason(date, northernHemisphere);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.public, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Earth-Sun Relation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Orbit Visualization
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: OrbitPainter(
                  dayOfYear: dayOfYear,
                  season: season,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Current Season',
                  season,
                  Icons.wb_sunny_outlined,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  'Solar Declination',
                  '${declination.toStringAsFixed(1)}°',
                  Icons.explore,
                  Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getSeasonDescription(season),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _getSeasonDescription(String season) {
    if (season.contains('Semi'))
      return 'Nature awakens. Days get longer, temperatures rise.';
    if (season.contains('Panas'))
      return 'Maximum tilt towards the sun. Longest days, warmest weather.';
    if (season.contains('Gugur'))
      return 'Temperatures cool down. Days get shorter as winter approaches.';
    return 'Maximum tilt away from the sun. Shortest days, coldest weather.';
  }
}

class OrbitPainter extends CustomPainter {
  final int dayOfYear;
  final String season;

  OrbitPainter({required this.dayOfYear, required this.season});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw Orbit Path
    final orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, orbitPaint);

    // Draw Sun
    final sunPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    // Sun Glow
    canvas.drawCircle(
        center, 15, Paint()..color = Colors.orangeAccent.withOpacity(0.3));
    canvas.drawCircle(center, 8, sunPaint);

    // Calculate Earth Position
    // June 21 (Day 172) -> Top (-pi/2)
    final angle = (dayOfYear - 172) / 365.0 * 2 * math.pi - math.pi / 2;

    final earthX = center.dx + radius * math.cos(angle);
    final earthY = center.dy + radius * math.sin(angle);
    final earthPos = Offset(earthX, earthY);

    // Draw Earth
    final earthPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(earthPos, 6, earthPaint);

    // Draw Labels (Solstices/Equinoxes)
    _drawLabel(canvas, center, radius, -math.pi / 2, 'Jun Sol');
    _drawLabel(canvas, center, radius, math.pi / 2, 'Dec Sol');
    _drawLabel(canvas, center, radius, 0, 'Sep Eq');
    _drawLabel(canvas, center, radius, math.pi, 'Mar Eq');
  }

  void _drawLabel(
      Canvas canvas, Offset center, double radius, double angle, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position slightly outside orbit
    final x =
        center.dx + (radius + 15) * math.cos(angle) - textPainter.width / 2;
    final y =
        center.dy + (radius + 15) * math.sin(angle) - textPainter.height / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant OrbitPainter oldDelegate) =>
      oldDelegate.dayOfYear != dayOfYear;
}
