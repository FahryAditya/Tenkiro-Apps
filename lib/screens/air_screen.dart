import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../widgets/air_quality_card.dart';

class AirScreen extends StatelessWidget {
  const AirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ MediaQuery untuk responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenHeight < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF2196F3),
            ],
          ),
        ),
        // ✅ SafeArea
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              final currentTime = provider.weather != null
                  ? DateTime.parse(provider.weather!.current.time)
                  : DateTime.now();

              // Get city with null safety
              final String city =
                  provider.currentLocation?.city ?? 'Loading...';

              return RefreshIndicator(
                onRefresh: () => provider.refreshWeatherData(),
                backgroundColor: Colors.white,
                color: const Color(0xFF1976D2),
                // ✅ SingleChildScrollView dengan physics yang tepat
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallDevice ? 12 : 16,
                      vertical: isSmallDevice ? 12 : 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // ✅ Important!
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(
                          context,
                          city,
                          currentTime,
                          isSmallDevice,
                        ),

                        SizedBox(height: isSmallDevice ? 12 : 16), // ✅ Reduced

                        // Air Quality Card
                        const AirQualityCard(),

                        SizedBox(height: isSmallDevice ? 12 : 16), // ✅ Reduced

                        // Additional Air Info
                        if (provider.weather != null)
                          _buildAdditionalAirInfo(
                            provider.weather!,
                            isSmallDevice,
                          ),

                        SizedBox(height: isSmallDevice ? 12 : 16), // ✅ Reduced

                        // Pollutants Info
                        _buildPollutantsInfo(isSmallDevice),

                        // ✅ Bottom padding for BottomNav (increased to 100)
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String city,
    DateTime time,
    bool isSmallDevice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kualitas Udara',
          style: TextStyle(
            fontSize: isSmallDevice ? 24 : 28, // ✅ Reduced
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallDevice ? 4 : 6), // ✅ Reduced
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white.withOpacity(0.9),
              size: isSmallDevice ? 14 : 16, // ✅ Reduced
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                city,
                style: TextStyle(
                  fontSize: isSmallDevice ? 12 : 14, // ✅ Reduced
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                DateFormat('HH:mm, dd MMM', 'id_ID').format(time),
                style: TextStyle(
                  fontSize: isSmallDevice ? 11 : 13, // ✅ Reduced
                  color: Colors.white.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalAirInfo(dynamic weather, bool isSmallDevice) {
    return Container(
      padding: EdgeInsets.all(isSmallDevice ? 12 : 16), // ✅ Reduced
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontSize: isSmallDevice ? 14 : 16, // ✅ Reduced
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallDevice ? 10 : 12), // ✅ Reduced
          _buildInfoRow(
            Icons.visibility,
            'Visibilitas',
            '${weather.current.visibility ~/ 1000} km',
            isSmallDevice,
          ),
          SizedBox(height: isSmallDevice ? 7 : 9), // ✅ Reduced
          _buildInfoRow(
            Icons.cloud,
            'Tutupan Awan',
            '${weather.current.cloudCover}%',
            isSmallDevice,
          ),
          SizedBox(height: isSmallDevice ? 7 : 9), // ✅ Reduced
          _buildInfoRow(
            Icons.opacity,
            'Kelembaban',
            '${weather.current.humidity}%',
            isSmallDevice,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isSmallDevice,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: isSmallDevice ? 18 : 20, // ✅ Reduced
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallDevice ? 12 : 13, // ✅ Reduced
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallDevice ? 13 : 14, // ✅ Reduced
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPollutantsInfo(bool isSmallDevice) {
    return Container(
      padding: EdgeInsets.all(isSmallDevice ? 12 : 16), // ✅ Reduced
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Polutan Udara',
            style: TextStyle(
              fontSize: isSmallDevice ? 14 : 16, // ✅ Reduced
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallDevice ? 8 : 12), // ✅ Reduced
          Text(
            'Informasi kualitas udara diambil dari sensor lokal dan satelit untuk memberikan data akurat.',
            style: TextStyle(
              fontSize: isSmallDevice ? 11 : 12, // ✅ Reduced
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
