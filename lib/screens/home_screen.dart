import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/color_utils.dart';
import '../widgets/weather_header.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/weather_details.dart';
import '../widgets/air_quality_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive for better performance

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final currentTime = provider.weather != null
            ? DateTime.parse(provider.weather!.current.time)
            : DateTime.now();

        final backgroundColor = provider.weather != null
            ? ColorUtils.getBackgroundColor(
                currentTime,
                provider.weather!.current.weatherCode,
              )
            : const Color(0xFFE8EEF7);

        final isSunset = ColorUtils.isSunsetTime(currentTime);
        final textColor = ColorUtils.getTextColor(currentTime);

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: isSunset ? ColorUtils.getSunsetGradient() : null,
              color: isSunset ? null : backgroundColor,
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                color: ColorUtils.getPrimaryColor(currentTime),
                backgroundColor: ColorUtils.getCardColor(currentTime),
                strokeWidth: 3,
                child: _buildContent(provider, textColor, currentTime),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
      WeatherProvider provider, Color textColor, DateTime currentTime) {
    if (provider.isLoading && provider.weather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorUtils.getCardColor(currentTime),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.getShadowColor(currentTime),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: ColorUtils.getPrimaryColor(currentTime),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: ColorUtils.getCardColor(currentTime),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorUtils.getCardBorderColor(currentTime),
                  width: 1.5,
                ),
              ),
              child: Text(
                'Memuat data cuaca...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null && provider.weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ColorUtils.getCardColor(currentTime),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorUtils.getCardBorderColor(currentTime),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorUtils.getShadowColor(currentTime),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: textColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorUtils.getCardColor(currentTime),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorUtils.getCardBorderColor(currentTime),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorUtils.getSecondaryTextColor(currentTime),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => provider.loadWeatherData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.getPrimaryColor(currentTime),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use ListView with cacheExtent for better performance
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      physics: const BouncingScrollPhysics(),
      cacheExtent: 500,
      children: const [
        WeatherHeader(),
        SizedBox(height: 24),
        TemperatureChart(),
        SizedBox(height: 28),
        HourlyForecast(),
        SizedBox(height: 28),
        DailyForecast(),
        SizedBox(height: 28),
        WeatherDetails(),
        SizedBox(height: 28),
        AirQualityCard(),
        SizedBox(height: 100),
      ],
    );
  }
}
