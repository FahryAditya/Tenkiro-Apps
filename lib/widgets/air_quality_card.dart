import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/color_utils.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.airQuality == null || provider.weather == null) {
          return const SizedBox.shrink();
        }

        final airQuality = provider.airQuality!;
        final currentTime = DateTime.parse(provider.weather!.current.time);
        final textColor = ColorUtils.getTextColor(currentTime);
        final cardColor = ColorUtils.getCardColor(currentTime);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16), // ✅ Reduced from 18 to 16
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.air, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kualitas Udara',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // ✅ Reduced from 14 to 12

              // AQI Main Display
              Row(
                children: [
                  Container(
                    width: 62, // ✅ Reduced from 65 to 62
                    height: 62, // ✅ Reduced from 65 to 62
                    decoration: BoxDecoration(
                      color: Color(airQuality.getAQIColor()),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(airQuality.getAQIColor()).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${airQuality.aqi}',
                        style: const TextStyle(
                          fontSize: 24, // ✅ Reduced from 26 to 24
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14), // ✅ Reduced from 16 to 14
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          airQuality.category,
                          style: TextStyle(
                            fontSize: 15, // ✅ Reduced from 15 to 14 (keeping 15 for readability)
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4), // ✅ Reduced from 5 to 4
                        Text(
                          airQuality.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor.withOpacity(0.8),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14), // ✅ Reduced from 16 to 14

              // Pollutants Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.6, // ✅ Increased from 2.5 to 2.6 (make cards shorter)
                crossAxisSpacing: 8, // ✅ Reduced from 10 to 8
                mainAxisSpacing: 8, // ✅ Reduced from 10 to 8
                children: [
                  _buildPollutantCard(
                    'PM2.5',
                    airQuality.pm25.toStringAsFixed(1),
                    'µg/m³',
                    textColor,
                  ),
                  _buildPollutantCard(
                    'PM10',
                    airQuality.pm10.toStringAsFixed(1),
                    'µg/m³',
                    textColor,
                  ),
                  _buildPollutantCard(
                    'CO',
                    airQuality.carbonMonoxide.toStringAsFixed(0),
                    'µg/m³',
                    textColor,
                  ),
                  _buildPollutantCard(
                    'SO₂',
                    airQuality.sulphurDioxide.toStringAsFixed(1),
                    'µg/m³',
                    textColor,
                  ),
                ],
              ),

              const SizedBox(height: 10), // ✅ Keep at 10

              // AQI Scale Legend
              _buildAQILegend(textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollutantCard(
    String label,
    String value,
    String unit,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ✅ Reduced vertical from 7 to 6
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13, // ✅ Keep at 13
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 9, // ✅ Keep at 9
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAQILegend(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skala AQI:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6), // ✅ Reduced from 7 to 6
        Wrap(
          spacing: 6, // ✅ Keep at 6
          runSpacing: 5, // ✅ Keep at 5
          children: [
            _buildLegendItem('0-50 Baik', 0xFF00E400, textColor),
            _buildLegendItem('51-100 Sedang', 0xFFFFFF00, textColor),
            _buildLegendItem('101-150 Sensitif', 0xFFFF7E00, textColor),
            _buildLegendItem('151-200 Tidak Sehat', 0xFFFF0000, textColor),
            _buildLegendItem('201-300 Buruk', 0xFF8F3F97, textColor),
            _buildLegendItem('301+ Berbahaya', 0xFF7E0023, textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, // ✅ Reduced from 11 to 10
          height: 10, // ✅ Reduced from 11 to 10
          decoration: BoxDecoration(
            color: Color(color),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}