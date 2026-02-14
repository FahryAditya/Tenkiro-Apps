import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../utils/color_utils.dart';

class WeatherDetails extends StatelessWidget {
  const WeatherDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weather == null) {
          return const SizedBox.shrink();
        }

        final weather = provider.weather!;
        final current = weather.current;
        final daily = weather.daily;
        final currentTime = DateTime.parse(current.time);
        final textColor = ColorUtils.getTextColor(currentTime);
        final secondaryColor = ColorUtils.getSecondaryTextColor(currentTime);
        final cardColor = ColorUtils.getCardColor(currentTime);

        // Get sunrise and sunset
        final sunrise = DateTime.parse(daily.sunrise[0]);
        final sunset = DateTime.parse(daily.sunset[0]);

        // Calculate UV Index (0 at night)
        final isNight = currentTime.hour < sunrise.hour || currentTime.hour >= sunset.hour;
        final displayUV = isNight ? 0.0 : current.uvIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorUtils.getCardBorderColor(currentTime),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorUtils.getShadowColor(currentTime),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorUtils.getPrimaryColor(currentTime).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline, 
                      color: ColorUtils.getPrimaryColor(currentTime),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Detail Cuaca',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailGrid(
                context,
                [
                  _DetailItem(
                    icon: Icons.thermostat,
                    label: 'Terasa Seperti',
                    value: '${current.apparentTemperature.round()}°C',
                    description: 'Suhu yang dirasakan',
                  ),
                  _DetailItem(
                    icon: Icons.air,
                    label: 'Angin',
                    value: '${current.windSpeed.round()} km/j',
                    description: WeatherUtils.getWindDescription(current.windSpeed),
                  ),
                  _DetailItem(
                    icon: Icons.water_drop,
                    label: 'Kelembaban',
                    value: '${current.humidity}%',
                    description: WeatherUtils.getHumidityDescription(current.humidity),
                  ),
                  _DetailItem(
                    icon: Icons.wb_sunny,
                    label: 'UV Index',
                    value: displayUV.toStringAsFixed(1),
                    description: WeatherUtils.getUVDescription(displayUV),
                  ),
                  _DetailItem(
                    icon: Icons.visibility,
                    label: 'Visibilitas',
                    value: '${current.visibility.toStringAsFixed(1)} km',
                    description: WeatherUtils.getVisibilityDescription(current.visibility),
                  ),
                  _DetailItem(
                    icon: Icons.speed,
                    label: 'Tekanan',
                    value: '${current.pressure.round()} hPa',
                    description: 'Tekanan udara',
                  ),
                  _DetailItem(
                    icon: Icons.wb_twilight,
                    label: 'Matahari Terbit',
                    value: DateFormat('HH:mm').format(sunrise),
                    description: 'Sunrise',
                  ),
                  _DetailItem(
                    icon: Icons.nightlight,
                    label: 'Matahari Terbenam',
                    value: DateFormat('HH:mm').format(sunset),
                    description: 'Sunset',
                  ),
                ],
                textColor,
                secondaryColor,
                currentTime,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailGrid(
    BuildContext context,
    List<_DetailItem> items,
    Color textColor,
    Color secondaryColor,
    DateTime currentTime,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isSmallScreen ? 1.3 : 1.4,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildEnhancedDetailCard(item, textColor, secondaryColor, currentTime);
      },
    );
  }

  Widget _buildEnhancedDetailCard(
    _DetailItem item,
    Color textColor,
    Color secondaryColor,
    DateTime currentTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorUtils.getCardBorderColor(currentTime),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorUtils.getPrimaryColor(currentTime).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: ColorUtils.getPrimaryColor(currentTime),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 10,
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String description;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });
}