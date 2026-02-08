import 'package:flutter/material.dart';

class ColorUtils {
  // Get background color based on time and weather
  static Color getBackgroundColor(DateTime currentTime, int weatherCode) {
    final hour = currentTime.hour;
    
    // Malam (20:00 - 04:59) - Lighter untuk text hitam
    if (hour >= 20 || hour < 5) {
      return const Color(0xFFB8C5D6); // Light blue-gray
    }
    
    // Pagi (05:00 - 09:59)
    if (hour >= 5 && hour < 10) {
      return const Color(0xFFD4E3F0); // Light morning blue
    }
    
    // Senja (17:00 - 19:59) - Lighter untuk text hitam
    if (hour >= 17 && hour < 20) {
      return const Color(0xFFEDB8A8); // Light peachy sunset
    }
    
    // Siang (10:00 - 16:59)
    // Check if cloudy
    if (weatherCode >= 45 && weatherCode <= 48) {
      return const Color(0xFFDFE6ED); // Light gray cloudy
    }
    if (weatherCode >= 51) {
      return const Color(0xFFD8DFE8); // Light gray rainy
    }
    
    return const Color(0xFFF0F4F8); // Very light clear sky
  }

  // Get gradient for sunset/sunrise with better contrast
  static LinearGradient getSunsetGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFC8B0), // Light peachy
        Color(0xFFEDB8A8), // Light coral
      ],
      stops: [0.0, 1.0],
    );
  }

  // Check if it's dark mode time
  static bool isDarkMode(DateTime currentTime) {
    final hour = currentTime.hour;
    return hour >= 17 || hour < 5; // Extended to include sunset
  }

  // Check if it's sunset time
  static bool isSunsetTime(DateTime currentTime) {
    final hour = currentTime.hour;
    return hour >= 17 && hour < 20;
  }

  // Get text color based on background with WCAG AA compliance
  static Color getTextColor(DateTime currentTime) {
    // SEMUA TEKS HITAM untuk konsistensi
    return Colors.black;
  }

  // Get card color with better visibility
  static Color getCardColor(DateTime currentTime) {
    final hour = currentTime.hour;
    
    // Sunset special handling
    if (hour >= 17 && hour < 20) {
      return Colors.white.withOpacity(0.15); // More transparent for sunset
    }
    
    // Night mode
    if (hour >= 20 || hour < 5) {
      return Colors.white.withOpacity(0.12);
    }
    
    // Day mode
    return Colors.white.withOpacity(0.85);
  }

  // Get primary color based on time
  static Color getPrimaryColor(DateTime currentTime) {
    final hour = currentTime.hour;
    
    if (hour >= 17 && hour < 20) {
      return const Color(0xFFFFB380); // Orange tint for sunset
    }
    
    if (hour >= 20 || hour < 5) {
      return const Color(0xFF8AAEE0); // Blue for night
    }
    
    return const Color(0xFF395886); // Default blue
  }

  // Get secondary text color (slightly lighter for hierarchy)
  static Color getSecondaryTextColor(DateTime currentTime) {
    // Secondary text sedikit lebih terang tapi tetap hitam
    return Colors.black87;
  }

  // Get card border color for better definition
  static Color getCardBorderColor(DateTime currentTime) {
    final hour = currentTime.hour;
    
    if (hour >= 17 && hour < 20) {
      return Colors.white.withOpacity(0.3); // Visible border for sunset
    }
    
    if (hour >= 20 || hour < 5) {
      return Colors.white.withOpacity(0.2);
    }
    
    return Colors.black.withOpacity(0.08);
  }

  // Get elevation/shadow color
  static Color getShadowColor(DateTime currentTime) {
    final hour = currentTime.hour;
    
    if (hour >= 17 || hour < 5) {
      return Colors.black.withOpacity(0.3); // Darker shadows for dark modes
    }
    
    return Colors.black.withOpacity(0.1);
  }
}