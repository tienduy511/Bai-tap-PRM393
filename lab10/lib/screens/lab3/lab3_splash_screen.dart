import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import 'lab3_home_screen.dart';
import 'lab3_login_screen.dart';

class Lab3SplashScreen extends StatefulWidget {
  const Lab3SplashScreen({super.key});

  @override
  State<Lab3SplashScreen> createState() => _State();
}

class _State extends State<Lab3SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final token = await SessionService().getToken();
    final username = await SessionService().getUsername();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null
            ? Lab3HomeScreen(username: username ?? 'User')
            : const Lab3LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 72),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang kiểm tra phiên đăng nhập...'),
          ],
        ),
      ),
    );
  }
}