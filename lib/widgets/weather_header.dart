import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../utils/color_utils.dart';

class WeatherHeader extends StatefulWidget {
  const WeatherHeader({super.key});

  @override
  State<WeatherHeader> createState() => _WeatherHeaderState();
}

class _WeatherHeaderState extends State<WeatherHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weather == null) {
          return const SizedBox.shrink();
        }

        final weather = provider.weather!;
        final currentTime = DateTime.parse(weather.current.time);
        final textColor = ColorUtils.getTextColor(currentTime);
        final secondaryColor = ColorUtils.getSecondaryTextColor(currentTime);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 20),

                // Location with edit button - Enhanced
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorUtils.getCardColor(currentTime),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: ColorUtils.getCardBorderColor(currentTime),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorUtils.getShadowColor(currentTime),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: textColor, size: 22),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            provider.currentLocation.city,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showLocationDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: textColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Current date and time - Enhanced
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('EEEE, d MMMM HH:mm:ss', 'id_ID')
                          .format(_currentTime),
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Weather icon with animation
                LayoutBuilder(
                  builder: (context, constraints) {
                    final iconSize = constraints.maxWidth > 400 ? 70.0 : 50.0;
                    final padding = constraints.maxWidth > 400 ? 18.0 : 12.0;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: EdgeInsets.all(padding),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorUtils.getCardColor(currentTime),
                                border: Border.all(
                                  color: ColorUtils.getCardBorderColor(
                                      currentTime),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ColorUtils.getShadowColor(currentTime),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                WeatherUtils.getWeatherIcon(
                                  weather.current.weatherCode,
                                  currentTime.hour >= 6 &&
                                      currentTime.hour < 18,
                                ),
                                style: TextStyle(fontSize: iconSize),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Current temperature - Enhanced (OVERRIDE: Boleh warna accent)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tempSize = constraints.maxWidth > 400 ? 80.0 : 60.0;
                    // TEMPERATURE UTAMA: Boleh pakai warna accent (biru)
                    final tempColor = ColorUtils.getPrimaryColor(currentTime);

                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [tempColor, tempColor.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        '${weather.current.temperature.round()}°',
                        style: TextStyle(
                          fontSize: tempSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.white, // Needed for ShaderMask
                          height: 1,
                          shadows: [
                            Shadow(
                              color: ColorUtils.getShadowColor(currentTime),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 6),

                // Weather description - Enhanced
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorUtils.getCardBorderColor(currentTime),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    WeatherUtils.getWeatherDescription(
                        weather.current.weatherCode),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Min/Max temperature - Enhanced with better layout
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorUtils.getCardColor(currentTime),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorUtils.getCardBorderColor(currentTime),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorUtils.getShadowColor(currentTime),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEnhancedTempInfo(
                        Icons.thermostat_outlined,
                        'Terasa',
                        '${weather.current.apparentTemperature.round()}°',
                        textColor,
                        secondaryColor,
                      ),
                      Container(
                        height: 35,
                        width: 1,
                        color: ColorUtils.getCardBorderColor(currentTime),
                      ),
                      _buildEnhancedTempInfo(
                        Icons.trending_up,
                        'Maks',
                        '${weather.daily.temperatureMax[0].round()}°',
                        textColor,
                        secondaryColor,
                      ),
                      Container(
                        height: 35,
                        width: 1,
                        color: ColorUtils.getCardBorderColor(currentTime),
                      ),
                      _buildEnhancedTempInfo(
                        Icons.trending_down,
                        'Min',
                        '${weather.daily.temperatureMin[0].round()}°',
                        textColor,
                        secondaryColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTempInfo(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color secondaryColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: secondaryColor, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showLocationDialog(BuildContext context) {
    final controller = TextEditingController();
    final textColor = ColorUtils.getTextColor(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_city,
                color: ColorUtils.getPrimaryColor(DateTime.now())),
            const SizedBox(width: 12),
            const Text('Ubah Lokasi'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nama Kota',
            hintText: 'Contoh: Jakarta, Surabaya',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<WeatherProvider>().changeLocationByName(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<WeatherProvider>()
                    .changeLocationByName(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtils.getPrimaryColor(DateTime.now()),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }
}
