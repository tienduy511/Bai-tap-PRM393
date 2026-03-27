import 'package:flutter/material.dart';
import 'screens/lab1/lab1_login_screen.dart';
import 'screens/lab2/lab2_login_screen.dart';
import 'screens/lab3/lab3_splash_screen.dart';
import 'screens/lab5/lab5_notification_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10 – Chọn bài'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _LabCard(
              labNumber: '10.1',
              title: 'Mock Login',
              subtitle: 'Giả lập backend · Validate form',
              icon: Icons.person_outline,
              color: Colors.indigo,
              onTap: () => _navigate(context, const Lab1LoginScreen()),
            ),
            const SizedBox(height: 12),
            _LabCard(
              labNumber: '10.2',
              title: 'Real REST API Login',
              subtitle: 'DummyJSON · HTTP POST · Parse token',
              icon: Icons.cloud_outlined,
              color: Colors.blue,
              onTap: () => _navigate(context, const Lab2LoginScreen()),
            ),
            const SizedBox(height: 12),
            _LabCard(
              labNumber: '10.3',
              title: 'Auto Login & Logout',
              subtitle: 'SharedPreferences · SplashScreen · Session',
              icon: Icons.lock_clock_outlined,
              color: Colors.teal,
              onTap: () => _navigate(context, const Lab3SplashScreen()),
            ),
            const SizedBox(height: 12),
            _LabCard(
              labNumber: '10.4',
              title: 'Firebase Google Sign-In',
              subtitle: 'Chưa cài Firebase – bỏ qua',
              icon: Icons.block_outlined,
              color: Colors.grey,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lab 10.4 yêu cầu cài Firebase – bỏ qua'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _LabCard(
              labNumber: '10.5',
              title: 'Local Notification',
              subtitle: 'flutter_local_notifications · LO7',
              icon: Icons.notifications_outlined,
              color: Colors.orange,
              onTap: () => _navigate(context, const Lab5NotificationScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  final String labNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LabCard({
    required this.labNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lab $labNumber  –  $title',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}