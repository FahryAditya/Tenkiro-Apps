import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../utils/color_utils.dart';

class DailyForecast extends StatefulWidget {
  const DailyForecast({super.key});

  @override
  State<DailyForecast> createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weather == null) {
          return const SizedBox.shrink();
        }

        final weather = provider.weather!;
        final daily = weather.daily;
        final currentTime = DateTime.parse(weather.current.time);

        final textColor = ColorUtils.getTextColor(currentTime);
        final secondaryColor = ColorUtils.getSecondaryTextColor(currentTime);
        final cardColor = ColorUtils.getCardColor(currentTime);

        final displayDays = _isExpanded ? daily.time.length : 7;

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
              /// HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorUtils.getPrimaryColor(currentTime)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: ColorUtils.getPrimaryColor(currentTime),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perkiraan $displayDays Hari',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// LIST HARIAN
              ...List.generate(
                displayDays,
                (index) => _buildEnhancedDayItem(
                  daily,
                  index,
                  textColor,
                  secondaryColor,
                  currentTime,
                  index == 0,
                ),
              ),

              /// BUTTON EXPAND
              if (daily.time.length > 7) ...[
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: ColorUtils.getPrimaryColor(currentTime)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ColorUtils.getPrimaryColor(currentTime)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color:
                                ColorUtils.getPrimaryColor(currentTime),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isExpanded
                                ? 'Ciutkan'
                                : 'Lihat Selengkapnya',
                            style: TextStyle(
                              color: ColorUtils.getPrimaryColor(currentTime),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// ================= ITEM HARIAN (FIX OVERFLOW) =================
  Widget _buildEnhancedDayItem(
    dynamic daily,
    int index,
    Color textColor,
    Color secondaryColor,
    DateTime currentTime,
    bool isToday,
  ) {
    final date = DateTime.parse(daily.time[index]);
    final dayName =
        isToday ? 'Hari Ini' : DateFormat('EEE', 'id_ID').format(date); // Shorter day name
    final dateStr = DateFormat('d MMM', 'id_ID').format(date);

    final weatherCode = daily.weatherCode[index];
    final tempMax = daily.temperatureMax[index].round();
    final tempMin = daily.temperatureMin[index].round();
    final precipitation = daily.precipitationProbability[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isToday
            ? ColorUtils.getPrimaryColor(currentTime).withOpacity(0.15)
            : textColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? ColorUtils.getPrimaryColor(currentTime).withOpacity(0.4)
              : ColorUtils.getCardBorderColor(currentTime),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          /// HARI & TANGGAL
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? ColorUtils.getPrimaryColor(currentTime)
                        : textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          /// HUJAN
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop,
                      size: 12, color: Colors.blue.shade700),
                  const SizedBox(width: 3),
                  Text(
                    '$precipitation%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// IKON
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                WeatherUtils.getWeatherIcon(weatherCode, true),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          /// SUHU
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text(
                  '$tempMin°',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.4),
                          Colors.orange.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$tempMax°',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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
