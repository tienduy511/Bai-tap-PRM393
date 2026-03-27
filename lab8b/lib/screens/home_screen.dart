import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _controller = TextEditingController();

  Future<WeatherModel>? _weatherFuture;
  String _searchedCity = '';

  void _search() {
    final city = _controller.text.trim();
    if (city.isEmpty) return;
    setState(() {
      _searchedCity = city;
      _weatherFuture = _service.fetchWeatherForCity(city);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌤️ Thời Tiết',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tra cứu thời tiết & gợi ý cho ngày của bạn',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Nhập tên thành phố... (VD: Hanoi)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _search,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_weatherFuture == null) {
      return _buildEmptyState();
    }
    return FutureBuilder<WeatherModel>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return _buildEmptyState();
        }
        return _buildWeatherCard(snapshot.data!);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Nhập tên thành phố để xem thời tiết',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'VD: Hanoi, Ho Chi Minh, Da Nang...',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4FC3F7)),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu thời tiết...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    final message = error.replaceFirst('Exception: ', '');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherModel weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Card chính: thành phố + nhiệt độ
          _buildMainCard(weather),
          const SizedBox(height: 16),
          // Gợi ý
          _buildRecommendationCard(weather),
          const SizedBox(height: 16),
          // Thông tin chi tiết
          _buildDetailsRow(weather),
        ],
      ),
    );
  }

  Widget _buildMainCard(WeatherModel weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  weather.cityName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
              Text(weather.weatherIcon, style: const TextStyle(fontSize: 72)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Cảm giác như ${weather.feelsLike.toStringAsFixed(1)}°C',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(WeatherModel weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý cho hôm nay',
            style: TextStyle(
              color: const Color(0xFF4FC3F7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weather.recommendation,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(WeatherModel weather) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            icon: '💧',
            label: 'Độ ẩm',
            value: '${weather.humidity}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            icon: '💨',
            label: 'Gió',
            value: '${weather.windSpeed.toStringAsFixed(0)} km/h',
            subtitle: weather.windDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}