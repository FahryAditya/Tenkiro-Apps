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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ✅ 1. MediaQuery - Get device dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallDevice = screenHeight < 700;
    final isTablet = screenWidth > 600;

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
            // ✅ 3. SafeArea - Avoid system UI overlaps
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                color: ColorUtils.getPrimaryColor(currentTime),
                backgroundColor: ColorUtils.getCardColor(currentTime),
                strokeWidth: 3,
                // ✅ 2. LayoutBuilder - Responsive layout based on constraints
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildContent(
                      provider,
                      textColor,
                      currentTime,
                      constraints,
                      isSmallDevice,
                      isTablet,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    WeatherProvider provider,
    Color textColor,
    DateTime currentTime,
    BoxConstraints constraints,
    bool isSmallDevice,
    bool isTablet,
  ) {
    // Loading state
    if (provider.isLoading && provider.weather == null) {
      return _buildLoadingState(textColor, currentTime, constraints);
    }

    // Error state
    if (provider.error != null && provider.weather == null) {
      return _buildErrorState(provider, textColor, currentTime, constraints);
    }

    // ✅ 4. SingleChildScrollView - Scrollable content
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              constraints.maxHeight, // Ensure full height for RefreshIndicator
        ),
        child: Column(
          children: [
            // ✅ More responsive spacing based on device size
            SizedBox(height: isSmallDevice ? 8 : 12),

            const WeatherHeader(),

            SizedBox(height: isSmallDevice ? 12 : 18),

            const TemperatureChart(),

            SizedBox(height: isSmallDevice ? 16 : 22),

            const HourlyForecast(),

            SizedBox(height: isSmallDevice ? 16 : 22),

            const DailyForecast(),

            SizedBox(height: isSmallDevice ? 16 : 22),

            const WeatherDetails(),

            SizedBox(height: isSmallDevice ? 16 : 22),

            const AirQualityCard(),

            // ✅ Reduced bottom padding to avoid BottomNavigationBar overlap
            SizedBox(height: isSmallDevice ? 60 : 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    Color textColor,
    DateTime currentTime,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ 5. Flexible spacing
            const Spacer(flex: 2),

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

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
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

            const Spacer(flex: 3),

            // ✅ Bottom padding for BottomNav
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    WeatherProvider provider,
    Color textColor,
    DateTime currentTime,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

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

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorUtils.getCardColor(currentTime),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorUtils.getCardBorderColor(currentTime),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorUtils.getSecondaryTextColor(currentTime),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => provider.loadWeatherData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.getPrimaryColor(currentTime),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),

              const Spacer(flex: 3),

              // ✅ Bottom padding for BottomNav
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
