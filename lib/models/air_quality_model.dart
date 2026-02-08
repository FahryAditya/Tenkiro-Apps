class AirQualityModel {
  final int aqi;
  final double pm25;
  final double pm10;
  final double carbonMonoxide;
  final double sulphurDioxide;
  final String category;
  final String description;

  AirQualityModel({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.carbonMonoxide,
    required this.sulphurDioxide,
    required this.category,
    required this.description,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};

    // Get pollutant values
    final pm25 = (current['pm2_5'] ?? 0).toDouble();
    final pm10 = (current['pm10'] ?? 0).toDouble();
    final co = (current['carbon_monoxide'] ?? 0).toDouble();
    final so2 = (current['sulphur_dioxide'] ?? 0).toDouble();

    // Calculate AQI based on PM2.5 (US EPA standard)
    final aqi = _calculateAQI(pm25);
    final category = _getAQICategory(aqi);
    final description = _getAQIDescription(aqi);

    return AirQualityModel(
      aqi: aqi,
      pm25: pm25,
      pm10: pm10,
      carbonMonoxide: co,
      sulphurDioxide: so2,
      category: category,
      description: description,
    );
  }

  static int _calculateAQI(double pm25) {
    if (pm25 <= 12.0) {
      return ((50 - 0) / (12.0 - 0.0) * (pm25 - 0.0) + 0).round();
    } else if (pm25 <= 35.4) {
      return ((100 - 51) / (35.4 - 12.1) * (pm25 - 12.1) + 51).round();
    } else if (pm25 <= 55.4) {
      return ((150 - 101) / (55.4 - 35.5) * (pm25 - 35.5) + 101).round();
    } else if (pm25 <= 150.4) {
      return ((200 - 151) / (150.4 - 55.5) * (pm25 - 55.5) + 151).round();
    } else if (pm25 <= 250.4) {
      return ((300 - 201) / (250.4 - 150.5) * (pm25 - 150.5) + 201).round();
    } else {
      return ((500 - 301) / (500.4 - 250.5) * (pm25 - 250.5) + 301).round();
    }
  }

  static String _getAQICategory(int aqi) {
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Tidak Sehat untuk Sensitif';
    if (aqi <= 200) return 'Tidak Sehat';
    if (aqi <= 300) return 'Sangat Tidak Sehat';
    return 'Berbahaya';
  }

  static String _getAQIDescription(int aqi) {
    if (aqi <= 50)
      return 'Kualitas udara baik, aman untuk aktivitas luar ruangan';
    if (aqi <= 100) return 'Dapat diterima, namun sensitif mungkin terpengaruh';
    if (aqi <= 150)
      return 'Kelompok sensitif sebaiknya mengurangi aktivitas luar';
    if (aqi <= 200)
      return 'Semua orang mulai terpengaruh, kurangi aktivitas luar';
    if (aqi <= 300)
      return 'Peringatan kesehatan, hindari aktivitas luar ruangan';
    return 'Darurat kesehatan, tetap di dalam ruangan';
  }

  int getAQIColor() {
    if (aqi <= 50) return 0xFF43A047; // Green 600 - Better contrast
    if (aqi <= 100) return 0xFFFBC02D; // Yellow 700 - Readable on white
    if (aqi <= 150) return 0xFFF57C00; // Orange 700
    if (aqi <= 200) return 0xFFD32F2F; // Red 700
    if (aqi <= 300) return 0xFF7B1FA2; // Purple 700
    return 0xFF880E4F; // Maroon (Pink 900)
  }
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
