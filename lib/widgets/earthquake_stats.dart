import 'package:flutter/material.dart';
import '../models/earthquake.dart';

class EarthquakeStats extends StatelessWidget {
  final List<Earthquake> earthquakes;

  const EarthquakeStats({
    super.key,
    required this.earthquakes,
  });

  @override
  Widget build(BuildContext context) {
    if (earthquakes.isEmpty) {
      return const SizedBox.shrink();
    }

    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik 24 Jam Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Gempa',
                  value: earthquakes.length.toString(),
                  icon: Icons.public,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Terkuat',
                  value: 'M${stats['maxMagnitude']}',
                  icon: Icons.trending_up,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Rata-rata',
                  value: 'M${stats['avgMagnitude']}',
                  icon: Icons.show_chart,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Signifikan',
                  value: stats['significantCount'].toString(),
                  icon: Icons.warning,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final maxMagnitude = earthquakes
        .map((e) => e.magnitude)
        .reduce((a, b) => a > b ? a : b)
        .toStringAsFixed(1);

    final avgMagnitude = (earthquakes
            .map((e) => e.magnitude)
            .reduce((a, b) => a + b) /
        earthquakes.length)
        .toStringAsFixed(1);

    final significantCount = earthquakes
        .where((e) => e.magnitude >= 5.0)
        .length;

    return {
      'maxMagnitude': maxMagnitude,
      'avgMagnitude': avgMagnitude,
      'significantCount': significantCount,
    };
  }
}