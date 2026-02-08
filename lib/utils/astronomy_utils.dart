import 'dart:math' as math;

/// Astronomy calculations for solar and lunar data
/// Based on Jean Meeus "Astronomical Algorithms"
class AstronomyUtils {
  static const double deg2rad = math.pi / 180.0;
  static const double rad2deg = 180.0 / math.pi;

  /// Calculate Julian Day from DateTime
  static double toJulianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day +
        (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;

    final a = (14 - m) ~/ 12;
    final y1 = y + 4800 - a;
    final m1 = m + 12 * a - 3;

    return d +
        (153 * m1 + 2) ~/ 5 +
        365 * y1 +
        y1 ~/ 4 -
        y1 ~/ 100 +
        y1 ~/ 400 -
        32045;
  }

  /// Calculate solar elevation angle in degrees
  /// Returns angle above horizon (-90 to 90)
  static double calculateSolarElevation(
    DateTime time,
    double latitude,
    double longitude,
  ) {
    final jd = toJulianDay(time);
    final jc = (jd - 2451545.0) / 36525.0; // Julian Century

    // Sun's mean longitude
    final l0 = (280.46646 + jc * (36000.76983 + jc * 0.0003032)) % 360;

    // Sun's mean anomaly
    final m = (357.52911 + jc * (35999.05029 - 0.0001537 * jc)) % 360;

    // Sun's equation of center
    final c =
        math.sin(m * deg2rad) * (1.914602 - jc * (0.004817 + 0.000014 * jc)) +
            math.sin(2 * m * deg2rad) * (0.019993 - 0.000101 * jc) +
            math.sin(3 * m * deg2rad) * 0.000289;

    // Sun's true longitude
    final sunLong = l0 + c;

    // Sun's declination
    final dec =
        math.asin(math.sin(23.439 * deg2rad) * math.sin(sunLong * deg2rad)) *
            rad2deg;

    // Hour angle
    final gmst = (280.46061837 + 360.98564736629 * (jd - 2451545.0)) % 360;
    final localSiderealTime = (gmst + longitude) % 360;
    final hourAngle = localSiderealTime - sunLong;

    // Solar elevation
    final lat = latitude * deg2rad;
    final ha = hourAngle * deg2rad;
    final d = dec * deg2rad;

    final elevation = math.asin(
          math.sin(lat) * math.sin(d) +
              math.cos(lat) * math.cos(d) * math.cos(ha),
        ) *
        rad2deg;

    return elevation;
  }

  /// Get golden hour status
  /// Golden hour: Sun elevation between -6° and 6°
  static GoldenHourStatus getGoldenHourStatus(double elevation) {
    if (elevation >= -0.833 && elevation <= 6) {
      return elevation > 0
          ? GoldenHourStatus.morningGolden
          : GoldenHourStatus.eveningGolden;
    } else if (elevation > -6 && elevation < -0.833) {
      return GoldenHourStatus.blueHour;
    } else if (elevation > 6) {
      return GoldenHourStatus.daylight;
    } else {
      return GoldenHourStatus.night;
    }
  }

  /// Calculate moon phase (0-29.5 days)
  /// 0 = New Moon, 7.4 = First Quarter, 14.8 = Full Moon, 22.1 = Last Quarter
  static double calculateMoonAge(DateTime date) {
    final jd = toJulianDay(date);

    // Known new moon (2000-01-06 18:14 UTC)
    const knownNewMoon = 2451550.1;
    const synodicMonth = 29.53058867; // Days

    final daysSinceKnownNewMoon = jd - knownNewMoon;
    final moonAge = daysSinceKnownNewMoon % synodicMonth;

    return moonAge;
  }

  /// Get moon phase name and illumination
  static MoonPhase getMoonPhase(double moonAge) {
    final illumination =
        50 * (1 - math.cos((moonAge / 29.53058867) * 2 * math.pi));

    String phaseName;
    String emoji;

    if (moonAge < 1.84566) {
      phaseName = 'New Moon';
      emoji = '🌑';
    } else if (moonAge < 5.53699) {
      phaseName = 'Waxing Crescent';
      emoji = '🌒';
    } else if (moonAge < 9.22831) {
      phaseName = 'First Quarter';
      emoji = '🌓';
    } else if (moonAge < 12.91963) {
      phaseName = 'Waxing Gibbous';
      emoji = '🌔';
    } else if (moonAge < 16.61096) {
      phaseName = 'Full Moon';
      emoji = '🌕';
    } else if (moonAge < 20.30228) {
      phaseName = 'Waning Gibbous';
      emoji = '🌖';
    } else if (moonAge < 23.99361) {
      phaseName = 'Last Quarter';
      emoji = '🌗';
    } else if (moonAge < 27.68493) {
      phaseName = 'Waning Crescent';
      emoji = '🌘';
    } else {
      phaseName = 'New Moon';
      emoji = '🌑';
    }

    return MoonPhase(
      age: moonAge,
      illumination: illumination,
      phaseName: phaseName,
      emoji: emoji,
    );
  }

