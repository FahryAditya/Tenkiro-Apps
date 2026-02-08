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
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: next48Hours.length,
                itemBuilder: (context, index) {
                  final hourIndex = next48Hours[index];
                  final time = DateTime.parse(hourly.time[hourIndex]);
                  final temp = hourly.temperature[hourIndex];
                  final weatherCode = hourly.weatherCode[hourIndex];
                  final humidity = hourly.humidity[hourIndex];
                  final isDay = hourly.isDay[hourIndex] == 1;
                  final isNow = index == 0;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: isNow
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorUtils.getPrimaryColor(currentTime).withOpacity(0.3),
                                ColorUtils.getPrimaryColor(currentTime).withOpacity(0.1),
                              ],
                            )
                          : null,
                      color: isNow ? null : ColorUtils.getCardColor(currentTime),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isNow
                            ? ColorUtils.getPrimaryColor(currentTime)
                            : ColorUtils.getCardBorderColor(currentTime),
                        width: isNow ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorUtils.getShadowColor(currentTime),
                          blurRadius: isNow ? 12 : 8,
                          offset: Offset(0, isNow ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isNow ? 'Sekarang' : DateFormat('HH:mm').format(time),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isNow ? FontWeight.w700 : FontWeight.w600,
                            color: isNow ? ColorUtils.getPrimaryColor(currentTime) : textColor,
                          ),
                        ),
                        Text(
                          WeatherUtils.getWeatherIcon(weatherCode, isDay),
                          style: const TextStyle(fontSize: 36),
                        ),
                        Text(
                          '${temp.round()}°',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 14,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$humidity%',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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