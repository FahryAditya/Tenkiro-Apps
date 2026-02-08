class WeatherModel {
  final CurrentWeather current;
  final HourlyWeather hourly;
  final DailyWeather daily;
  final String timezone;

  WeatherModel({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezone,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      current: CurrentWeather.fromJson(json['current']),
      hourly: HourlyWeather.fromJson(json['hourly']),
      daily: DailyWeather.fromJson(json['daily']),
      timezone: json['timezone'] ?? 'UTC',
    );
  }
}

class CurrentWeather {
  final String time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double pressure;
  final double visibility;
  final int cloudCover;
  final double uvIndex;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.cloudCover,
    required this.uvIndex,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] ?? '',
      temperature: (json['temperature_2m'] ?? 0).toDouble(),
      apparentTemperature: (json['apparent_temperature'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
      windSpeed: (json['wind_speed_10m'] ?? 0).toDouble(),
      humidity: json['relative_humidity_2m'] ?? 0,
      pressure: (json['surface_pressure'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 0).toDouble() / 1000, // Convert to km
      cloudCover: json['cloud_cover'] ?? 0,
      uvIndex: (json['uv_index'] ?? 0).toDouble(),
    );
  }
}

class HourlyWeather {
  final List<String> time;
  final List<double> temperature;
  final List<double> apparentTemperature;
  final List<int> weatherCode;
  final List<int> humidity;
  final List<double> windSpeed;
  final List<double> uvIndex;
  final List<int> precipitation;
  final List<int> isDay;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.precipitation,
    required this.isDay,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: List<String>.from(json['time'] ?? []),
      temperature: List<double>.from(
        (json['temperature_2m'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      apparentTemperature: List<double>.from(
        (json['apparent_temperature'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      weatherCode: List<int>.from(json['weather_code'] ?? []),
      humidity: List<int>.from(json['relative_humidity_2m'] ?? []),
      windSpeed: List<double>.from(
        (json['wind_speed_10m'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      uvIndex: List<double>.from(
        (json['uv_index'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      precipitation: List<int>.from(json['precipitation_probability'] ?? []),
      isDay: List<int>.from(json['is_day'] ?? []),
    );
  }
}

class DailyWeather {
  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperatureMax;
  final List<double> temperatureMin;
  final List<int> precipitationProbability;
  final List<String> sunrise;
  final List<String> sunset;
  final List<double> uvIndexMax;

  DailyWeather({
    required this.time,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbability,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time'] ?? []),
      weatherCode: List<int>.from(json['weather_code'] ?? []),
      temperatureMax: List<double>.from(
        (json['temperature_2m_max'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      temperatureMin: List<double>.from(
        (json['temperature_2m_min'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
      precipitationProbability: List<int>.from(
        json['precipitation_probability_max'] ?? []
      ),
      sunrise: List<String>.from(json['sunrise'] ?? []),
      sunset: List<String>.from(json['sunset'] ?? []),
      uvIndexMax: List<double>.from(
        (json['uv_index_max'] ?? []).map((e) => (e ?? 0).toDouble())
      ),
    );
  }
}