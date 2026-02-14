import 'package:flutter/material.dart';

class ObjectVisibilityScreen extends StatelessWidget {
  const ObjectVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCDB2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// ===== JUDUL =====
              const Text(
                'Sky Visibility',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// ===== LEGEND (ANTI OVERFLOW) =====
              _buildLegend(),

              const SizedBox(height: 20),

              /// ===== LIST =====
              Expanded(
                child: ListView(
                  children: const [
                    VisibilityCard(
                      emoji: '🌙',
                      name: 'Bulan',
                      type: 'Natural Satellite',
                      score: 85,
                      status: 'Terlihat sangat jelas malam ini',
                      color: Colors.green,
                    ),
                    VisibilityCard(
                      emoji: '🪐',
                      name: 'Saturnus dengan Cincin Panjang',
                      type: 'Planet',
                      score: 60,
                      status: 'Terlihat sebagian',
                      color: Colors.orange,
                    ),
                    VisibilityCard(
                      emoji: '☄️',
                      name: 'Komet Jangka Panjang Sangat Terang',
                      type: 'Comet',
                      score: 30,
                      status: 'Sulit terlihat',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== LEGEND =====
  static Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        LegendItem(emoji: '🟢', text: 'Terlihat Jelas'),
        LegendItem(emoji: '🟠', text: 'Terlihat Sebagian'),
        LegendItem(emoji: '🔴', text: 'Tidak Terlihat'),
      ],
    );
  }
}

/// =======================================================
/// LEGEND ITEM (ANTI OVERFLOW)
/// =======================================================
class LegendItem extends StatelessWidget {
  final String emoji;
  final String text;

  const LegendItem({
    super.key,
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// =======================================================
/// VISIBILITY CARD (ANTI RIGHT OVERFLOW)
/// =======================================================
class VisibilityCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String type;
  final int score;
  final String status;
  final Color color;

  const VisibilityCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.type,
    required this.score,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== HEADER =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),

              /// TEXT AREA (EXPANDED)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// SCORE BADGE (FLEXIBLE)
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '%',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ===== STATUS =====
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
