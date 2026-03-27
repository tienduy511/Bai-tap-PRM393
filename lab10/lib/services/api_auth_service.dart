import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAuthService {
  static const _baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Đăng nhập thất bại');
  }
}