  /// Calculate night sky visibility index (0-100)
  /// Higher is better for stargazing
  static SkyVisibilityIndex calculateSkyVisibility({
    required int cloudCover, // 0-100%
    required double moonIllumination, // 0-100%
    required double visibility, // km
    required int humidity, // 0-100%
  }) {
    // Weights
    const cloudWeight = 0.40;
    const moonWeight = 0.30;
    const visibilityWeight = 0.20;
    const humidityWeight = 0.10;

    // Normalize values (higher is better)
    final cloudScore = (100 - cloudCover).toDouble();
    final moonScore = (100 - moonIllumination);
    final visibilityScore = (visibility / 50 * 100).clamp(0, 100).toDouble();
    final humidityScore = (100 - humidity).toDouble();

    // Calculate weighted score
    final totalScore = (cloudScore * cloudWeight +
            moonScore * moonWeight +
            visibilityScore * visibilityWeight +
            humidityScore * humidityWeight)
        .round();

    // Determine category
    String category;
    String recommendation;

    if (totalScore >= 80) {
      category = 'Ideal';
      recommendation = 'Perfect untuk stargazing & astrofotografi!';
    } else if (totalScore >= 60) {
      category = 'Baik';
      recommendation = 'Kondisi bagus untuk melihat bintang';
    } else if (totalScore >= 40) {
      category = 'Cukup';
      recommendation = 'Beberapa objek langit terlihat';
    } else {
      category = 'Buruk';
      recommendation = 'Tidak ideal untuk observasi langit';
    }

    return SkyVisibilityIndex(
      score: totalScore,
      category: category,
      recommendation: recommendation,
    );
  }

  /// Calculate day length in hours
  static double calculateDayLength(
    DateTime date,
    double latitude,
    double longitude,
    DateTime sunrise,
    DateTime sunset,
  ) {
    final diff = sunset.difference(sunrise);
    return diff.inMinutes / 60.0;
  }

  /// Calculate solar declination (angle relative to equator)
  static double calculateSolarDeclination(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final angle = 2 * math.pi / 365 * (dayOfYear - 81);
    final declination = 23.45 * math.sin(angle);
    return declination;
  }

  /// Get season for given date and hemisphere
  static String getSeason(DateTime date, bool northernHemisphere) {
    final month = date.month;
    final day = date.day;

    if (northernHemisphere) {
      if ((month == 3 && day >= 20) ||
          (month > 3 && month < 6) ||
          (month == 6 && day < 21)) {
        return 'Musim Semi';
      } else if ((month == 6 && day >= 21) ||
          (month > 6 && month < 9) ||
          (month == 9 && day < 23)) {
        return 'Musim Panas';
      } else if ((month == 9 && day >= 23) ||
          (month > 9 && month < 12) ||
          (month == 12 && day < 21)) {
        return 'Musim Gugur';
      } else {
        return 'Musim Dingin';
      }
    } else {
      // Southern hemisphere - opposite
      if ((month == 3 && day >= 20) ||
          (month > 3 && month < 6) ||
          (month == 6 && day < 21)) {
        return 'Musim Gugur';
      } else if ((month == 6 && day >= 21) ||
          (month > 6 && month < 9) ||
          (month == 9 && day < 23)) {
        return 'Musim Dingin';
      } else if ((month == 9 && day >= 23) ||
          (month > 9 && month < 12) ||
          (month == 12 && day < 21)) {
        return 'Musim Semi';
      } else {
        return 'Musim Panas';
      }
    }
  }
}

/// Golden Hour status enum
enum GoldenHourStatus {
  night,
  blueHour,
  morningGolden,
  eveningGolden,
  daylight,
}

/// Moon Phase data class
class MoonPhase {
  final double age; // Days (0-29.5)
  final double illumination; // Percentage (0-100)
  final String phaseName;
  final String emoji;

  MoonPhase({
    required this.age,
    required this.illumination,
    required this.phaseName,
    required this.emoji,
  });
}

/// Sky Visibility Index data class
class SkyVisibilityIndex {
  final int score; // 0-100
  final String category; // Ideal, Baik, Cukup, Buruk
  final String recommendation;

  SkyVisibilityIndex({
    required this.score,
    required this.category,
    required this.recommendation,
  });
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
