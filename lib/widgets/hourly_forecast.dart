import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../utils/color_utils.dart';

class HourlyForecast extends StatelessWidget {
  const HourlyForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weather == null) {
          return const SizedBox.shrink();
        }

        final weather = provider.weather!;
        final hourly = weather.hourly;
        final currentTime = DateTime.parse(weather.current.time);
        final textColor = ColorUtils.getTextColor(currentTime);
        final secondaryColor = ColorUtils.getSecondaryTextColor(currentTime);

        // Get next 48 hours
        final now = DateTime.parse(weather.current.time);
        final currentHourIndex = hourly.time.indexWhere((time) {
          final hourTime = DateTime.parse(time);
          return hourTime.isAfter(now) || hourTime.isAtSameMomentAs(now);
        });

        if (currentHourIndex == -1) return const SizedBox.shrink();

        final next48Hours = List.generate(
          48,
          (index) => currentHourIndex + index,
        ).where((i) => i < hourly.time.length).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorUtils.getPrimaryColor(currentTime).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: ColorUtils.getPrimaryColor(currentTime),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Perkiraan Per Jam',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6), // ✅ Reduced from 8 to 6
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 110), // ✅ NILAI SUPER AMAN: 110px (dari 120px)
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10), // ✅ Reduced from 12 to 10
                itemCount: next48Hours.length,
                itemBuilder: (context, index) {
                  final hourIndex = next48Hours[index];
                  final time = DateTime.parse(hourly.time[hourIndex]);
                  final temp = hourly.temperature[hourIndex];
                  final weatherCode = hourly.weatherCode[hourIndex];
                  final humidity = hourly.humidity[hourIndex];
                  final isDay = hourly.isDay[hourIndex] == 1;
                  final isNow = index == 0;

                  return Container(
                    width: 75, // ✅ Reduced from 80 to 75
                    margin: const EdgeInsets.symmetric(horizontal: 2.5), // ✅ Reduced from 3 to 2.5
                    padding: const EdgeInsets.symmetric(
                      vertical: 6, // ✅ Reduced from 8 to 6
                      horizontal: 5, // ✅ Reduced from 6 to 5
                    ),
                    decoration: BoxDecoration(
                      gradient: isNow
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorUtils.getPrimaryColor(currentTime).withOpacity(0.25), // ✅ Reduced opacity from 0.3
                                ColorUtils.getPrimaryColor(currentTime).withOpacity(0.08), // ✅ Reduced opacity from 0.1
                              ],
                            )
                          : null,
                      color: isNow ? null : ColorUtils.getCardColor(currentTime),
                      borderRadius: BorderRadius.circular(14), // ✅ Reduced from 16 to 14
                      border: Border.all(
                        color: isNow
                            ? ColorUtils.getPrimaryColor(currentTime)
                            : ColorUtils.getCardBorderColor(currentTime),
                        width: isNow ? 1.2 : 0.8, // ✅ Reduced from 1.5/1 to 1.2/0.8
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorUtils.getShadowColor(currentTime).withOpacity(0.5), // ✅ Reduced opacity
                          blurRadius: isNow ? 6 : 4, // ✅ Reduced from 8/6 to 6/4
                          offset: Offset(0, isNow ? 2 : 1), // ✅ Reduced from 3/2 to 2/1
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // ✅ Changed to center untuk distribusi optimal
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Time label
                        Text(
                          isNow ? 'Sekarang' : DateFormat('HH:mm').format(time),
                          style: TextStyle(
                            fontSize: 10, // ✅ Reduced from 10.5 to 10
                            fontWeight: isNow ? FontWeight.w700 : FontWeight.w600,
                            color: isNow ? ColorUtils.getPrimaryColor(currentTime) : textColor,
                            height: 1.2, // ✅ Tambahan untuk kontrol line height
                          ),
                        ),
                        const SizedBox(height: 3), // ✅ Reduced from 4 to 3
                        
                        // Weather icon
                        Text(
                          WeatherUtils.getWeatherIcon(weatherCode, isDay),
                          style: const TextStyle(
                            fontSize: 24, // ✅ Reduced from 26 to 24
                            height: 1.0, // ✅ Tambahan untuk kontrol line height
                          ),
                        ),
                        const SizedBox(height: 3), // ✅ Reduced from 4 to 3
                        
                        // Temperature
                        Text(
                          '${temp.round()}°',
                          style: TextStyle(
                            fontSize: 14, // ✅ Reduced from 15 to 14
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.2, // ✅ Tambahan untuk kontrol line height
                          ),
                        ),
                        const SizedBox(height: 2), // ✅ Reduced from 3 to 2
                        
                        // Humidity
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 9, // ✅ Reduced from 10 to 9
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 2), // ✅ Keep at 2
                            Text(
                              '$humidity%',
                              style: TextStyle(
                                fontSize: 9, // ✅ Reduced from 9.5 to 9
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                                height: 1.2, // ✅ Tambahan untuk kontrol line height
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}