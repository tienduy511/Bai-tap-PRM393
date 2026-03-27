import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Bước 1: Tìm tọa độ (lat, lon) từ tên thành phố
  Future<Map<String, dynamic>> _fetchCoordinates(String cityName) async {
    final uri = Uri.parse(
      '$_geocodingBaseUrl?name=${Uri.encodeComponent(cityName)}&count=1&language=vi&format=json',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể kết nối đến server. Mã lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw Exception('Không tìm thấy thành phố "$cityName". Thử tên khác nhé!');
    }

    return results.first as Map<String, dynamic>;
  }

  /// Bước 2: Lấy dữ liệu thời tiết từ tọa độ
  Future<WeatherModel> fetchWeatherForCity(String cityName) async {
    // Lấy tọa độ
    final locationData = await _fetchCoordinates(cityName);
    final lat = locationData['latitude'] as num;
    final lon = locationData['longitude'] as num;
    final resolvedName = locationData['name'] as String;
    final country = locationData['country'] as String? ?? '';

    // Gọi weather API
    final uri = Uri.parse(
      '$_weatherBaseUrl'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code'
          '&wind_speed_unit=kmh'
          '&timezone=auto',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi lấy dữ liệu thời tiết. Mã lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final displayName = country.isNotEmpty ? '$resolvedName, $country' : resolvedName;

    return WeatherModel.fromJson(data, displayName);
  }
}