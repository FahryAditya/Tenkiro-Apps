import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/astronomy_utils.dart';
import '../utils/color_utils.dart';

// Import widgets
import '../widgets/solar_tracker_widget.dart';
import '../widgets/moon_phase_widget.dart';
import '../widgets/sky_visibility_widget.dart';

// Import Sky Map
import '../sky_map_page.dart';

class SkyScreenEnhanced extends StatefulWidget {
  const SkyScreenEnhanced({super.key});

  @override
  State<SkyScreenEnhanced> createState() => _SkyScreenEnhancedState();
}

class _SkyScreenEnhancedState extends State<SkyScreenEnhanced>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2332),
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.weather == null) {
                return _buildLoadingState();
              }

              if (provider.error != null && provider.weather == null) {
                return _buildErrorState(provider);
              }

              if (provider.weather == null) {
                return _buildNoDataState();
              }

              return _buildContent(provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading astronomy data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.refreshWeatherData(),
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A2332),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nights_stay,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WeatherProvider provider) {
    final weather = provider.weather!;
    final location = provider.currentLocation;
    final currentTime = DateTime.parse(weather.current.time);

    return RefreshIndicator(
      onRefresh: () => provider.refreshWeatherData(),
      backgroundColor: Colors.white,
      color: const Color(0xFF395886),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with hamburger menu
          _buildHeader(context, location.city, currentTime),

          const SizedBox(height: 24),

          // Solar Tracker Widget
          _buildSafeWidget(
            () => SolarTrackerWidget(
              latitude: location.latitude,
              longitude: location.longitude,
              sunrise: DateTime.parse(weather.daily.sunrise[0]),
              sunset: DateTime.parse(weather.daily.sunset[0]),
              currentTime: currentTime,
            ),
            'Solar Tracker',
          ),

          const SizedBox(height: 24),

          // Moon Phase Widget
          _buildSafeWidget(
            () => MoonPhaseWidget(
              currentTime: currentTime,
            ),
            'Moon Phase',
          ),

          const SizedBox(height: 24),

          // Sky Visibility Widget
          _buildSafeWidget(
            () => SkyVisibilityWidget(
              cloudCover: weather.current.cloudCover,
              visibility: weather.current.visibility,
              humidity: weather.current.humidity,
              currentTime: currentTime,
            ),
            'Sky Visibility',
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSafeWidget(Widget Function() builder, String widgetName) {
    try {
      return builder();
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  '$widgetName Error',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This component is temporarily unavailable.\n${e.toString()}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, String city, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.nights_stay, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sky Watch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Hamburger Menu
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => _showSkyMenu(context),
              tooltip: 'Sky Menu',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              city,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMM yyyy', 'id_ID').format(time),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSkyMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Menu title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.nights_stay, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Sky Watch Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white30, height: 32),

            // Sky Map Menu Item
            _buildMenuItem(
              context,
              icon: Icons.map,
              title: 'Peta Langit 3D',
              subtitle: 'Lihat langit real-time dengan sensor',
              color: Colors.purple,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              ),
              onTap: () {
                Navigator.pop(context);
                _openSkyMap(context);
              },
            ),

            const Divider(
                color: Colors.white10, height: 1, indent: 80, endIndent: 24),

            // Future menu items
            _buildMenuItem(
              context,
              icon: Icons.star,
              title: 'Constellation Guide',
              subtitle: 'Learn about constellations (Coming Soon)',
              color: Colors.blue,
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur akan datang!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient ??
                    LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _openSkyMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SkyMapPage(),
        fullscreenDialog: true,
      ),
    );
  }
}
