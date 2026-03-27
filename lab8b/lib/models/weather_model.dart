class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final String description;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.description,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherModel(
      cityName: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
      description: _descriptionFromCode((current['weather_code'] as num).toInt()),
    );
  }

  static String _descriptionFromCode(int code) {
    if (code == 0) return 'Trời quang đãng';
    if (code <= 3) return 'Có mây';
    if (code <= 49) return 'Sương mù';
    if (code <= 59) return 'Mưa phùn';
    if (code <= 69) return 'Mưa';
    if (code <= 79) return 'Tuyết';
    if (code <= 84) return 'Mưa rào';
    if (code <= 99) return 'Dông bão';
    return 'Không xác định';
  }

  String get weatherIcon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 69) return '🌧️';
    if (weatherCode <= 79) return '❄️';
    if (weatherCode <= 84) return '🌦️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }

  String get recommendation {
    if (weatherCode >= 51) return '☂️ Nhớ mang ô! Trời đang mưa hoặc có dông.';
    if (weatherCode >= 40) return '🌫️ Sương mù dày, lái xe cẩn thận.';
    if (weatherCode >= 2) return '🌥️ Trời nhiều mây, mang ô phòng hờ nhé.';
    if (temperature >= 35) return '🥵 Quá nóng! Hạn chế ra ngoài, uống nhiều nước.';
    if (temperature >= 28) return '😎 Trời nắng đẹp nhưng khá nóng. Bôi kem chống nắng!';
    if (temperature >= 18) return '🚶 Thời tiết lý tưởng để đi dạo ngoài trời!';
    if (temperature >= 10) return '🧥 Trời mát, nên mặc thêm áo khoác.';
    return '🥶 Trời lạnh, mặc ấm trước khi ra ngoài nhé!';
  }

  String get windDescription {
    if (windSpeed < 5) return 'Gió nhẹ';
    if (windSpeed < 20) return 'Gió vừa';
    if (windSpeed < 40) return 'Gió mạnh';
    return 'Gió rất mạnh';
  }
}