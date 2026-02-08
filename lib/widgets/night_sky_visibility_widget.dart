import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/astronomy_utils.dart';

class NightSkyVisibilityWidget extends StatelessWidget {
  final int cloudCover;
  final double moonIllumination;
  final double visibility;
  final int humidity;

  const NightSkyVisibilityWidget({
    super.key,
    required this.cloudCover,
    required this.moonIllumination,
    required this.visibility,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final index = AstronomyUtils.calculateSkyVisibility(
      cloudCover: cloudCover,
      moonIllumination: moonIllumination,
      visibility: visibility,
      humidity: humidity,
    );

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
                child: const Icon(Icons.star, color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Stargazing Index',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gauge & Score
          Center(
            child: CustomPaint(
              size: const Size(200, 100),
              painter: _GaugePainter(score: index.score),
              child: SizedBox(
                width: 200,
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${index.score}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      index.category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getScoreColor(index.score),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recommendation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getScoreColor(index.score).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getScoreColor(index.score).withOpacity(0.3),
              ),
            ),
            child: Text(
              index.recommendation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Factors Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFactorItem(Icons.cloud, '$cloudCover%', 'Cloud Cover'),
              _buildFactorItem(Icons.nightlight_round,
                  '${moonIllumination.round()}%', 'Moon'),
              _buildFactorItem(Icons.remove_red_eye,
                  '${visibility.toStringAsFixed(1)}km', 'Visibility'),
              _buildFactorItem(Icons.water_drop, '$humidity%', 'Humidity'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF00E676); // Green
    if (score >= 60) return const Color(0xFF69F0AE); // Light Green
    if (score >= 40) return const Color(0xFFFFD740); // Amber
    return const Color(0xFFFF5252); // Red
  }
}

class _GaugePainter extends CustomPainter {
  final int score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Foreground Arc (Score)
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Gradient for the score arc
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFFFF5252), // Red
        Color(0xFFFFD740), // Amber
        Color(0xFF00E676), // Green
      ],
    );

    fgPaint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );

    final sweepAngle = (score / 100) * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score;
}
