import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/astronomy_utils.dart';

class SkyVisibilityWidget extends StatelessWidget {
  final int cloudCover;
  final double visibility;
  final int humidity;
  final DateTime currentTime;

  const SkyVisibilityWidget({
    super.key,
    required this.cloudCover,
    required this.visibility,
    required this.humidity,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate moon illumination
    final moonAge = AstronomyUtils.calculateMoonAge(currentTime);
    final moonPhase = AstronomyUtils.getMoonPhase(moonAge);

    // Calculate visibility index
    final visibilityIndex = AstronomyUtils.calculateSkyVisibility(
      cloudCover: cloudCover,
      moonIllumination: moonPhase.illumination,
      visibility: visibility,
      humidity: humidity,
    );

    final color = _getColorForScore(visibilityIndex.score);

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F2027),
            const Color(0xFF203A43),
            const Color(0xFF2C5364),
          ],
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
                  Icons.stars,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Night Sky Visibility',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Gauge meter
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: GaugePainter(
                score: visibilityIndex.score,
                color: color,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getCategoryIcon(visibilityIndex.score),
                const SizedBox(width: 12),
                Text(
                  visibilityIndex.category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              visibilityIndex.recommendation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Factors breakdown
          const Text(
            'Visibility Factors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          _buildFactor(
            '☁️ Cloud Cover',
            cloudCover,
            '%',
            cloudCover <= 20,
          ),

          const SizedBox(height: 12),

          _buildFactor(
            '🌙 Moon Light',
            moonPhase.illumination.round(),
            '%',
            moonPhase.illumination <= 30,
          ),

          const SizedBox(height: 12),

          _buildFactor(
            '👁️ Visibility',
            visibility.round(),
            'km',
            visibility >= 20,
          ),

          const SizedBox(height: 12),

          _buildFactor(
            '💧 Humidity',
            humidity,
            '%',
            humidity <= 70,
          ),
        ],
      ),
    );
  }

  Widget _buildFactor(String label, int value, String unit, bool isGood) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGood
              ? Colors.green.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Text(
                '$value$unit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isGood ? Icons.check_circle : Icons.warning,
                color: isGood ? Colors.green : Colors.orange,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _getCategoryIcon(int score) {
    if (score >= 80) {
      return const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 16));
    } else if (score >= 60) {
      return const Text('⭐⭐⭐⭐', style: TextStyle(fontSize: 16));
    } else if (score >= 40) {
      return const Text('⭐⭐⭐', style: TextStyle(fontSize: 16));
    } else {
      return const Text('⭐⭐', style: TextStyle(fontSize: 16));
    }
  }
}

/// Custom painter untuk gauge meter
class GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  GaugePainter({
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = size.width * 0.35;

    // Draw background arc
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw colored segments
    final segments = [
      {'color': Colors.red, 'start': 0.0, 'end': 0.2},
      {'color': Colors.orange, 'start': 0.2, 'end': 0.4},
      {'color': Colors.yellow, 'start': 0.4, 'end': 0.6},
      {'color': Colors.lightGreen, 'start': 0.6, 'end': 0.8},
      {'color': Colors.green, 'start': 0.8, 'end': 1.0},
    ];

    for (final segment in segments) {
      final segmentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..color = (segment['color'] as Color).withOpacity(0.3);

      final start =
          math.pi * 0.75 + (math.pi * 1.5 * (segment['start'] as double));
      final sweep = math.pi *
          1.5 *
          ((segment['end'] as double) - (segment['start'] as double));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        segmentPaint,
      );
    }

    // Draw progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = color;

    final sweepAngle = math.pi * 1.5 * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw needle
    final needleAngle = math.pi * 0.75 + sweepAngle;
    final needleLength = radius + 10;
    final needleX = center.dx + needleLength * math.cos(needleAngle);
    final needleY = center.dy + needleLength * math.sin(needleAngle);

    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    canvas.drawLine(center, Offset(needleX, needleY), needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(center, 8, centerPaint);

    // Draw score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: score.toString(),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + 10,
      ),
    );

    // Draw scale labels
    _drawScaleLabel(canvas, center, radius, 0.0, '0');
    _drawScaleLabel(canvas, center, radius, 0.5, '50');
    _drawScaleLabel(canvas, center, radius, 1.0, '100');
  }

  void _drawScaleLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double position,
    String text,
  ) {
    final angle = math.pi * 0.75 + (math.pi * 1.5 * position);
    final labelRadius = radius + 35;
    final x = center.dx + labelRadius * math.cos(angle);
    final y = center.dy + labelRadius * math.sin(angle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
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
