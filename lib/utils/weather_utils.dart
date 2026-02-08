class WeatherUtils {
  // Convert WMO Weather code to description
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 71:
      case 73:
      case 75:
        return 'Hujan Salju';
      case 77:
        return 'Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Lebat';
      case 85:
      case 86:
        return 'Salju Lebat';
      case 95:
        return 'Petir';
      case 96:
      case 99:
        return 'Petir & Hujan Es';
      default:
        return 'Tidak Diketahui';
    }
  }

  // Get weather icon based on code and isDay
  static String getWeatherIcon(int code, bool isDay) {
    if (!isDay) {
      // Night icons
      switch (code) {
        case 0:
          return '🌙';
        case 1:
        case 2:
        case 3:
          return '☁️';
        case 45:
        case 48:
          return '🌫️';
        case 51:
        case 53:
        case 55:
        case 61:
        case 63:
        case 65:
        case 80:
        case 81:
        case 82:
          return '🌧️';
        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86:
          return '❄️';
        case 95:
        case 96:
        case 99:
          return '⛈️';
        default:
          return '🌙';
      }
    } else {
      // Day icons
      switch (code) {
        case 0:
          return '☀️';
        case 1:
        case 2:
          return '🌤️';
        case 3:
          return '⛅';
        case 45:
        case 48:
          return '🌫️';
        case 51:
        case 53:
        case 55:
        case 61:
        case 63:
        case 65:
        case 80:
        case 81:
        case 82:
          return '🌧️';
        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86:
          return '❄️';
        case 95:
        case 96:
        case 99:
          return '⛈️';
        default:
          return '☀️';
      }
    }
  }

  // Get UV Index description
  static String getUVDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Rendah';
    if (uvIndex <= 5) return 'Sedang';
    if (uvIndex <= 7) return 'Tinggi';
    if (uvIndex <= 10) return 'Sangat Tinggi';
    return 'Ekstrim';
  }

  // Get wind description
  static String getWindDescription(double windSpeed) {
    if (windSpeed < 5) return 'Tenang';
    if (windSpeed < 20) return 'Sepoi-sepoi';
    if (windSpeed < 40) return 'Sedang';
    if (windSpeed < 60) return 'Kencang';
    return 'Sangat Kencang';
  }

  // Get visibility description
  static String getVisibilityDescription(double visibility) {
    if (visibility < 1) return 'Sangat Buruk';
    if (visibility < 4) return 'Buruk';
    if (visibility < 10) return 'Sedang';
    return 'Baik';
  }

  // Get humidity description
  static String getHumidityDescription(int humidity) {
    if (humidity < 30) return 'Kering';
    if (humidity < 60) return 'Nyaman';
    if (humidity < 80) return 'Lembab';
    return 'Sangat Lembab';
  
  }
}
